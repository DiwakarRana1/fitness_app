import SwiftUI
import SwiftData

struct NutritionView: View {
    @Query(sort: \DailyMacroLog.date, order: .reverse) private var logs: [DailyMacroLog]
    @Environment(\.modelContext) private var modelContext
    
    @State private var caloriesInput: String = ""
    @State private var proteinInput: String = ""
    @State private var carbsInput: String = ""
    @State private var fatsInput: String = ""
    
    private var todayMacroLog: DailyMacroLog {
        let calendar = Calendar.current
        return logs.first { calendar.isDateInToday($0.date) } ?? DailyMacroLog(
            date: Date(),
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
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Today's Progress")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(todayMacroLog.consumedCalories) / \(todayMacroLog.targetCalories) kcal")
                            .font(.title2)
                            .bold()
                        
                        VStack(spacing: 12) {
                            MacroProgressBar(title: "Protein", current: todayMacroLog.consumedProtein, target: todayMacroLog.targetProtein, color: .blue)
                            MacroProgressBar(title: "Carbs", current: todayMacroLog.consumedCarbs, target: todayMacroLog.targetCarbs, color: .orange)
                            MacroProgressBar(title: "Fats", current: todayMacroLog.consumedFats, target: todayMacroLog.targetFats, color: .pink)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Quick-Add Macros")) {
                    VStack(spacing: 12) {
                        HStack {
                            TextField("Calories (kcal)", text: $caloriesInput)
                                #if os(iOS)
                                .keyboardType(.numberPad)
                                #endif
                            TextField("Protein (g)", text: $proteinInput)
                                #if os(iOS)
                                .keyboardType(.numberPad)
                                #endif
                        }
                        HStack {
                            TextField("Carbs (g)", text: $carbsInput)
                                #if os(iOS)
                                .keyboardType(.numberPad)
                                #endif
                            TextField("Fats (g)", text: $fatsInput)
                                #if os(iOS)
                                .keyboardType(.numberPad)
                                #endif
                        }
                        
                        Button(action: addMacros) {
                            Text("Add Macros")
                                .bold()
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(caloriesInput.isEmpty && proteinInput.isEmpty && carbsInput.isEmpty && fatsInput.isEmpty)
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("Macro History")) {
                    if logs.isEmpty {
                        Text("No logs yet")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(logs) { log in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(log.date, style: .date)
                                        .font(.headline)
                                    Text("P: \(log.consumedProtein)g | C: \(log.consumedCarbs)g | F: \(log.consumedFats)g")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("\(log.consumedCalories) kcal")
                                    .bold()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Nutrition")
        }
    }
    
    private func addMacros() {
        let calendar = Calendar.current
        let todayLog = logs.first { calendar.isDateInToday($0.date) }
        
        let c = Int(caloriesInput) ?? 0
        let p = Int(proteinInput) ?? 0
        let carb = Int(carbsInput) ?? 0
        let f = Int(fatsInput) ?? 0
        
        if let log = todayLog {
            log.consumedCalories += c
            log.consumedProtein += p
            log.consumedCarbs += carb
            log.consumedFats += f
        } else {
            let newLog = DailyMacroLog(
                date: Date(),
                consumedCalories: c,
                consumedProtein: p,
                consumedCarbs: carb,
                consumedFats: f
            )
            modelContext.insert(newLog)
        }
        
        // Reset Inputs
        caloriesInput = ""
        proteinInput = ""
        carbsInput = ""
        fatsInput = ""
    }
}

#Preview {
    NutritionView()
}
