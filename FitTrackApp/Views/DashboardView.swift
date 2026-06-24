import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var macroLogs: [DailyMacroLog]
    @Query private var workouts: [WorkoutSession]
    @Query private var physiqueEntries: [PhysiqueEntry]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Dashboard")
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    // Add Rings/Progress Bars for Macros here
                    // Add Latest Workout Summary here
                    // Add Latest Scale Weight here
                }
            }
            .navigationTitle("FitTrack Dashboard")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    DashboardView()
}
