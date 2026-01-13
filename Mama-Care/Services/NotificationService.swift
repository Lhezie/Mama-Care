//
//  NotificationService.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 24/11/2025.
//

import Foundation
import UserNotifications
import SwiftUI

extension Notification.Name {
    static let navigateToMood = Notification.Name("NavigateToMood")
    static let navigateToVaccines = Notification.Name("NavigateToVaccines")
}

@MainActor
class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    
    @Published var isAuthorized = false
    private let notificationCenter = UNUserNotificationCenter.current()
    
    override private init() {
        super.init()
        notificationCenter.delegate = self
        checkAuthorizationStatus()
    }
    
    //  Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                self.isAuthorized = granted
            }
            print(granted ? " Notification permission granted" : "Notification permission denied")
            return granted
        } catch {
            print("Failed to request notification permission: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() {
        Task {
            let settings = await notificationCenter.notificationSettings()
            await MainActor.run {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    //  Mood Check-In Notifications
    
    func scheduleMoodCheckInNotifications(times: [Int]? = nil) {
        // times are in minutes since midnight (e.g., 480 = 08:00, 840 = 14:00)
        let checkInTimes = times ?? [480, 840, 1200] // Default: 08:00, 14:00, 20:00
        
        // Cancel existing mood notifications
        cancelMoodCheckInNotifications()
        
        for minutesSinceMidnight in checkInTimes {
            scheduleMoodNotification(at: minutesSinceMidnight)
        }
        
        print("Scheduled \(checkInTimes.count) mood check-in notifications")
    }
    
    private func scheduleMoodNotification(at minutesSinceMidnight: Int) {
        let hour = minutesSinceMidnight / 60
        let minute = minutesSinceMidnight % 60
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Mood Check-In"
        content.body = "How are you feeling today? Take a moment to check in with yourself."
        content.sound = .default
        content.categoryIdentifier = "MOOD_CHECKIN"
        
        // Schedule for specific hour and minute every day
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let identifier = "mood-checkin-\(minutesSinceMidnight)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule mood notification at \(String(format: "%02d:%02d", hour, minute)) - \(error)")
            } else {
                print("Scheduled mood notification at \(String(format: "%02d:%02d", hour, minute))")
            }
        }
    }
    
    func cancelMoodCheckInNotifications() {
        // Cancel all mood check-in notifications (they all start with "mood-checkin-")
        notificationCenter.getPendingNotificationRequests { requests in
            let moodIdentifiers = requests
                .filter { $0.identifier.starts(with: "mood-checkin-") }
                .map { $0.identifier }
            
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: moodIdentifiers)
            print("🗑️ Cancelled \(moodIdentifiers.count) mood check-in notifications")
        }
    }
    
    //  Vaccine Reminder Notifications
    
    func scheduleVaccineReminder(for vaccine: VaccineItem) {
        guard let dueDate = vaccine.dueDate else {
            print("No due date for vaccine: \(vaccine.name)")
            return
        }
        
        // Calculate 24 hours before due date
        let reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: dueDate)
        
        guard let reminderDate = reminderDate, reminderDate > Date() else {
            print("Reminder date is in the past for vaccine: \(vaccine.name)")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Vaccine Reminder"
        content.body = "\(vaccine.name) is due tomorrow. Don't forget to schedule your appointment!"
        content.sound = .default
        content.categoryIdentifier = "VACCINE_REMINDER"
        content.userInfo = ["vaccineId": vaccine.id.uuidString]
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let identifier = "vaccine-\(vaccine.id.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule vaccine reminder for \(vaccine.name) - \(error)")
            } else {
                print("Scheduled vaccine reminder for \(vaccine.name) on \(reminderDate)")
            }
        }
    }
    
    func scheduleVaccineReminders(for vaccines: [VaccineItem]) {
        // Only schedule for upcoming and due vaccines (not completed or overdue)
        let vaccinesToSchedule = vaccines.filter { vaccine in
            vaccine.status == .upcoming || vaccine.status == .due
        }
        
        for vaccine in vaccinesToSchedule {
            scheduleVaccineReminder(for: vaccine)
        }
        
        print("Scheduled reminders for \(vaccinesToSchedule.count) vaccines")
    }
    
    func cancelVaccineReminder(for vaccineId: UUID) {
        let identifier = "vaccine-\(vaccineId.uuidString)"
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        print("🗑️ Cancelled vaccine reminder: \(identifier)")
    }
    
    func cancelAllVaccineReminders() {
        notificationCenter.getPendingNotificationRequests { requests in
            let vaccineIdentifiers = requests
                .filter { $0.identifier.starts(with: "vaccine-") }
                .map { $0.identifier }
            
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: vaccineIdentifiers)
            print("🗑️ Cancelled \(vaccineIdentifiers.count) vaccine reminders")
        }
    }
    
    //  Cancel All Notifications
    
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        print("🗑️ Cancelled all notifications")
    }
    
    //  Debug
    
    func listPendingNotifications() {
        notificationCenter.getPendingNotificationRequests { requests in
            print("📋 Pending notifications: \(requests.count)")
            for request in requests {
                print("   - \(request.identifier): \(request.content.title)")
            }
        }
    }
}

//  UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    // Handle notification when app is in foreground
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.notification.request.identifier
        
        if identifier.starts(with: "mood-checkin") {
            print("User tapped mood check-in notification")
            // Navigate to mood check-in view
            NotificationCenter.default.post(name: .navigateToMood, object: nil)
        } else if identifier.starts(with: "vaccine-") {
            print("User tapped vaccine reminder notification")
            // Navigate to vaccine schedule view
            NotificationCenter.default.post(name: .navigateToVaccines, object: nil)
        }
        
        completionHandler()
    }
}
