# PROMPT.md — Build Pediglam

## Task

Build **Pediglam** — a native iOS app that reads from the iOS calendar and shows today's appointments alongside free time slots. The app helps freelancers, consultants, and small business owners quickly see when they have availability to fit in more clients.

---

## Background

The user is a freelancer/business owner who:
- Uses the native iOS Calendar to book clients
- Has set business hours (e.g., 9:00 AM – 7:00 PM)
- Wants to instantly see free gaps in their day
- Needs to know if they can squeeze in another appointment

---

## Core Requirements

### 1. Calendar Access
- Use EventKit to request access to the user's calendars
- Read all events for the selected date
- Handle all authorization states (authorized, denied, not determined)
- Include proper `NSCalendarsUsageDescription` in Info.plist

### 2. Display Today's Schedule
- Show all calendar events for today
- Each event shows:
  - Time range (e.g., "09:00 – 10:30")
  - Event title (client name)
  - Duration
- Events sorted chronologically

### 3. Calculate Free Slots
- Given work hours (default 9:00–19:00), calculate gaps between events
- A "free slot" is any time between the end of one event and the start of the next
- Include the gap from work start to first event
- Include the gap from last event to work end
- Show total free time for the day

### 4. Visual Design
- **Busy slots**: Red accent color, person icon, event title
- **Free slots**: Green accent color, clock icon, duration prominently shown
- **Summary section**: Total free time vs busy time at the bottom
- Clean, minimal Apple-like design
- Support Dark Mode automatically

### 5. Settings
- Configurable work hours (start and end time)
- Settings persisted in UserDefaults

---

## Technical Specification

### Stack
- **Language:** Swift 5.9+
- **UI:** SwiftUI (pure)
- **Framework:** EventKit
- **Build Tool:** XcodeGen
- **Minimum iOS:** 16.0
- **No external dependencies**

### Project Location
```
/Users/emgie/Desktop/My/Pediglam/
```

### Files to Create

1. `project.yml` — XcodeGen configuration
2. `Info.plist` — with calendar usage descriptions
3. `App/PediglamApp.swift` — @main entry point
4. `Models/CalendarEvent.swift` — EKEvent wrapper
5. `Models/TimeSlot.swift` — free/busy slot model
6. `Models/DaySchedule.swift` — day aggregation
7. `ViewModels/CalendarViewModel.swift` — main business logic
8. `Services/CalendarService.swift` — EventKit wrapper
9. `Utilities/DateExtensions.swift` — date formatting helpers
10. `Utilities/AppColors.swift` — color palette
11. `Views/ContentView.swift` — main screen
12. `Views/components/HeaderView.swift`
13. `Views/components/EventCard.swift`
14. `Views/components/FreeSlotCard.swift`
15. `Views/components/BusySlotCard.swift`
16. `Views/components/SummaryView.swift`
17. `Views/components/EmptyStateView.swift`
18. `Views/sheets/SettingsSheet.swift`
19. `Views/sheets/EventDetailSheet.swift`
20. `Resources/Assets.xcassets/Contents.json`

### Key Algorithm: Free Slot Calculation

```
Input: events[] (sorted by startDate), workStart, workEnd
Output: freeSlots[]

1. Filter events to only those within workStart–workEnd
2. Sort events by startDate
3. Create gaps:
   - gap from workStart to firstEvent.start
   - gap from events[i].end to events[i+1].start
   - gap from lastEvent.end to workEnd
4. Return only gaps with duration > 0
```

### Duration Formatting
- Less than 60 minutes: "30 min"
- 60+ minutes: "1h 30min"

---

## UI Mockup

```
┌──────────────────────────────────┐
│ Pediglam      ⚙️  🔄      │  ← Header
├──────────────────────────────────┤
│ Wednesday, May 22, 2026          │  ← Date
│ Business hours: 9:00 AM – 7:00 PM│
├──────────────────────────────────┤
│ 🟢 FREE  9:00 – 10:00          │  ← Free slot (1h)
│ 1 hour available                 │
├──────────────────────────────────┤
│ 🔴 Jan Kowalski  10:00 – 11:00 │  ← Busy slot
│ 1 hour                          │
├──────────────────────────────────┤
│ 🟢 FREE  11:00 – 11:30         │  ← Free slot (30 min)
│ 30 minutes available             │
├──────────────────────────────────┤
│ 🔴 Anna Nowak  11:30 – 12:30   │
│ 1 hour                          │
├──────────────────────────────────┤
│ ...                              │
├──────────────────────────────────┤
│ 📊 SUMMARY                      │
│ Free: 4h 30min  Busy: 5h 30min │
└──────────────────────────────────┘
```

---

## Edge Cases to Handle

| Scenario | Behavior |
|----------|----------|
| No events today | Show "You're completely free today! 🎉" |
| All day busy | Show "No free slots today" |
| Permission denied | Show screen with "Open Settings" button |
| No calendars exist | Show "No calendars found" |
| Event outside work hours | Ignore it (don't show) |
| Event spans beyond work hours | Truncate to work hours |
| Event has no title | Show "Busy" as title |

---

## Build Instructions

```bash
# 1. Navigate to project directory
cd /Users/emgie/Desktop/My/Pediglam

# 2. Generate Xcode project
xcodegen generate

# 3. Open in Xcode
open Pediglam.xcodeproj

# 4. Select iPhone simulator and press Run (Cmd+R)
```

---

## Success Criteria

- App reads and displays today's calendar events
- Free slots are correctly calculated and displayed
- Work hours are configurable and persisted
- UI is clean, minimal, and follows Apple HIG
- App builds and runs without errors
- Supports iOS 16.0+
