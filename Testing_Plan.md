# MamaCare Testing Plan & Checklist

**Project**: MamaCare - Pregnancy & Child Health Companion (iOS)  
**Platform**: iOS 17+  
**Target Users**: Pregnant women and mothers with children (UK & Nigeria)  
**Date**: November 2025

---

## Testing Objectives

1. Ensure core features work correctly for both user types (pregnant vs has child)
2. Validate country-specific data (UK & Nigeria)
3. Verify offline-first functionality
4. Confirm privacy and security measures
5. Test subscription and payment flows
6. Ensure accessibility compliance

---

## 1. Unit Testing (Code-level)

### Data Models & JSON Parsing
- [ ] Vaccine schedule loads correctly from `uk_vaccination_schedule.json`
- [ ] Vaccine schedule loads correctly from `ng_vaccination_schedule.json`
- [ ] Nutrition data loads from `nutrition_data.json`
- [ ] Postpartum motivation loads from `postpartum_motivation.json`
- [ ] Handles missing/corrupted JSON files gracefully

### Business Logic
- [ ] Country normalization: "NG" and "Nigeria" both work
- [ ] Country normalization: "UK", "United Kingdom", "GB" all work
- [ ] Pregnancy week calculation from EDD is accurate
- [ ] Postpartum day calculation from birth date is accurate
- [ ] Vaccine due date calculation based on birth date/EDD
- [ ] Vaccine status determination (upcoming, due, overdue, completed)
- [ ] Mood check-in scheduling (08:00, 14:00, 20:00)

### Encryption & Security
- [ ] Data encryption with AES-256-GCM works
- [ ] Encryption key stored securely in Keychain
- [ ] Decryption retrieves correct data
- [ ] iCloud Keychain sync (if enabled)

### Pricing Logic
- [ ] UK users see £4 pricing
- [ ] Nigerian users see ₦8,000 pricing
- [ ] Handles country code variations correctly

---

## 2. Integration Testing

### User Flows
- [ ] **Onboarding → Storage**: Account creation → data encrypted → stored locally
- [ ] **Country Selection → Content**: Select Nigeria → Nigerian vaccines load
- [ ] **EDD Entry → Vaccines**: Enter EDD → infant vaccines calculated
- [ ] **Birth Date → Vaccines**: Enter birth date → vaccines calculated from birth
- [ ] **Mood Check-in → Escalation**: "Not Good" → emergency escalation option
- [ ] **Subscription → Access**: Purchase → premium features unlocked

### Data Persistence
- [ ] User data persists after app restart
- [ ] Settings persist after app restart
- [ ] Mood check-in history saved correctly
- [ ] Vaccine completion status saved
- [ ] Emergency contacts stored encrypted

---

## 3. Manual UI/UX Testing

### Onboarding Flow
- [ ] Sign up with valid email and password
- [ ] Sign up validation: invalid email rejected
- [ ] Sign up validation: weak password rejected
- [ ] Sign up validation: password mismatch detected
- [ ] Country selection dropdown works (UK & Nigeria)
- [ ] User type selection: "I am pregnant"
- [ ] User type selection: "I have a child"
- [ ] EDD date picker (for pregnant users)
- [ ] Birth date picker (for users with child)
- [ ] Emergency contact: add, edit, delete
- [ ] Storage mode selection (Device-only vs iCloud)
- [ ] Privacy policy and T&Cs acceptance

### Dashboard & Navigation
- [ ] Dashboard loads with correct user greeting
- [ ] Pregnancy progress card shows correct week (pregnant users)
- [ ] Quick Actions: "Mood Check-In" navigates to Tab 1
- [ ] Quick Actions: "Vaccines" navigates to Tab 3
- [ ] Quick Actions: "Emergency" navigates to Tab 4
- [ ] Quick Actions: "AI Chat" navigates to Tab 5
- [ ] Tab bar navigation works smoothly
- [ ] Back navigation works correctly

