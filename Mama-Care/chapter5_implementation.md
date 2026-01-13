# Chapter 5: Implementation

## 5.1 Introduction

The implementation phase transforms the architectural designs and requirements specifications detailed in previous chapters into a functional software product. This chapter outlines the realization of the **Mama-Care** iOS application, demonstrating how the modular MVVM architecture, privacy-first data strategies, and specialized algorithms were translated into Swift code.

The primary goal of this implementation was to create a robust, user-centric mobile application that addresses the critical needs of expectant and new mothers in Nigeria and the UK. Key objectives for this chapter include:

1.  **Presenting the System Architecture**: Detailing the realized software structure, focusing on the separation of concerns between Views, ViewModels, and Services.
2.  **Reviewing Technology Selection**: Justifying the choice of the Swift ecosystem, SwiftUI framework, and Firebase backend services based on performance, safety, and scalability criteria.
3.  **Documenting Implementation Challenges**: Discussing significant technical hurdles encountered during development—such as offline-first synchronization and end-to-end encryption—and the specific software solutions devised to resolve them.
4.  **Demonstrating Core Functionality**: Providing concrete evidence of the features built, from the localized vaccination tracking algorithms to the AI-driven emotional support system.

The following sections provide a technical deep-dive into the codebase, illustrating how modern iOS engineering practices were applied to deliver a secure, reliable, and empathetic healthcare tool.

## 5.2 System Architecture

The Mama-Care application is built upon a **Model-View-ViewModel (MVVM)** architectural pattern, enhanced with a dedicated **Service Layer**. This architectural choice ensures valid separation of concerns, testability, and scalability. The system moves away from massive view controllers, promoting a declarative UI (View) driven by a distinct state container (ViewModel), which in turn delegates heavy lifting to specialized workers (Services).

### 5.2.1 Architectural Components & Interaction

The architecture consists of four distinct layers, each with specific responsibilities:

1.  **The View Layer (UI)**: Built entirely with **SwiftUI**, this layer is responsible for rendering the user interface. It is purely declarative and "state-driven," meaning it reacts to changes in the data rather than manipulating it directly.
    *   *Interaction*: Views observe `ObservableObject` ViewModels. When data changes (e.g., a user logs a mood), the View automatically re-renders to reflect the new state.

2.  **The ViewModel Layer (State Management)**: Serving as the brain of the application, ViewModels (e.g., `MamaCareViewModel`, `VaccineViewModel`) bridge the UI and the data layer. They handle business logic, such as calculating pregnancy weeks or filtering vaccination lists.
    *   *Interaction*: Steps between the UI and Services. It calls Service methods (e.g., `NotificationService.scheduleMoodCheckIn`) and exposes result data via `@Published` properties.

3.  **The Service Layer (Business Logic & Repository)**: This layer encapsulates specific capabilities and communicates with external systems. It converts raw data into domain objects.
    *   *Key Services*:
        *   `SwiftDataService`: Manages local, encrypted persistence using the SwiftData framework.
        *   `UserService`: Handles cloud synchronization with Firebase Firestore.
        *   `AIService`: Manages session contexts and privacy scrubbing for the Gemini API.
        *   `EncryptionService`: Provides the cryptographic primitives (ChaChaPoly) that secure data before it enters storage.

4.  **The Model Layer (Data Structure)**: Defines the immutable data schemas (e.g., `User`, `VaccineItem`, `MoodCheckIn`) used throughout the app. These models conform to `Codable` for JSON parsing and `PersistentModel` for SwiftData storage.

### 5.2.2 High-Level Architecture Diagram
Figure 5.1 illustrates the realized MVVM+Service architecture. It depicts the unidirectional data flow: User interactions in a `View` (e.g., `MoodCheckInView`) trigger methods in the corresponding `ViewModel`, which orchestrates calls to the Service Layer. The Services abstract the underlying persistence, routing writes to both the local SwiftData container and, if enabled, the remote Firestore database. The ViewModel's `@Published` properties are observed by the View, completing the reactive loop.

