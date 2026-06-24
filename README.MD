# App Specification: FitTrack Unified (iOS SwiftUI Application)

This document serves as the absolute blueprint and execution plan for the autonomous AI agents to scaffold, develop, and verify a native iOS application for tracking diet, workouts, and physique metrics using SwiftUI and SwiftData.

---

## 1. Project Goal & Overview
Build a high-performance, responsive, and clean native iOS application to track daily progress across three core pillars: Nutrition, Exercise, and Physique metrics. The application must function entirely offline using local storage (`SwiftData`) and be structured correctly so that it compiles seamlessly upon loading into Apple's Xcode IDE.

---

## 2. Core Technical Architecture

- **Platform:** iOS 17+
- **Language:** Swift 5.10+
- **UI Framework:** SwiftUI (Declarative UI)
- **Data Persistence:** SwiftData (Modern native framework for local data models)
- **Design Pattern:** MVVM (Model-View-ViewModel) or direct SwiftData `@Query`/`@Environment` macro architecture[cite: 1].

---

## 3. Data Models (`SwiftData` Managed)

The AI agent must initialize and define the following persistent models using `@Model`[cite: 1]:

### A. `DailyMacroLog`[cite: 1]
- `id`: UUID (Primary Key)[cite: 1]
- `date`: Date (Timestamp truncated to daily format)[cite: 1]
- `targetCalories`: Int[cite: 1]
- `targetProtein`: Int[cite: 1]
- `targetCarbs`: Int[cite: 1]
- `targetFats`: Int[cite: 1]
- `consumedCalories`: Int[cite: 1]
- `consumedProtein`: Int[cite: 1]
- `consumedCarbs`: Int[cite: 1]
- `consumedFats`: Int[cite: 1]

### B. `WorkoutSession`[cite: 1]
- `id`: UUID[cite: 1]
- `date`: Date[cite: 1]
- `routineName`: String (e.g., "Push Day", "Full Body")[cite: 1]
- `exercises`: [ExerciseLog] (Relationship: Cascade delete)[cite: 1]

### C. `ExerciseLog`[cite: 1]
- `id`: UUID[cite: 1]
- `name`: String (e.g., "Barbell Squat")[cite: 1]
- `sets`: [ExerciseSet] (Relationship: Cascade delete)[cite: 1]

### D. `ExerciseSet`[cite: 1]
- `id`: UUID[cite: 1]
- `setNumber`: Int[cite: 1]
- `weight`: Double (in kg/lbs)[cite: 1]
- `reps`: Int[cite: 1]
- `isCompleted`: Bool[cite: 1]

### E. `PhysiqueEntry`[cite: 1]
- `id`: UUID[cite: 1]
- `date`: Date[cite: 1]
- `bodyWeight`: Double[cite: 1]
- `photoData`: Data? (Binary representation of the progress image saved locally)[cite: 1]
- `notes`: String[cite: 1]

---

## 4. Feature and UI Specification

The app must feature a clean tab-based navigation layout (`TabView`) mapping directly to the following visual structures[cite: 1]:

### Tab 1: Dashboard View (`DashboardView.swift`)[cite: 1]
- **Visuals:** High-impact dynamic metric rings or progress bars for Calories, Protein, Carbs, and Fats[cite: 1].
- **Content:** Highlights today's nutrition balance, displays the last logged workout, and shows the latest recorded scale weight[cite: 1].
- **Actions:** High-visibility quick buttons to jump into adding items[cite: 1].

### Tab 2: Nutrition View (`NutritionView.swift`)[cite: 1]
- **Macro Meter:** Displays dynamic numerical fraction lines (e.g., "140g / 180g Protein")[cite: 1].
- **Quick-Add Interface:** A form sheet containing text input fields or stepper counters to instantly increment consumed Calories, Protein, Carbs, and Fats manually without requiring an external food database search[cite: 1].
- **History list:** An expandable accordion or scrolling menu showing previous days' logged macro metrics[cite: 1].

### Tab 3: Workout Logger (`WorkoutLogView.swift`)[cite: 1]
- **Session Setup:** A modal view to select or name a new routine session[cite: 1].
- **Dynamic Grid Interface:** Form components to seamlessly add a new exercise name string[cite: 1]. Beneath each exercise, a reactive row item listing `Set Number`, `Weight Input Box`, `Reps Input Box`, and a clickable "Checkmark" button to mark the set completed[cite: 1].
- **Persistent History:** A chronologically organized view showcasing past completed workouts with detailed nested summaries[cite: 1].

### Tab 4: Physique Gallery (`PhysiqueGalleryView.swift`)[cite: 1]
- **Metric Logger:** Simple numerical input block with data entry validation to log current scale weight[cite: 1].
- **Weight Chart:** A native `Swift Charts` line plot rendering your weight history curve over time[cite: 1].
- **Photo Repository:** An interactive square grid gallery component pulling local binary images via Swift's `PhotosPicker`[cite: 1]. Tapping any card displays the image in full screen with corresponding logging date metadata[cite: 1].

---

## 5. Directory Blueprint to Generate

The background agent must set up the workspace directory according to standard native iOS project conventions[cite: 1]:

```text
FitTrackApp/
├── FitTrackApp.swift (App Entrypoint, injects SwiftData modelContainer)
├── Models/
│   ├── DailyMacroLog.swift
│   ├── WorkoutSession.swift
│   └── PhysiqueEntry.swift
├── Views/
│   ├── MainTabView.swift
│   ├── DashboardView.swift
│   ├── NutritionView.swift
│   ├── WorkoutLogView.swift
│   └── PhysiqueGalleryView.swift
└── Components/
    ├── MacroProgressBar.swift
    └── WorkoutSetRow.swift