### Content Display (Pregnant Users)
- [ ] Nutrition tab shows correct week content
- [ ] Nutrition content updates as pregnancy progresses
- [ ] Vaccine schedule based on EDD
- [ ] Vaccine schedule shows infant vaccines only (not adolescent)
- [ ] Pregnancy week calculation is accurate

### Content Display (Users with Child)
- [ ] Post Care tab shows correct postpartum day content
- [ ] Postpartum tips update daily
- [ ] Vaccine schedule based on birth date
- [ ] Vaccine schedule shows all applicable vaccines
- [ ] Days since birth calculation is accurate

### Vaccination Schedule
- [ ] UK users see UK vaccination schedule
- [ ] Nigerian users see Nigerian vaccination schedule
- [ ] Vaccines show correct status: Upcoming (gray)
- [ ] Vaccines show correct status: Due (yellow/orange)
- [ ] Vaccines show correct status: Overdue (red)
- [ ] Vaccines show correct status: Completed (green)
- [ ] Cannot mark "Upcoming" vaccine as completed
- [ ] Can mark "Due" or "Overdue" vaccine as completed
- [ ] Vaccine details display correctly (name, age range, description)
- [ ] Due dates calculated correctly

### Mood Check-ins
- [ ] Mood check-in view accessible from Quick Actions
- [ ] Three options: Good, Okay, Not Good
- [ ] "Good" response shows motivational message
- [ ] "Okay" response shows supportive tips
- [ ] "Not Good" response offers escalation (if subscribed)
- [ ] "Not Good" response shows paywall (if not subscribed)
- [ ] Mood history saved and viewable
- [ ] Timestamps recorded correctly

### Emergency Features
- [ ] Emergency contact list displays
- [ ] Add emergency contact works
- [ ] Edit emergency contact works
- [ ] Delete emergency contact works
- [ ] Emergency escalation (subscribed): opens SMS/Email composer
- [ ] Emergency escalation (not subscribed): shows paywall
- [ ] Prefilled message includes user info
- [ ] User must press "Send" (not automatic)

### AI Chat
- [ ] AI chat accessible from Quick Actions
- [ ] Disclaimer shown on first use
- [ ] Can send messages
- [ ] Messages stored locally
- [ ] Can delete chat history
- [ ] Chat history persists after app restart

### Subscription & Paywall
- [ ] Paywall appears when accessing premium features
- [ ] Correct pricing displayed: £4 for UK users
- [ ] Correct pricing displayed: ₦8,000 for Nigerian users
- [ ] Purchase flow works (use Sandbox testing)
- [ ] Restore purchases works
- [ ] Subscription status persists
- [ ] Premium features unlocked after purchase

### Settings
- [ ] Edit profile: name, country
- [ ] Edit user type (pregnant ↔ has child)
- [ ] Edit EDD (pregnant users)
- [ ] Edit birth date (users with child)
- [ ] Edit mood check-in times
- [ ] Enable/disable notifications
- [ ] Switch storage mode (Device ↔ iCloud)
- [ ] Export data (if implemented)
- [ ] Delete all data works
- [ ] Sign out works

---

## 4. Device & OS Testing

