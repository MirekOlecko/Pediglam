# Pediglam — SPEC.md

## 1. Concept & Vision

**Pediglam** to minimalistyczna appka do zarządzania wolnymi terminami w ciągu dnia pracy. Wpisujesz klientów w natywny kalendarz iOS — appka automatycznie pokazuje kiedy masz wolne okienka, żeby wcisnąć kolejnego klienta lub zaplanować przerwę.

Filozofia: **prosta jak Google Calendar, szybka jak zegarek**. Bez zbędnych funkcji — tylko to co potrzebne: "mam wolne od X do Y".

---

## 2. Design Language

**Aesthetic:** Minimal, professional, business-focused. Think Apple Calendar meets Linear.

### Colors
- **Background:** `#FFFFFF` (light) / `#000000` (dark)
- **Primary text:** `#1D1D1F`
- **Secondary text:** `#86868B`
- **Accent (busy):** `#FF6B6B` (coral red)
- **Accent (free):** `#51CF66` (fresh green)
- **Card background:** `#F5F5F7` (light) / `#1C1C1E` (dark)
- **Time blocks:** `#007AFF` (iOS blue)

### Typography
- **Font:** SF Pro (system)
- **Heading:** 34pt Bold
- **Subheading:** 17pt Semibold
- **Body:** 15pt Regular
- **Caption:** 13pt Regular, secondary color

### Spacing
- 16pt horizontal margins
- 12pt between cards
- 8pt internal padding in cards

### Motion
- 200ms ease-out for all transitions
- Subtle scale (0.98) on tap for cards
- Pull-to-refresh with native iOS rubber band

---

## 3. Layout & Structure

### Single Screen Design
Jeden ekran główny — nie ma nawigacji. Wszystko na jednym widoku.

```
┌─────────────────────────────┐
│  Pediglam      🔄     │  ← Header (data + refresh)
├─────────────────────────────┤
│  Dzisiaj, 22 maja 2026     │  ← Date header
│  Godziny pracy: 9:00–19:00 │  ← Configurable
├─────────────────────────────┤
│  ◉ 09:00–10:00  Jan Kowalski │  ← Busy slot (red accent)
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━  │  ← Event card
├─────────────────────────────┤
│  🟢 WOLNE  10:00–11:30     │  ← Free slot (green)
│  1h 30min wolnego           │  ← Duration
├─────────────────────────────┤
│  ◉ 11:30–12:30  Anna Nowak  │  ← Busy slot
├─────────────────────────────┤
│  🟢 WOLNE  12:30–14:00     │
│  1h 30min wolnego           │
├─────────────────────────────┤
│  ...                        │
├─────────────────────────────┤
│  📊 Podsumowanie dnia       │  ← Summary section
│  Wolne: 4h 30min / 10h     │  ← Total free time
│  Zajęte: 5h 30min          │
└─────────────────────────────┘
```

### Responsive
- iPhone: pełna szerokość karty
- iPad: karty max 600pt szerokości, wycentrowane

---

## 4. Features & Interactions

### Core Features

**F1: Calendar Access**
- Aplikacja prosi o dostęp do kalendarza iOS (EventKit)
- Jeśli brak dostępu — pokazuje ekran z prośbą o włączenie w Settings
- Czytam wszystkie kalendarze (EventStore.default.calendars)

**F2: Today's Schedule**
- Pobiera wszystkie eventy na dzisiejszy dzień
- Sortuje chronologicznie
- Filtruje tylko te które mieszczą się w godzinach pracy (domyślnie 9:00–19:00)
- Ignoruje all-day events (cały dzień zajęty)

**F3: Free Slot Calculation**
- Dzieli dzień na bloki: [start_pracy] → [event1_start] → [event1_end] → [event2_start] → ... → [end_pracy]
- Każdy gap między eventami = wolny slot
- Jeśli event zaczyna się przed godziną otwarcia — traktujemy od godziny otwarcia
- Jeśli event kończy się po godzinie zamknięcia — traktujemy do godziny zamknięcia

**F4: Business Hours Configuration**
- Godziny pracy ustawiane w Settings (UserDefaults)
- Domyślne: 9:00 – 19:00
- Możliwość zmiany na dowolną godzinę (TimePicker)
- Pamiętane między sesjami

**F5: Pull to Refresh**
- Pull down na liście odświeża dane z kalendarza
- Native iOS refresh control

**F6: Summary Stats**
- Na dole ekranu: łączny czas wolny vs łączny czas zajęty
- Procent wykorzystania dnia

### Interactions

**Tap on event card:**
- Pokazuje detal: tytuł, czas, lokalizację (jeśli jest), notatki
- Prezentowane jako native sheet (SwiftUI sheet)

**Long press on free slot:**
- Opcja "Skopiuj jako tekst" — np. "Wolne: 10:00–11:30 (1h 30min)"
- Użyteczne do wysłania SMS/a klientowi

**Settings (gear icon):**
- Godzina otwarcia (TimePicker)
- Godzina zamknięcia (TimePicker)
- Opcja "Pokazuj tylko忙klienci" (filtruje eventy bez tytułu)
- About / wersja

### Edge Cases

- **Brak eventów:** "Masz cały dzień wolny! 🎉"
- **Brak kalendarza:** "Nie znaleziono kalendarzy. Stwórz pierwszy event."
- **Kalendarz niedostępny:** Przekierowanie do Settings app
- **Wszystko zapełnione:** "Brak wolnych slotów na dziś"
- **Eventy poza godzinami pracy:** Ignorowane (nie pokazujemy ich)

