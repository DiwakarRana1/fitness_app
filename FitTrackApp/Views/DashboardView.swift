import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var macroLogs: [DailyMacroLog]
    @Query private var workouts: [WorkoutSession]
    @Query private var physiqueEntries: [PhysiqueEntry]
    
    // Helper to find today's log or supply a default one
    private var currentMacroLog: DailyMacroLog {
        let calendar = Calendar.current
        let todayLog = macroLogs.first { log in
            calendar.isDateInToday(log.date)
        }
        return todayLog ?? DailyMacroLog(
            targetCalories: 2000,
            targetProtein: 150,
            targetCarbs: 200,
            targetFats: 65,
            consumedCalories: 0,
            consumedProtein: 0,
            consumedCarbs: 0,
            consumedFats: 0
        )
    }
    
    // Helper to get the most recent workout
    private var latestWorkout: WorkoutSession? {
        workouts.sorted(by: { $0.date > $1.date }).first
    }
    
    // Helper to get the most recent weight entry
    private var latestPhysiqueEntry: PhysiqueEntry? {
        physiqueEntries.sorted(by: { $0.date > $1.date }).first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Dashboard")
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    // 1. Nutrition Card
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Today's Nutrition")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack(alignment: .firstTextBaseline) {
                            Text("\(currentMacroLog.consumedCalories)")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                            Text("/ \(currentMacroLog.targetCalories) kcal")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 12) {
                            MacroProgressBar(title: "Protein", current: currentMacroLog.consumedProtein, target: currentMacroLog.targetProtein, color: .blue)
                            MacroProgressBar(title: "Carbs", current: currentMacroLog.consumedCarbs, target: currentMacroLog.targetCarbs, color: .orange)
                            MacroProgressBar(title: "Fats", current: currentMacroLog.consumedFats, target: currentMacroLog.targetFats, color: .pink)
                        }
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // 2. Latest Workout Card
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Latest Workout")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        if let workout = latestWorkout {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(workout.routineName)
                                        .font(.title3)
                                        .bold()
                                    Text(workout.date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("\(workout.exercises.count) Exercises")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            Text("No workouts logged yet.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // 3. Latest Scale Weight Card
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Latest Weight")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        if let entry = latestPhysiqueEntry {
                            HStack {
                                Text("\(String(format: "%.1f", entry.bodyWeight)) kg")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                Spacer()
                                Text(entry.date, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            Text("No weight logged yet.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("FitTrack Dashboard")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

#Preview {
    DashboardView()
}