### 5.2.3 Addressing Implementation Issues in Architecture

The implementation of this architecture required solving several structural challenges:

#### A. Data Flow and Storage Mechanisms
A critical requirement was the "Offline-First" capability. The architecture was designed to treat the **Local Database (SwiftData)** as the single source of truth for the UI.
*   **Challenge**: Ensuring the UI remains responsive even when network calls to Firebase are slow or failing.
*   **Solution**: The **Repository Pattern**. The ViewModels primarily subscribe to local data streams. When a user updates data (e.g., marking a vaccine as done), the app writes to SwiftData immediately (updating the UI instantly) and then pushes the change to Firebase in the background. This "Optimistic UI" approach ensures a seamless user experience regardless of connectivity.

#### B. Integration with Third-Party APIs
Integrating external services like the **Google Gemini API** for AI chat required a strict abstraction layer to prevent "leakage" of implementation details into the UI.
*   **Strategy**: An adapter class (`AIService`) was created to wrap the RESTful API calls. This class handles authentication, JSON serialization, and error handling internally, exposing only a simple `sendMessage(_ text: String)` function to the rest of the app. This decouples the app from the specific AI provider.

    ```swift
    // Abstraction Example: AIService.swift
    func sendMessage(_ text: String) async {
        // ... logic to update UI immediately ...
        do {
            let response = try await chat.sendMessage(text)
            if let responseText = response.text {
                 // ... logic to persist response ...
            }
        } catch {
            self.error = "Failed to send message: \(error.localizedDescription)"
        }
    }
    ```
    This encapsulation ensures that the specific Gemini API endpoints and keys are hidden from the rest of the application.

#### C. Deployment Strategy
*   **Configuration**: Build schemes (Debug vs. Release) were configured in Xcode to point to different environments (Development vs. Production) to ensure that testing data does not corrupt the live analytics or databases.

### 5.2.4 Applied Design Patterns

To ensure modularity and maintainability, several standard software design patterns were employed throughout the implementation:

*   **Observer Pattern**: Leveraged extensively via SwiftUI and Combine. The ViewModels implement `ObservableObject`, and their `@Published` properties emit signals when data changes. The Views subscribe to these signals, ensuring that the UI is always a reflection of the current state without manual DOM manipulation.
*   **Facade Pattern**: The Service Layer acts as a simplified interface to complex subsystems. For example, `AIService` provides a simple `sendMessage()` facade, hiding the intricate details of the Gemini REST API, JSON parsing, and context management from the ViewModels.
*   **Repository Pattern**: Employed to abstract data persistence. The ViewModels interact with `SwiftDataService` and `UserService` as repositories, which internally manage the complexity of syncing between the local database (Device-Only) and Firestore (Cloud).
*   **Utility Pattern**: Encapsulated in the `MamaCareDateHelper`. This static utility class isolates complex date arithmetic (e.g., EDD calculations), keeping domain logic pure, testable, and separate from UI components.
*   **Singleton Pattern**: Used for stateless service access points (`EncryptionService.shared`, `UserService.shared`) to ensure a single instance manages resources like Database Connections and Keychain Access throughout the app lifecycle.

## 5.3 Review of Technologies

The selection of technologies for Mama-Care was driven by the need for high performance, native system integration, and strict security compliance. The following technologies were analyzed and selected:

### 5.3.1 Programming Languages & Frameworks

#### Swift (Language)
*   **Selection**: Swift 5+
*   **Relevance**: As the native language for iOS development, Swift offers safety features (such as Optional unwrapping and type inference) that drastically reduce runtime crashes. Its compiled nature ensures high-performance execution of cryptographic algorithms (ChaChaPoly encryption), which is computationally expensive in interpreted languages like JavaScript/React Native.
*   **Justification**: Swift's syntax is expressive and concise, and its strict memory safety (ARC) prevents common memory leaks, crucial for a long-running healthcare tracking app.

