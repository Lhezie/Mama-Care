import Foundation
import Combine

@MainActor
final class VaccineViewModel: ObservableObject {
    @Published var vaccineSchedule: [VaccineItem] = []
    @Published var vaccineScheduleData: VaccineScheduleData?
    
    private var cancellables = Set<AnyCancellable>()
    
    private let notificationService: NotificationService
    private let swiftDataService = SwiftDataService.shared
    
    init(notificationService: NotificationService = .shared) {
        self.notificationService = notificationService
    }
    
    // Vaccine Loading
    
    func loadVaccines(for user: User?) {
        guard let user = user else {
            print(" No current user - cannot load vaccines")
            self.vaccineSchedule = []
            return
        }
        
        let country = user.country
        print(" Loading vaccine schedule for country: \(country)")
        vaccineScheduleData = JSONDataLoader.loadVaccineSchedule(country: country)
        
        guard let scheduleData = vaccineScheduleData else {
            print(" Vaccine schedule data not loaded for \(country)")
            self.vaccineSchedule = []
            return
        }
        
        // Determine the reference date for vaccine calculations
        let referenceDate: Date?
        let userTypeDescription: String
        
        if user.userType == .hasChild, let birthDate = user.birthDate {
            // User has a child - use birth date
            referenceDate = birthDate
            userTypeDescription = "child with birth date"
        } else if user.userType == .pregnant, let edd = user.expectedDeliveryDate {
            // User is pregnant - use expected delivery date
            referenceDate = edd
            userTypeDescription = "pregnant with EDD"
        } else {
            print(" User has no birth date or EDD - vaccines not applicable")
            self.vaccineSchedule = []
            return
        }
        
        guard let baseDate = referenceDate else {
            print(" No reference date available for vaccine calculation")
            self.vaccineSchedule = []
            return
        }
        
        print(" Calculating vaccines for \(userTypeDescription)")
        
        var vaccines: [VaccineItem] = []
        
        for appointment in scheduleData.schedule {
            guard let ageDays = appointment.ageDays else { continue }
            
            // Calculate due date from reference date (birth date or EDD)
            let dueDate = MamaCareDateHelper.vaccineDueDate(from: baseDate, ageDays: ageDays)
            
            // Determine status
            let status = determineVaccineStatus(dueDate: dueDate)
            
            // Create vaccine items from appointment
            if let items = appointment.items {
                // Regular appointment with multiple items
                for item in items {
                    let vaccineItem = VaccineItem(
                        code: item.code,
                        name: item.name,
                        ageRange: appointment.label ?? "As scheduled",
                        description: item.antigens?.joined(separator: ", ") ?? item.name,
                        dueDate: dueDate,
                        status: status
                    )
                    vaccines.append(vaccineItem)
                }
            } else if let code = appointment.code, let name = appointment.name {
                // Adolescent vaccine (single item without items array)
                let vaccineItem = VaccineItem(
                    code: code,
                    name: name,
                    ageRange: appointment.label ?? "As scheduled",
                    description: code, // This was already using code as description
                    dueDate: dueDate,
                    status: status
                )
                vaccines.append(vaccineItem)
            }
        }
        
        // SYNC WITH PERSISTENCE
        // Fetch persisted completion status
        let uid = AuthService.shared.currentUser?.uid
        if let userProfile = swiftDataService.fetchUserProfile(for: uid) {
            let vaccineRecords = swiftDataService.fetchVaccineRecords(for: userProfile)
            print("Syncing \(vaccineRecords.count) persisted vaccine records")
            
            // Update status based on records
            for record in vaccineRecords {
                if let index = vaccines.firstIndex(where: { $0.code == record.code }) {
                    vaccines[index].status = .completed
                    vaccines[index].completedDate = record.completedDate
                }
            }
        }
        
        // SYNC WITH CLOUD if applicable
        if user.storageMode == .cloud, let uid = AuthService.shared.currentUser?.uid {
            print(" Fetching cloud vaccine records for user: \(uid)")
            UserService.shared.fetchVaccineRecords(uid: uid)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print(" Failed to fetch cloud vaccine records: \(error)")
                    }
                } receiveValue: { [weak self] cloudRecords in
                    guard let self = self else { return }
                    print(" Fetched \(cloudRecords.count) vaccine records from cloud")
                    
                    // Update schedule with cloud records
                    for record in cloudRecords {
                        if let index = self.vaccineSchedule.firstIndex(where: { $0.code == record.code }) {
                            // Only update if not already completed locally (or trust cloud more?)
                            // Let's trust cloud as source of truth for completion if it says completed
                            if self.vaccineSchedule[index].status != .completed {
                                self.vaccineSchedule[index].status = .completed
                                self.vaccineSchedule[index].completedDate = record.completedDate
                                
                                // ALSO PERSIST TO LOCAL STORAGE FOR OFFLINE ACCESS
                                Task {
                                    if let userProfile = await MainActor.run(body: { self.swiftDataService.fetchUserProfile(for: uid) }) {
                                        // Check if record exists locally
                                        let localRecords = self.swiftDataService.fetchVaccineRecords(for: userProfile)
                                        if !localRecords.contains(where: { $0.code == record.code }) {
                                            // Create local record
                                             let newLocalRecord = VaccineRecord(
                                                code: record.code,
                                                completedDate: record.completedDate,
                                                user: userProfile
                                             )
                                            do {
                                                try await MainActor.run {
                                                    try self.swiftDataService.saveVaccineRecord(newLocalRecord)
                                                }
                                                print(" Saved cloud record to local storage: \(record.code)")
                                            } catch {
                                                print(" Failed to save cloud record locally: \(error)")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .store(in: &cancellables)
        }
        
        print(" Loaded \(vaccines.count) vaccines from \(country) schedule")
        self.vaccineSchedule = vaccines
        
        // Schedule vaccine reminders if notifications are enabled
        if user.notificationsWanted {
            notificationService.scheduleVaccineReminders(for: vaccines)
        }
    }
    
    //  Status & Completion
    
    private func determineVaccineStatus(dueDate: Date?) -> VaccineStatus {
        guard let dueDate = dueDate else { return .upcoming }
        
        let calendar = Calendar.current
        let today = Date()
        
        let daysUntilDue = calendar.dateComponents([.day], from: today, to: dueDate).day ?? 0
        
        // Removed .overdue status as requested
        if daysUntilDue <= 0 {
            return .due
        } else {
            return .upcoming
        }
    }
    
    func markVaccineAsCompleted(_ vaccine: VaccineItem) {
        if let index = vaccineSchedule.firstIndex(where: { $0.id == vaccine.id }) {
            vaccineSchedule[index].status = .completed
            vaccineSchedule[index].completedDate = Date()
            
            // Cancel the reminder notification
            notificationService.cancelVaccineReminder(for: vaccine.id)
            
            // Persist to SwiftData
            Task { @MainActor in
                 let uid = AuthService.shared.currentUser?.uid
                 var userProfile = swiftDataService.fetchUserProfile(for: uid)
                 
                 // Fallback: Try linking device-only profile to cloud user
                 if userProfile == nil, let currentUid = uid {
                     if let unlinkedProfile = swiftDataService.fetchUserProfile(for: nil) {
                         unlinkedProfile.uid = currentUid
                         try? swiftDataService.updateUserProfile(unlinkedProfile)
                         userProfile = unlinkedProfile
                     }
                 }
                 
                 if let userProfile = userProfile {
                      let record = VaccineRecord(
                         code: vaccine.code,
                         completedDate: Date(),
                         user: userProfile
                      )
                      
                      do {
                          try swiftDataService.saveVaccineRecord(record)
                          
                          // Sync to cloud if cloud user
                          let appUser = userProfile.toUser()
                          if appUser.storageMode == .cloud, let uid = uid {
                              UserService.shared.updateVaccineRecord(uid: uid, record: record)
                                 .sink { completion in
                                     if case .failure(let error) = completion {
                                         print("Cloud sync failed: \(error)")
                                     }
                                 } receiveValue: { _ in }
                                 .store(in: &cancellables) 
                          }
                      } catch {
                          print("Failed to save vaccine record: \(error)")
                      }
                  }
             }
        }
    }
}
