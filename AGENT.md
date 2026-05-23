# AGENT.md — How to Build Pediglam

## Role & Behavior

You are a senior iOS developer building Pediglam. You write clean, production-ready Swift code using SwiftUI and EventKit. You follow the SPEC.md exactly and produce code that "just works."

## Development Rules

### DO
- Write pure Swift/SwiftUI — no UIKit unless absolutely necessary
- Use native iOS frameworks (EventKit for calendar, UserDefaults for persistence)
- Follow Apple Human Interface Guidelines
- Keep code simple and readable — no over-engineering
- Handle all edge cases gracefully (empty calendar, permission denied, etc.)
- Use SF Symbols for all icons
- Support both Light and Dark mode automatically (system colors)
- Use `@AppStorage` for simple UserDefaults-backed settings

### DON'T
- Don't use CocoaPods or SPM unless necessary (pure native = better)
- Don't write code that's not in the spec
- Don't add features not described in SPEC.md
- Don't use third-party libraries for basic things SwiftUI can handle
- Don't write "TODO" comments — implement or ask

## Project Structure

```
Pediglam/
├── project.yml              # XcodeGen configuration
├── SPEC.md                  # This spec (read before coding)
├── AGENT.md                 # This file
├── PROMPT.md                # Human-readable prompt for implementation
├── Pediglam/
│   ├── App/
│   │   └── PediglamApp.swift
│   ├── Models/
│   │   ├── CalendarEvent.swift
│   │   ├── TimeSlot.swift
│   │   └── DaySchedule.swift
│   ├── ViewModels/
│   │   └── CalendarViewModel.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── components/
│   │   │   ├── HeaderView.swift
│   │   │   ├── EventCard.swift
│   │   │   ├── FreeSlotCard.swift
│   │   │   ├── BusySlotCard.swift
│   │   │   ├── SummaryView.swift
│   │   │   └── EmptyStateView.swift
│   │   └── sheets/
│   │       ├── SettingsSheet.swift
│   │       └── EventDetailSheet.swift
│   ├── Services/
│   │   └── CalendarService.swift
│   ├── Utilities/
│   │   ├── DateExtensions.swift
│   │   └── AppColors.swift
│   ├── Resources/
│   │   └── Assets.xcassets/
│   └── Info.plist
```

## Implementation Order

### Phase 1: Project Setup
1. Create `project.yml` for XcodeGen
2. Create `Info.plist` with calendar usage descriptions
3. Create `Assets.xcassets` structure
4. Generate project: `xcodegen generate`

### Phase 2: Models
1. `CalendarEvent.swift` — wraps EKEvent, adds computed properties
2. `TimeSlot.swift` — free/busy slot model with duration
3. `DaySchedule.swift` — holds array of slots for a day

### Phase 3: Services
1. `CalendarService.swift` — EventKit wrapper:
   - Request calendar access
   - Fetch events for date range
   - Check authorization status

### Phase 4: Utilities
1. `DateExtensions.swift` — formatting helpers (time, date, duration)
2. `AppColors.swift` — color palette as Color extensions

### Phase 5: ViewModel
1. `CalendarViewModel.swift`:
   - `@Published` properties: events, freeSlots, busySlots, isLoading, error
   - `loadEvents(for:)` — fetch and process
   - `calculateFreeSlots(events:workStart:workEnd:)` — core algorithm
   - `calculateSummary()` — total free/busy time

### Phase 6: UI Components
Build in this order:
1. `AppColors.swift` — reference all colors
2. `HeaderView.swift`
3. `EventCard.swift` (base)
4. `FreeSlotCard.swift` (extends EventCard styling)
5. `BusySlotCard.swift` (extends EventCard styling)
6. `SummaryView.swift`
7. `EmptyStateView.swift`
8. `SettingsSheet.swift`
9. `EventDetailSheet.swift`

### Phase 7: Main Views
1. `ContentView.swift` — main screen with all components composed
2. `PediglamApp.swift` — @main entry point

### Phase 8: Build & Verify
1. Generate project: `xcodegen generate`
2. Build with xcodebuild (or open in Xcode and build)
3. Fix any compilation errors
4. Test on simulator

## Coding Standards

### Naming
- Swift conventions: `camelCase` for everything
- Files: `PascalCase.swift`
- Models: no suffix or `Model` suffix
- Views: `View` suffix
- ViewModels: `ViewModel` suffix
- Services: `Service` suffix

### SwiftUI Best Practices
- Use `struct` for Views (not classes)
- Use `@StateObject` or `@State` for local state
- Use `@ObservableObject` + `@Published` for ViewModels
- Use `@AppStorage` for UserDefaults-backed settings
- Use `some View` return types
- Avoid `AnyView` — use generic views

### Error Handling
- Use `Result` type for service methods
- Show user-friendly error messages
- Never crash on errors — show empty state or retry option

## Verification Checklist

Before calling "done", verify:
- [ ] App builds without errors
- [ ] Calendar permission is requested on first launch
- [ ] Today's events are displayed correctly
- [ ] Free slots are calculated correctly (check edge cases)
- [ ] Settings (work hours) are persisted
- [ ] Empty states show appropriate messages
- [ ] Dark mode works
- [ ] Pull to refresh works
- [ ] Event detail sheet shows on tap
- [ ] All SF Symbols load correctly

## Commands

```bash
# Generate Xcode project
xcodegen generate

# Build
xcodebuild -project Pediglam.xcodeproj -scheme Pediglam -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16' build

# Or open in Xcode
open Pediglam.xcodeproj
```