#### SwiftUI (Interface Framework)
*   **Selection**: SwiftUI (iOS 17+)
*   **Relevance**: A declarative UI framework that allows for rapid prototyping and reactive state management.
*   **Justification**: Unlike UIKit's imperative style, SwiftUI drastically reduces boilerplate code. Its seamless integration with Combine (for reactive data streams) and rigid layout system ensures that the app looks consistent across different device sizes (iPhone SE to Pro Max).

#### SwiftData (Local Persistence)
*   **Selection**: SwiftData (Core Data successor)
*   **Relevance**: Apple's modern object-relational mapping (ORM) framework.
*   **Justification**: SwiftData was chosen over raw SQLite or Realm because of its "native" feel. It allows defining data models using pure Swift `structs` and `classes` with the `@Model` macro, automatically handling relational mapping, migrations, and iCloud syncing capabilities if needed in the future.

### 5.3.2 Backend & Cloud Services

#### Google Firebase
*   **Components**: Firestore (NoSQL Database), Firebase Authentication.
*   **Strengths**: Real-time synchronization, massive scalability, and cross-platform authentication support.
*   **Weaknesses**: Vendor lock-in; however, the service abstraction layer mitigates this risk.
*   **Justification**: For a master's project with limited timeline and resources, Firebase provided a "backend-as-a-service" (BaaS) that eliminated the need to manage server infrastructure, allowing focus on client-side feature development.

#### Google Gemini API
*   **Usage**: AI Chatbot backbone.
*   **Justification**: Selected for its superior context window and natural language processing capabilities compared to smaller on-device models. It allows the "Supportive Friend" persona to maintain conversation context over a session.

### 5.3.3 Hardware Requirements

*   **Development**: MacBook Air M1 (macOS Sequoia) running Xcode 16.
*   **Testing**: Apple iPhone 13 (iOS 17) was used as the primary physical test device to validate camera usage (for QR codes) and biometric sensors (FaceID), which cannot be fully emulated in the Simulator.

### 5.4 Implementation Issues and Solutions

During the implementation phase, several significant technical challenges were encountered. This section details the investigation and algorithmic solutions applied.

### 5.4.1 Encryption and Data Privacy
*   **Description of the Issue**: Storing sensitive medical data (e.g., mood notes) and Personally Identifiable Information (PII) like names and phone numbers required strict confidentiality. Storing this data in plain text on the cloud (Firebase) would pose a significant privacy risk in the event of a server-side breach.
*   **Solution**: The system implements **Client-Side Field-Level Encryption**. This ensures that data is encrypted *on the device* before it is ever sent to the network, and can only be decrypted by the device holding the private key in its Keychain. This effectively provides **End-to-End Privacy** for storage.
    *   **Strategy**: The **Encrypted DTO (Data Transfer Object)** pattern was adopted. The app converts standard models (e.g., `User`) into encrypted transport models (e.g., `EncryptedUserFirestoreData`) where sensitive properties are replaced with opaque ciphertext (`Data`).
    
    *   **Integration Point**: `UserService` and `MoodService` handle this transformation transparently.
    ```swift
    // EncryptionService.swift (ChaChaPoly Algorithm)
    func encrypt(data: Data) -> Data? {
        do {
            let key = getSymmetricKey() // Retrieved from Secure Enclave/Keychain
            let sealedBox = try ChaChaPoly.seal(data, using: key)
            return sealedBox.combined
        } catch {
            return nil
        }
    }
    ```

