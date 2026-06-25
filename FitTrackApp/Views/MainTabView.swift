import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
            NutritionView()
                .tabItem {
                    Label("Nutrition", systemImage: "fork.knife")
                }
            WorkoutLogView()
                .tabItem {
                    Label("Workout", systemImage: "figure.run")
                }
            PhysiqueGalleryView()
                .tabItem {
                    Label("Physique", systemImage: "camera.macro")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
}