---

## 5. Component Inventory

### HeaderView
- Data dzisiejsza (format: "Środa, 22 maja 2026")
- Przycisk odświeżania (SF Symbol: `arrow.clockwise`)
- Przycisk ustawień (SF Symbol: `gear`)
- States: default, refreshing (rotating icon)

### DateHeaderView
- Dzień tygodnia + data
- Godziny pracy jako subtitle
- Możliwość tapnięcia na zmianę daty (DatePicker)

### EventCard
- Kolorowa kropka/linia po lewej (czerwona dla busy, zielona dla free)
- Czas: "09:00 – 10:00"
- Tytuł klienta (bold) lub "Wolne"
- Czas trwania jako caption
- States: default, tapped (scale 0.98)

### FreeSlotCard (extends EventCard)
- Zielona kropka/linia
- Ikona "wolne" (SF Symbol: `clock.badge.checkmark`)
- Duration w größ Schrift (np. "1h 30min")

### BusySlotCard (extends EventCard)
- Czerwona kropka/linia
- Ikona "zajęty" (SF Symbol: `person.fill`)
- Nazwa klienta z tytułu eventu
- Jeśli brak tytułu: "Zajęty"

### SummaryView
- Sekcja na dole ekranu
- Dwie statystyki: "Wolne" i "Zajęte"
- Pasek postępu (wolne vs zajęte wizualnie)

### EmptyStateView
- Ilustracja (SF Symbol: `calendar.badge.checkmark`)
- Tekst zachęcający do dodania eventów
- Albo "Brak wolnych slotów" z emoji

### PermissionDeniedView
- SF Symbol: `calendar.badge.exclamationmark`
- Tekst: "Potrzebuję dostępu do kalendarza"
- Przycisk: "Otwórz Ustawienia"

### EventDetailSheet
- SwiftUI sheet
- Pełne informacje o evencie
- Przycisk "Otwórz w Kalendarzu" (URL scheme: `calshow://`)

---

## 6. Technical Approach

### Stack
- **Language:** Swift 5.9+
- **UI:** SwiftUI (pure, no UIKit)
- **Framework:** EventKit (calendar access)
- **Build:** XcodeGen
- **Minimum iOS:** 16.0

### Architecture: MVVM

```
Pediglam/
├── App/
│   └── PediglamApp.swift       # @main entry point
├── Models/
│   ├── CalendarEvent.swift            # Raw EKEvent wrapper
│   ├── TimeSlot.swift                 # Free/busy slot model
│   └── DaySchedule.swift              # Aggregated day view
├── ViewModels/
│   └── CalendarViewModel.swift        # Main view model, ObservableObject
├── Views/
│   ├── ContentView.swift              # Main screen
│   ├── components/
│   │   ├── HeaderView.swift
│   │   ├── EventCard.swift
│   │   ├── FreeSlotCard.swift
│   │   ├── BusySlotCard.swift
│   │   ├── SummaryView.swift
│   │   └── EmptyStateView.swift
│   └── sheets/
│       ├── SettingsSheet.swift
│       └── EventDetailSheet.swift
├── Services/
│   └── CalendarService.swift          # EventKit wrapper
├── Utilities/
│   ├── DateExtensions.swift
│   └── Colors.swift                   # App color palette
├── Resources/
│   └── Assets.xcassets
└── Info.plist
```

### Data Flow
1. `CalendarService` pobiera eventy z EventKit
2. `CalendarViewModel` przetwarza eventy → oblicza wolne sloty
3. SwiftUI Views obserwują `@Published` properties w ViewModel
4. User interactions (tap, pull) wywołują metody ViewModel

### Key Algorithms

**Free Slot Calculation:**
```swift
func calculateFreeSlots(events: [EKEvent], workStart: Date, workEnd: Date) -> [TimeSlot] {
    // 1. Filter events within work hours
    // 2. Sort by startDate
    // 3. Create gaps:
    //    - gap from workStart to first event.start
    //    - gap from event[i].end to event[i+1].start
    //    - gap from last event.end to workEnd
    // 4. Return only gaps > 0 duration
}
```

**Duration Formatting:**
- < 60 min: "30 min"
- ≥ 60 min: "1h 30min"

### Persistence (UserDefaults)
- `workStartHour: Int` (default: 9)
- `workStartMinute: Int` (default: 0)
- `workEndHour: Int` (default: 19)
- `workEndMinute: Int` (default: 0)
- `selectedDate: Date` (last viewed date)

### Info.plist Keys
```xml
<key>NSCalendarsUsageDescription</key>
<string>Pediglam potrzebuje dostępu do kalendarza, żeby pokazywać Twoje spotkania i wolne terminy.</string>
<key>NSCalendarsFullAccessUsageDescription</key>
<string>Pediglam potrzebuje pełnego dostępu do kalendarza, żeby pokazywać Twoje spotkania i wolne terminy.</string>
```

### Dependencies
- **None** — pure SwiftUI + EventKit
- XcodeGen only for project generation (Homebrew: `brew install xcodegen`)

### Asset Requirements
- App Icon: simple calendar with checkmark (can use SF Symbols in-app)
- No custom images needed — SF Symbols for all icons
- Accent color: `#51CF66` (green for free)