### 5.4.2 Hybrid Data Synchronization (The "Two-Source" Problem)
*   **Description of the Issue**: Managing conflicts between the local cache (Device) and remote server (Cloud) created potential data integrity issues.
*   **Solution**: The logic uses a **Last-Write-Wins** strategy with client timestamps for conflict resolution, but critically treats the **Local Store as the Master for UI**.
    *   **Design Decision**: Firestore acts as a backup and synchronization endpoint, not the primary data source for the active session. When a user logs in, `UserService` pulls remote data and "upserts" it into the local SwiftData container. The UI observes *only* the local container, preventing UI flickering or race conditions.

### 5.4.3 Automatic Emergency Escalation
*   **Description of the Issue**: Requirement FR13 stated that the system should "automatically" alert contacts if the user is inactive for 48 hours. However, iOS strictly limits background execution (Sandbox) to prevent battery drain and privacy violations, preventing automated SMS sending.
*   **Solution**: This solution represents a pragmatic adaptation of the requirement to the iOS security model.
    *   **Passive Watchdog**: The `checkForMissedCheckIns()` function monitors the `lastCheckInDate` on every app launch.
    *   **Fail-Safe Journey**: precise automation was replaced with a **"Forced Escalation" Modal**. If `delta > 48h`, the app locks the dashboard behind a safety screen that requires the user to either "Confirm Safety" (Check-in) or "Request Help" (pre-filling an SOS message). This ensures that prolonged inactivity guarantees an escalation option upon the next interactions, fulfilling the safety intent within platform constraints.

### 5.4.4 Testing Hardware Features on Simulator
*   **Description of the Issue**: The iOS Simulator lacks the necessary hardware components to simulate cellular calls (`tel://`) and SMS messaging (`sms://`). This created a significant bottleneck for testing the **Emergency Contact** features during development without a dedicated physical device.
*   **Solution**: To ensure the UI remained robust during testing, a defensive coding strategy was implemented.
    *   **Capability Checks**: The app uses `UIApplication.shared.canOpenURL(...)` to verify if the device supports the specific scheme before attempting to execute it.
    *   **Defensive UI Feedback**: In the event that the capability check fails (indicating execution on a Simulator or iPad without cellular data), the app presents a specific alert: *"Feature Unavailable: Calling/Messaging is not supported on Simulator. You must use an actual iPhone."* This provides immediate feedback to the developer or tester, distinguishing between a logic failure and a hardware limitation.

## 5.5 "As-Implemented" Class Diagram

This section presents the final class structure of the Mama-Care application. While the design phase (Chapter 4) proposed a high-level abstraction, the actual implementation necessitated specific refinements to handle iOS frameworks (SwiftData, Combine) and asynchronous concurrency (Swift Concurrency).

*[Insert Final Class Diagram Here]*

*Figure 5.2: As-Implemented Class Diagram.*

**Comparison to Design:**
The final implementation reflects refinements made during the coding phase. The abstract `DataService` from the design is now realized as two distinct singleton classes: `SwiftDataService` (handling local persistence) and `UserService` (handling Firestore synchronization), complying with the Single Responsibility Principle. Additionally, the `EncryptionService` was implemented as a standalone utility used by both data services, rather than a subclass, to favor composition over inheritance. New helper structures like `MamaCareDateHelper` were introduced to encapsulate the localized pregnancy logic, keeping the ViewModels lean.

## 5.6 Overview of Key Software Components

This section details the internal logic of the system's most critical components, providing code evidence of the implementation.

