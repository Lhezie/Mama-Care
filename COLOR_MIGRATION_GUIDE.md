# Color Migration Guide

## Color Mapping Reference

Use this guide to replace all `Color(hex: "...")` with named colors from the design system.

### Find & Replace Patterns

| Hex Code | Replace With | Category |
|----------|--------------|----------|
| `Color(hex: "00BBA7")` | `.mamaCarePrimary` | Primary |
| `Color(hex: "009966")` | `.mamaCarePrimaryDark` | Primary |
| `Color(hex: "00C4B4")` | `.mamaCareTeal` | Primary |
| `Color(hex: "00A88F")` | `.mamaCareTealDark` | Primary |
| `Color(hex: "1F2937")` | `.mamaCareTextPrimary` | Text |
| `Color(hex: "6B7280")` | `.mamaCareTextSecondary` | Text |
| `Color(hex: "9CA3AF")` | `.mamaCareTextTertiary` | Text |
| `Color(hex: "4B5563")` | `.mamaCareTextDark` | Text |
| `Color(hex: "F9FAFB")` | `.mamaCareGrayLight` | Background |
| `Color(hex: "F3F4F6")` | `.mamaCareGrayMedium` | Background |
| `Color(hex: "E5E7EB")` | `.mamaCareGrayBorder` | Background |
| `Color(hex: "EC4899")` | `.mamaCarePink` | Accent |
| `Color(hex: "FCE7F3")` | `.mamaCarePinkLight` | Accent |
| `Color(hex: "8B5CF6")` | `.mamaCarePurple` | Accent |
| `Color(hex: "3B82F6")` | `.mamaCareBlue` or `.mamaCareUpcoming` | Status/Accent |
| `Color(hex: "F59E0B")` | `.mamaCareDue` | Status |
| `Color(hex: "EF4444")` | `.mamaCareOverdue` or `.mamaCareRed` | Status |
| `Color(hex: "10B981")` | `.mamaCareCompleted` | Status |
| `Color(hex: "DBEAFE")` | `.mamaCareUpcomingBg` | Status Background |
| `Color(hex: "FEF3C7")` | `.mamaCareDueBg` | Status Background |
| `Color(hex: "FEE2E2")` | `.mamaCareOverdueBg` | Status Background |
| `Color(hex: "D1FAE5")` | `.mamaCareCompletedBg` | Status Background |
| `Color(hex: "D946EF")` | `.mamaCareMagenta` | Accent |
| `Color(hex: "F97316")` | `.mamaCareOrange` | Accent |
| `Color(hex: "FEF2F2")` | `.mamaCareRedLight` | Accent |
| `Color(hex: "FFF7ED")` | `.mamaCareOrangeLight` | Accent |
| `Color(hex: "FDF4FF")` | `.mamaCarePurpleLight` | Accent |
| `Color(hex: "004D40")` | `.mamaCareDarkGreen` | Accent |

### Gradient Replacements

| Old Gradient | Replace With |
|--------------|--------------|
| `LinearGradient(gradient: Gradient(colors: [Color(hex: "00BBA7"), Color(hex: "009966")]), ...)` | `.mamaCareGradient` |
| `LinearGradient(gradient: Gradient(colors: [Color(hex: "00C4B4"), Color(hex: "00A88F")]), ...)` | `.mamaCareTealGradient` |
| `LinearGradient(gradient: Gradient(colors: [Color(hex: "3B82F6"), Color(hex: "8B5CF6")]), ...)` | `.mamaCarePurpleGradient` |

## Files to Update

### High Priority (Most Color Usage)
1. ✅ `Colors.swift` - Design system updated
2. ⏳ `EnhancedDashboardView.swift`
3. ⏳ `PostpartumCareTipView.swift`
4. ⏳ `VaccineScheduleView.swift`
5. ⏳ `NutritionView.swift`
6. ⏳ `MoodCheckInView.swift`
7. ⏳ `EmergencyView.swift`
8. ⏳ `AIChatView.swift`

### Medium Priority
9. ⏳ `SettingsView.swift`
10. ⏳ `PaywallView.swift`
11. ⏳ All onboarding views

## Benefits

✅ **Consistency**: All colors defined in one place  
✅ **Maintainability**: Change colors globally by updating Colors.swift  
✅ **Readability**: `.mamaCarePrimary` is clearer than `Color(hex: "00BBA7")`  
✅ **Type Safety**: Autocomplete helps prevent typos  
✅ **Theme Support**: Easy to add dark mode or alternative themes later

## Example Transformation

### Before:
```swift
Text("Welcome")
    .foregroundColor(Color(hex: "1F2937"))
    .background(Color(hex: "F9FAFB"))
```

### After:
```swift
Text("Welcome")
    .foregroundColor(.mamaCareTextPrimary)
    .background(.mamaCareGrayLight)
```
