import SwiftUI
import SwiftData

struct NutritionView: View {
    @Query private var logs: [DailyMacroLog]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Today's Macros")) {
                    // Macro Meter components here
                    // Quick-Add Interface here
                }
                
                Section(header: Text("History")) {
                    ForEach(logs) { log in
                        VStack(alignment: .leading) {
                            Text(log.date, style: .date)
                            Text("Calories: \(log.consumedCalories)/\(log.targetCalories)")
                        }
                    }
                }
            }
            .navigationTitle("Nutrition")
        }
    }
}

#Preview {
    NutritionView()
}