*   **Component Name: MamaCareViewModel (Central Orchestrator)**
    *   **Purpose**: Acts as the central "brain" of the application, managing global state (User, Authentication) and orchestrating data flow between the UI and backend services. It implements the MVVM pattern to separate business logic from the view layer.
    *   **Data Structures**:
        *   `currentUser` (User?): The active user profile.
        *   `moodCheckIns` (Array<MoodCheckIn>): List of user's mood history.
        *   `vaccineSchedule` (Array<VaccineItem>): Calculated vaccine due dates.
    *   **Methods**:
        *   `login(email, password)`: Authenticates user via Firebase and loads profile.
        *   `checkForMissedCheckIns()`: Analyzes check-in history to trigger safety alerts.
        *   `syncData()`: Coordinates upload of local changes to the cloud.
    *   **Pseudocode of Algorithms Used**:
        **Example: Emergency Escalation Logic**
        ```text
        Function checkForMissedCheckIns():
           lastCheckIn = users.lastMoodCheckIn
           timeDifference = CurrentTime - lastCheckIn.timestamp
           
           If timeDifference > 48 Hours AND user.escalationEnabled:
               Trigger "Emergency Escalation Mode"
               Show Alert Modal to User
        ```
    *   **Examples**:
        ```swift
        // Logic to trigger escalation
        if timeSinceLastCheckIn > fortyEightHoursInSeconds {
             print("ALERT: Triggering Escalation.")
             showEmergencyEscalation = true
        }
        ```

*   **Component Name: AuthService (Authentication & Storage Manager)**
    *   **Purpose**: Manages the user's identity and governs the "Hybrid Storage" policy. It determines whether data should be synced to the Cloud or remain strictly on the device based on the user's selection during onboarding.
    *   **Data Structures**:
        *   `currentUser` (FirebaseAuth.User?): The active session token from Firebase.
        *   `storageMode` (Enum): Takes values `.deviceOnly` or `.cloud`.
    *   **Methods**:
        *   `signIn(email, password)`: Validates credentials against Firebase Auth.
        *   `signUp(email, password)`: Creates a new identity.
        *   `resolveStorageMode()`: Logic to decide where to route Save/Fetch requests.
    *   **Pseudocode of Algorithms Used**:
        **Example: Hybrid Storage Decision Logic**
        ```text
        Function saveUserData(user):
           // 1. Always save locally (Optimistic UI)
           SwiftDataService.save(user)
           
           // 2. Conditionally sync to cloud
           If user.storageMode == .cloud AND isOnline():
               EncryptedUser = EncryptionService.encrypt(user)
               Firestore.save(EncryptedUser)
           Else:
               Return "Saved Locally Only"
        ```
    *   **Examples**:
        ```swift
        // Actual Swift Implementation
        if user.storageMode == .cloud, let uid = authService.currentUser?.uid {
            userService.createUserProfile(user: user, uid: uid)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print("Failed to sync to Firebase: \(error)")
                    }
                }
        }
        ```

*   **Component Name: EncryptionService (Security Layer)**
    *   **Purpose**: Handles all cryptographic operations to ensure data privacy. It provides "Zero-Knowledge" encryption for sensitive fields before they leave the device.
    *   **Data Structures**:
        *   `keyTag` (String): Identifier for the keychain item.
        *   `SymmetricKey`: The 256-bit AES/ChaChaPoly key.
    *   **Methods**:
        *   `encrypt(data)`: Encrypts raw bytes using ChaChaPoly-1305.
        *   `decrypt(data)`: Restores original data from ciphertext.
        *   `getSymmetricKey()`: Retrieves or generates the master key from the Secure Enclave (Keychain).
    *   **Pseudocode of Algorithms Used**:
        **Example: Encryption Flow**
        ```text
        Function encrypt(plaintext):
           key = Keychain.retrieve("com.mamacare.key")
           sealedBox = ChaChaPoly.seal(plaintext, using: key)
           Return sealedBox.combinedData
        ```
    *   **Examples**:
        ```swift
        let sealedBox = try ChaChaPoly.seal(data, using: key)
        return sealedBox.combined
        ```

