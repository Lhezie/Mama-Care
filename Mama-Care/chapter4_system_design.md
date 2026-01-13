# Chapter 4: System Design

## 4.1 Introduction
This chapter describes the design of the Mama-Care system, expanding on the functional requirements captured during the requirements analysis phase. Building upon the UML Use Case diagrams presented earlier, this section develops detailed Use Case descriptions, architectural patterns, and data structures. The design prioritizes modularity (NFR7), offline-first reliability, and end-to-end encryption to ensure a privacy-preserving experience for expectant and new mothers. Additional design components such as local-first SwiftData structures, Firebase synchronization logic, and algorithmic designs for emergency escalation and vaccination schedules are detailed herein.

## 4.2 Use Case Diagram
The following UML Use Case diagram provides a high-level overview of the system's functional boundaries and actor interactions. 

![Use Case Diagram](file:///Users/udodirim/.gemini/antigravity/brain/903c498c-da8e-4857-9971-25e74924fad8/use_case_diagram.puml)

*Figure 4.1: Mama-Care System Use Case Diagram.*

---

## 4.3 Use Case Descriptions

## 4.3 Use Case Descriptions

### 4.3.1 UC01: Signup/Onboarding

| ITEM | VALUE |
| :--- | :--- |
| **UseCase** | Signup/Onboarding |
| **Summary** | Guides new users through first-time setup including privacy consent, profile creation, and preference configuration. |
| **Actor** | User (Pregnant Mother or Mother with Child) |
| **Precondition** | The user has installed the MamaCare application and launches it for the first time. |
| **Postcondition** | A user profile is created and stored. The user is authenticated and can access personalised content. |
| **Base Sequence** | 1. The system displays an onboarding welcome screen with a privacy statement and requests consent.<br>2. The user grants consent and proceeds.<br>3. The system presents a form requesting: name, country (UK/Nigeria), user type (Pregnant/Mother with Child), storage preference (Device-only/Cloud), key date (EDD or child's date of birth), and emergency contact details.<br>4. The user enters valid information and submits the form.<br>5. The system validates inputs, creates a user profile with a unique identifier, and persists it according to the selected storage preference.<br>6. The system navigates to the main dashboard. |
| **Branch Sequence** | 4a. The user selects an invalid date (e.g., in the future for a child's birth date).<br>4a1. The system displays an error message and requests correction.<br>5a. Network is unavailable and Cloud storage was selected.<br>5a1. The system informs the user that Cloud mode requires initial connectivity and offers to continue in Device-only mode. |
| **Exception Sequence** | Invalid inputs show an inline error and require correction. |
| **Sub UseCase** | Includes Consent and Select User Type sub-flows. |
| **Note** | This is the gateway to the application's personalized experience. |

### 4.3.2 UC02: Sign In

| ITEM | VALUE |
| :--- | :--- |
| **UseCase** | Sign In |
| **Summary** | Allows returning users to authenticate and access their existing profile and data. |
| **Actor** | User (Authenticated/Registered) |
| **Precondition** | User has an existing account and is on the Login screen. |
| **Postcondition** | User is authenticated and data is synchronized (if in Cloud mode). |
| **Base Sequence** | 1. The system displays the login screen.<br>2. User enters credentials (Email/Password or biometric).<br>3. System validates credentials against local vault or Firebase Auth.<br>4. System retrieves user's encryption key from Keychain.<br>5. System navigates to the dashboard. |
| **Branch Sequence** | 2a. User forgets password.<br>2a1. User triggers password reset flow.<br>3a. Network unavailable for Cloud user.<br>3a1. System attempts offline login using cached credentials. |
| **Exception Sequence** | Incorrect credentials trigger an error message; account lockout after multiple failures. |
| **Sub UseCase** | - |
| **Note** | Critical for multi-device synchronization. |

### 4.3.3 UC03: Perform Mood Check-In

| ITEM | VALUE |
| :--- | :--- |
| **UseCase** | Perform Mood Check-In |
| **Summary** | Captures the user's emotional state to monitor mental health and trigger support. |
| **Actor** | User |
| **Precondition** | User is logged in and on the Dashboard or responds to a notification. |
| **Postcondition** | Mood entry is encrypted and stored; Safety Watchdog timer is reset. |
| **Base Sequence** | 1. User selects "Log Mood".<br>2. System displays mood options (Good, Okay, Not Good).<br>3. User selects a mood and optionally enters notes.<br>4. System encrypts the data and saves it to the selected storage (SwiftData/Firebase).<br>5. System provides immediate positive feedback or tips. |
| **Branch Sequence** | 3a. User selects "Not Good".<br>3a1. System triggers the Safety Loop, offering AI Chat or Emergency SOS contacts. |
| **Exception Sequence** | Storage failure alerts the user to retry. |
| **Sub UseCase** | Includes Safety Loop (UC09) if mood is low. |
| **Note** | Core feature for tracking PND/PPA risks. |

### 4.3.4 UC04: Receive Notification

| ITEM | VALUE |
| :--- | :--- |
| **UseCase** | Receive Notification |
| **Summary** | System reminds the user of scheduled tasks like mood check-ins or upcoming vaccinations. |
| **Actor** | System (Timer/Event Tracker) |
| **Precondition** | Notification permissions granted; events scheduled. |
| **Postcondition** | User is prompted to take action; engagement is tracked. |
| **Base Sequence** | 1. Background task identifies a due event (e.g., 24h since last check-in).<br>2. System schedules a local notification.<br>3. User receives the alert and taps it.<br>4. System opens the relevant view (Mood Logger or Vaccine Schedule). |
| **Branch Sequence** | 3a. User dismisses notification.<br>3a1. System logs the dismissal and reschedules according to logic. |
| **Exception Sequence** | Disabled notifications prevent the alert; fallback to in-app banners. |
| **Sub UseCase** | - |
| **Note** | Essential for the Safety Watchdog algorithm. |

### 4.3.5 UC05: Chat with AI (Supportive Chat)

| ITEM | VALUE |
| :--- | :--- |
| **UseCase** | Chat with AI |
| **Summary** | Provides the user with an interactive, AI-driven emotional support experience. |
| **Actor** | User |
| **Precondition** | User has accepted AI Consent; internet connection available. |
| **Postcondition** | Chat history is updated; user receives supportive guidance. |
| **Base Sequence** | 1. User opens "AI Support".<br>2. User types a query regarding their emotional health.<br>3. System scrubs PII and sends query to Gemini API wrapper.<br>4. System receives and displays the response with a medical disclaimer.<br>5. System stores the session locally (encrypted). |
| **Branch Sequence** | 3a. Network unavailable.<br>3a1. System informs user that AI requires connectivity. |
| **Exception Sequence** | API errors result in a "Try again later" message. |
| **Sub UseCase** | Includes Consent flow. |
| **Note** | AI is trained to prioritize empathy and safety over medical diagnosis. |

### 4.3.6 UC06: View & Track Vaccinations

| ITEM | VALUE |
| :--- | :--- |
| **UseCase** | Track Vaccinations |
| **Summary** | Displays the projected vaccination schedule and allows recording completion. |
| **Actor** | User |
| **Precondition** | Child's birth date or EDD is set in the profile. |
| **Postcondition** | Vaccine status is updated; Digital Vaccine Card reflects changes. |
| **Base Sequence** | 1. User navigates to "Vaccine Schedule".<br>2. System calculates target dates based on localized schedules (UK/Nigeria).<br>3. System displays categorized lists (Due, Completed, Upcoming).<br>4. User marks a vaccine as "Done".<br>5. System records timestamp and updates the UI. |
| **Branch Sequence** | 4a. User attempts to mark a future vaccine.<br>4a1. System restricts action and shows "Too early" message. |
| **Exception Sequence** | Missing birth/EDD data prompts user to complete profile. |
| **Sub UseCase** | - |
| **Note** | Driving factor for the QR export feature. |

### 4.3.7 UC07: Track Pregnancy/Postpartum Status

| ITEM | VALUE |
| :--- | :--- |
| **UseCase** | Track Pregnancy/Postpartum Status |
| **Summary** | Provides dynamic dashboard content and tips based on the user's current stage. |
| **Actor** | User |
| **Precondition** | Valid EDD or Birth Date provided during onboarding. |
| **Postcondition** | User sees relevant clinical info, nutrition tips, and recovery guides. |
| **Base Sequence** | 1. User opens the Dashboard.<br>2. System calculates Pregnancy Week or Postpartum Day.<br>3. System fetches content from localized JSON datasets.<br>4. System displays adaptive UI (e.g., "Week 24: Baby's Growth"). |
| **Branch Sequence** | 2a. User updates their key date in settings.<br>2a1. System recalculates and refreshes content. |
| **Exception Sequence** | Corrupt date data defaults the view to a general help screen. |
| **Sub UseCase** | - |
| **Note** | Uses the clinical 280-day convention for pregnancy. |

### 4.3.8 UC08: Export Data (QR/Digital Card)

| ITEM | VALUE |
| :--- | :--- |
| **UseCase** | Export Data / Digital Vaccine Card |
| **Summary** | Generates a portable, human-readable record of vaccinations via QR code. |
| **Actor** | User, Healthcare Provider |
| **Precondition** | User has recorded at least one vaccine or has relevant health data. |
| **Postcondition** | QR code is displayed for scanning by 3rd party devices. |
| **Base Sequence** | 1. User selects "Export Records".<br>2. System serializes PII (sanitized) and vaccine completion data.<br>3. System generates a high-density QR code locally.<br>4. User presents the screen to a provider.<br>5. Provider scans the code to view plaintext records. |
| **Branch Sequence** | 3a. No data to export.<br>3a1. System shows "No records found" screen. |
| **Exception Sequence** | QR generation failure displays a manual text summary instead. |
| **Sub UseCase** | - |
| **Note** | Designed for offline interaction with healthcare providers. |

### 4.3.9 UC09: Perform Emergency Escalation

| ITEM | VALUE |
| :--- | :--- |
| **UseCase** | Perform Emergency Escalation |
| **Summary** | Provides rapid access to pre-configured emergency contacts during a crisis. |
| **Actor** | User, Emergency Contact |
| **Precondition** | Emergency contacts configured during onboarding. |
| **Postcondition** | Communication is initiated; event is logged. |
| **Base Sequence** | 1. User triggers SOS (via button or Safety Loop).<br>2. System displays emergency contact list.<br>3. User taps a contact.<br>4. System launches native phone/SMS composer.<br>5. User completes the call/message. |
| **Branch Sequence** | - |
| **Exception Sequence** | Empty contact list redirects user to the settings screen. |
| **Sub UseCase** | Triggered by Safety Loop (UC03). |
| **Note** | High-priority safety feature for mental health crisis management. |

### 4.3.10 UC10: Calming Audio Support

| ITEM | VALUE |
| :--- | :--- |
| **UseCase** | Calming Audio Support |
| **Summary** | Provides users with therapeutic audio tracks (nature sounds, white noise) to aid relaxation and stress reduction. |
| **Actor** | User |
| **Precondition** | User is on the Dashboard or in the Supportive Tips view. |
| **Postcondition** | Audio is played through the device; user achieves temporary relaxation. |
| **Base Sequence** | 1. User selects "Calming Audio".<br>2. System displays a list of available tracks (local and online).<br>3. User selects a track.<br>4. System initializes `AudioPlayerManager` and begins streaming/playing the audio.<br>5. User can play, pause, or switch tracks. |
| **Branch Sequence** | 2a. System detects offline status.<br>2a1. System filters list to show only bundled local tracks.<br>3a. User closes the view.<br>3a1. System terminates the audio playback session. |
| **Exception Sequence** | API failure for online tracks triggers a "Fallback to local sounds" alert. |
| **Sub UseCase** | - |
| **Note** | Part of the therapeutic toolkit for PND/PPA mitigation. |

---

## 4.4 System Architecture
Mama-Care follows a modular **MVVM-S (Model-View-ViewModel-Service)** architecture. This ensures a strict separation of concerns (NFR7):
- **Models**: Defines encrypted data structures for Profiles, Moods, and Vaccines.
- **Views**: SwiftUI-based declarative UI that remains logic-free.
- **ViewModels**: Orchestrates business logic and maintains state for the Views.
- **Services**: Standalone modules for specialized tasks (QR Generation, AI, Encryption, Notification Scheduling).

## 4.5 Data Design & Security
Data is stored using a local-first approach. For **Device-Only** users, SwiftData manages an encrypted SQL database on-device. For **Cloud** users, Firestore serves as a synchronized mirror. 
- **Encryption**: All personally identifiable information (PII) is encrypted using **AES-256-GCM** before persistence. The encryption key is securely stored in the iOS **Keychain**.

## 4.6 Algorithmic Designs

### 1. Pregnancy & Vaccination Projection
Uses the `MamaCareDateHelper` to project NHS/Nigerian vaccine schedules relative to the Expected Delivery Date (EDD) or Child's Birth Date.

**Pregnancy Week Algorithm:**
The system uses the 280-day (40-week) clinical convention from the EDD.
- $GestationDays = 280 - (EDD - CurrentDate)$
- $PregnancyWeek = (GestationDays / 7) + 1$
This ensures that the user is always presented with a week-number within the [1, 40] range, driving the adaptive content delivery.

**Postpartum Age Algorithm:**
For users who have already given birth, the system calculates the child's age to drive the vaccination and postpartum recovery logic.
- $DaysPostpartum = CurrentDate - BirthDate$
- $PostpartumWeek = (DaysPostpartum / 7) + 1$
The system uses 1-based indexing where the day of birth is mathematically treated as Day 1 of Week 1.

**Vaccine Target Date Logic:**
It performs a chronological mapping of vaccine IDs to specific "target dates" and evaluates the current state (Upcoming, Due, Overdue, or Completed) by comparing `Date()` against the calculated threshold.

### 2. The Safety Watchdog (Missed Check-In Alert)
A background monitoring algorithm that evaluates user safety based on interaction frequency. It calculates the delta between the current time and the `lastMoodTimestamp`.
- **Threshold 1 (24h)**: Triggers a "soft" push notification.
- **Threshold 2 (48h)**: Triggers a "critical" state, prompting the UI to display the Emergency SOS selection screen immediately upon app launch.

### 3. Privacy-Preserving QR Data Formatting
This algorithm converts complex, encrypted database records into a human-readable, plaintext report on-the-fly. It sanitizes sensitive PII, extracts the latest vaccination completion dates, and formats them into a standardized text block. This allows non-digital healthcare providers to read the record via a standard QR scanner without needing specialized decoding software or cloud access.

### 4. Hybrid Storage Selection Logic
Determines data residency based on the `StorageMode` enum selected during onboarding.
- **If Device-Only**: Logic routes all `CRUD` operations to the `SwiftDataService` using local encryption.
- **If Cloud**: Logic performs a "dual-write" or "sync-through" operation, ensuring local availability for offline use while maintaining a persistent mirror in Firebase Firestore.

### 5. Adaptive Content Delivery Logic
A dynamic routing algorithm that selects the appropriate dashboard and educational content (Nutrition vs. Postpartum) based on the `UserType` and the age of the child/pregnancy. It calculates the `PregnancyWeek` (if EDD exists) or `PostpartumDay` (if Birth Date exists) to index into the localized JSON content datasets.

### 6. Localized Encryption Logic (AES-GCM)
This algorithm manages the privacy threshold of the system.
- **Key Generation**: Uses `CryptoKit` to generate a 256-bit symmetric key.
- **Sealing Process**: Uses `ChaChaPoly` (an IETF variant of AES-GCM) to seal data blobs.
- **Persistence**: Encapsulates the ciphertext, nonce, and tag into a single `Data` object for storage, ensuring that data is undecipherable even if the physical device storage is compromised.

### 7. AI Support Safeguarding Logic
An algorithmic pre-processor for AI interactions.
- **PII Scrubbing**: Before transmission to the Gemini API, the system scrubs localized context (like exact names or contact history).
- **Context Injection**: Injects a system-level directive (System Prompt) that forces the AI to append a medical disclaimer and prioritize emotional support over diagnostic advice.