### Device Coverage
- [ ] iPhone 12 (6.1" display)
- [ ] iPhone 13 Pro (6.1" display)
- [ ] iPhone 14 Plus (6.7" display)
- [ ] iPhone 15 (6.1" display)
- [ ] iPad (if supporting tablets)

### iOS Versions
- [ ] iOS 17.0
- [ ] iOS 17.5
- [ ] Latest iOS 17.x

### Display Modes
- [ ] Light mode appearance
- [ ] Dark mode appearance
- [ ] Portrait orientation
- [ ] Landscape orientation (if supported)

### Accessibility
- [ ] Dynamic Type: smallest text size
- [ ] Dynamic Type: largest text size
- [ ] VoiceOver: all elements labeled
- [ ] VoiceOver: navigation works
- [ ] Color contrast meets WCAG AA
- [ ] Touch targets ≥ 44x44 points

---

## 5. Offline Testing (Critical!)

### Core Functionality
- [ ] Install app with no internet connection
- [ ] Create account offline
- [ ] View vaccination schedule offline
- [ ] View nutrition/postpartum content offline
- [ ] Add mood check-in offline
- [ ] Add emergency contact offline
- [ ] AI chat works offline (if local model)

### Sync Behavior
- [ ] Data syncs when internet restored (iCloud enabled)
- [ ] Conflicts resolved correctly
- [ ] No data loss during sync

### Airplane Mode Testing
- [ ] Enable airplane mode
- [ ] Use all core features
- [ ] Disable airplane mode
- [ ] Verify sync (if iCloud enabled)

---

## 6. Notification Testing

### Mood Check-in Notifications
- [ ] Notification at 08:00 (default)
- [ ] Notification at 14:00 (default)
- [ ] Notification at 20:00 (default)
- [ ] Custom times work (if user changes)
- [ ] Notifications respect system permissions
- [ ] Tapping notification opens mood check-in

### Vaccine Reminders
- [ ] Notification 24 hours before due date
- [ ] Notification content is clear
- [ ] Tapping notification opens vaccine schedule
- [ ] Reminders stop after vaccine marked complete

### Permission Handling
- [ ] App requests notification permission
- [ ] Graceful handling if permission denied
- [ ] Settings link if notifications disabled

---

## 7. Security & Privacy Testing

### Data Encryption
- [ ] User data encrypted at rest (verify with file inspector)
- [ ] Encryption key in Keychain (not in UserDefaults)
- [ ] Emergency contacts encrypted
- [ ] Mood check-in data encrypted
- [ ] Chat messages encrypted

### Privacy Compliance
- [ ] No data sent to external servers (use network monitor)
- [ ] No analytics/tracking without consent
- [ ] Emergency escalation uses local composer only
- [ ] AI chat disclaimer clear
- [ ] Privacy policy accessible

### Data Deletion
- [ ] Delete all data removes everything
- [ ] Encryption key removed from Keychain
- [ ] iCloud data deleted (if sync enabled)
- [ ] No residual data in app container

---

## 8. Edge Cases & Error Handling

### Invalid Data Entry
- [ ] EDD in the past (show error)
- [ ] EDD more than 280 days in future (show warning)
- [ ] Birth date in the future (show error)
- [ ] Birth date more than 1 year ago (show warning)
- [ ] Invalid email format
- [ ] Password too short
- [ ] Empty required fields

### Data Corruption
- [ ] Corrupted JSON file (show error, don't crash)
- [ ] Missing JSON file (show error, don't crash)
- [ ] Invalid date formats
- [ ] Missing user profile data

### User Scenarios
- [ ] User changes from pregnant → has child (after birth)
- [ ] User changes country (UK → Nigeria)
- [ ] User updates EDD (recalculates vaccines)
- [ ] User updates birth date (recalculates vaccines)
- [ ] User deletes emergency contact while escalating
- [ ] Multiple users on same device (if supported)

### Network Errors
- [ ] Purchase fails (network error)
- [ ] Restore purchases fails
- [ ] iCloud sync fails
- [ ] Graceful error messages

---

## 9. Performance Testing

### Metrics (Requirements from MamaCareBreakdown)
- [ ] App launch time < 2 seconds (A13 chip or later)
- [ ] Smooth scrolling (60fps minimum)
- [ ] JSON loading < 500ms
- [ ] Encryption/decryption < 100ms
- [ ] View transitions smooth

### Tools
- Xcode Instruments: Time Profiler
- Xcode Instruments: Allocations
- Xcode Instruments: Energy Log

### Benchmarks
- [ ] Memory usage < 100MB (typical)
- [ ] No memory leaks
- [ ] Battery drain acceptable (< 5% per hour active use)
- [ ] No CPU spikes during idle

---

## 10. User Acceptance Testing (UAT)

### Participant Recruitment
- **Target**: 5-10 pregnant women or new mothers
- **Mix**: 50% UK, 50% Nigeria (if possible)
- **Mix**: 50% pregnant, 50% with child

### Test Scenarios

#### Scenario 1: New User Onboarding
**Task**: "Set up your account as a pregnant woman due in 3 months"
- Observe: Where do they hesitate? What's confusing?
- Time: Should complete in < 5 minutes

#### Scenario 2: Daily Use
**Task**: "Check today's nutrition tip and complete a mood check-in"
- Observe: Can they find features easily?
- Time: Should complete in < 2 minutes

#### Scenario 3: Vaccination Planning
**Task**: "View your baby's vaccination schedule and mark one as completed"
- Observe: Do they understand the schedule? Status colors?
- Time: Should complete in < 3 minutes

#### Scenario 4: Emergency Access
**Task**: "Add an emergency contact and try to send an alert"
- Observe: Is the flow clear? Do they understand subscription requirement?
- Time: Should complete in < 4 minutes

### Feedback Questions
1. What did you like most about the app?
2. What was confusing or frustrating?
3. Would you use this app daily? Why or why not?
4. Is the vaccination information clear and trustworthy?
5. What features are missing that you'd want?
6. On a scale of 1-10, how likely are you to recommend this app?

### Success Criteria
- ✅ 80% complete onboarding without help
- ✅ 90% can navigate to key features
- ✅ 70% understand vaccination schedule
- ✅ Average rating ≥ 7/10

---

## 11. App Store Compliance Testing

### Pre-submission Checklist
- [ ] No crashes in any tested scenario
- [ ] Privacy policy included and accessible
- [ ] Medical disclaimer clear and prominent
- [ ] Subscription terms clear
- [ ] Age rating appropriate (likely 12+)
- [ ] App description accurate
- [ ] Screenshots representative
- [ ] Keywords relevant

### Health App Specific
- [ ] Clear that app is NOT medical advice
- [ ] Emergency features work reliably
- [ ] Vaccination data sources cited
- [ ] No false medical claims

---

## Testing Priority & Timeline

### **Phase 1: Critical (Week 1-2)** - MVP Must-Have
- ✅ Manual testing of all core flows
- ✅ Country-specific data validation (UK & Nigeria)
- ✅ Offline functionality testing
- ✅ Subscription flow (Sandbox)
- ✅ Device compatibility (3-4 devices)

### **Phase 2: Important (Week 3-4)** - Pre-launch
- ✅ Unit tests for critical logic
- ✅ Performance testing
- ✅ Accessibility testing
- ✅ Edge cases & error handling
- ✅ Security audit

### **Phase 3: Validation (Week 5-6)** - User Feedback
- ✅ User acceptance testing (5-10 users)
- ✅ Beta testing (TestFlight)
- ✅ Bug fixes from feedback
- ✅ Final App Store prep

---

## Bug Tracking

### Severity Levels
- **Critical**: App crashes, data loss, security breach
- **High**: Core feature doesn't work, major UX issue
- **Medium**: Minor feature issue, cosmetic bug
- **Low**: Nice-to-have, future enhancement

### Bug Report Template
```
Title: [Brief description]
Severity: [Critical/High/Medium/Low]
Steps to Reproduce:
1. 
2. 
3. 
Expected Result: 
Actual Result: 
Device: [iPhone model, iOS version]
Screenshots: [If applicable]
```

---

## Test Environment Setup

### Required Accounts
- [ ] Apple Developer account (for TestFlight)
- [ ] Sandbox tester accounts (for IAP testing)
- [ ] Test iCloud account
- [ ] Test user profiles (pregnant & has child)

### Test Data
- [ ] UK user profile (pregnant, EDD in 3 months)
- [ ] UK user profile (has child, born 2 months ago)
- [ ] Nigerian user profile (pregnant, EDD in 5 months)
- [ ] Nigerian user profile (has child, born 6 months ago)

---

## Sign-off

### Testing Complete When:
- [ ] All critical tests pass
- [ ] No critical or high severity bugs
- [ ] UAT feedback incorporated
- [ ] Performance benchmarks met
- [ ] Accessibility compliance verified
- [ ] App Store guidelines met

**Tested by**: _________________  
**Date**: _________________  
**Supervisor Approval**: _________________  
**Date**: _________________

---

## Notes & Observations

[Space for additional notes during testing]