*   **Component Name: AIService (AI Chat Integration)**
    *   **Purpose**: Manages communication with the Google Gemini API to provide supportive chat functionality. It ensures user privacy by sanitizing input before transmission.
    *   **Data Structures**:
        *   `chatHistory` (Array<ChatMessage>): Local cache of the conversation context.
    *   **Methods**:
        *   `sendMessage(text)`: Scrubs PII and sends prompt to AI.
        *   `scrubPII(text)`: Removes emails and phone numbers from user input.
    *   **Pseudocode of Algorithms Used**:
        **Example: PII Scrubbing**
        ```text
        Function scrubPII(text):
           emailPattern = "[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}"
           phonePattern = "[0-9]{11}"
           
           scrubbedText = Regex.replace(text, emailPattern, "[REDACTED]")
           scrubbedText = Regex.replace(scrubbedText, phonePattern, "[REDACTED]")
           
           Return scrubbedText
        ```
    *   **Examples**:
        ```swift
        // Actual Swift Implementation
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        if let regex = try? NSRegularExpression(pattern: emailPattern) {
            scrubbed = regex.stringByReplacingMatches(in: scrubbed, ... withTemplate: "[EMAIL REDACTED]")
        }
        ```

*   **Component Name: NotificationService (Engagement Engine)**
    *   **Purpose**: Manages user re-engagement through local notifications. It handles the scheduling of daily mood check-in reminders and vaccine alerts, interacting directly with the iOS `UserNotifications` framework to ensure delivery even when the app is closed.
    *   **Data Structures**:
        *   `center` (UNUserNotificationCenter): The system singleton for managing alerts.
        *   `checkInTimes` (Array<Int>): Minutes from midnight representing scheduled times (e.g., 480 = 8:00 AM).
    *   **Methods**:
        *   `requestAuthorization()`: Prompts the user for permission to display alerts/badges.
        *   `scheduleMoodCheckInNotifications(times)`: Converts integer times into recurring calendar triggers.
    *   **Pseudocode of Algorithms Used**:
        **Example: Time Conversion Algorithm**
        ```text
        Function scheduleReminders(timesInMinutes):
           For time in timesInMinutes:
               hour = time / 60   // Integer division
               minute = time % 60 // Modulo
               
               trigger = Calendar(hour: hour, minute: minute, repeats: True)
               System.schedule(trigger, content: "How are you feeling?")
        ```
    *   **Examples**:
        ```swift
        let hour = minutesSinceMidnight / 60
        let minute = minutesSinceMidnight % 60
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        ```

*   **Component Name: VaccineViewModel (Health Logic)**
    *   **Purpose**: Specialized logic for the childhood immunization schedule. It determines which vaccines are overdue based on the child's specific birth date and country.
    *   **Data Structures**:
        *   `scheduledVaccines` (Array<VaccineItem>): List of all vaccines and their due dates.
    *   **Methods**:
        *   `loadVaccines()`: Parse JSON schedule (UK or Nigeria).
        *   `calculateDueDates(birthDate)`: Computes exact due dates for each vaccine.
    *   **Pseudocode of Algorithms Used**:
        **Example: Status Determination**
        ```text
        Function calculateStatus(vaccine, birthDate):
           dueDate = birthDate + vaccine.ageMonths
           If vaccine.isCompleted: Return "Completed"
           Else If CurrentDate > dueDate: Return "Overdue"
           Else: Return "Upcoming"
        ```
    *   **Examples**:
        ```swift
        if let completedDate = record.completedDate {
            return .completed(date: completedDate)
        } else if Date() > dueDate {
            return .overdue
        }
        ```

## 5.7 Conclusion

This chapter has detailed the construction of the Mama-Care application, demonstrating how the architectural patterns and algorithms from Chapter 4 were realized in production-grade Swift code. The implementation successfully resolves core challenges of data privacy (via ChaChaPoly encryption), hybrid synchronization (via the Repository pattern), and platform integration (via UserNotifications and Keychain). By prioritizing a local-first architecture, the system ensures reliability for users in low-connectivity environments while leveraging the cloud for backup and recovery. The next chapter, **Testing and Evaluation**, will validate this implementation against the functional and non-functional requirements established in Chapter 3, covering unit tests, user acceptance testing, and performance benchmarking.
