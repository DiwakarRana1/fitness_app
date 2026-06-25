import SwiftUI
import SwiftData

@main
struct FitTrackApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [
            DailyMacroLog.self,
            MealLog.self,
            WorkoutSession.self,
            ExerciseLog.self,
            ExerciseSet.self,
            PhysiqueEntry.self
        ])
    }
}
