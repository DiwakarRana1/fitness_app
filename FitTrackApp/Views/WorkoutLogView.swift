import SwiftUI
import SwiftData

struct WorkoutLogView: View {
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(sessions) { session in
                    NavigationLink(destination: Text("Session Detail for \(session.routineName)")) {
                        VStack(alignment: .leading) {
                            Text(session.routineName)
                                .font(.headline)
                            Text(session.date, style: .date)
                                .font(.subheadline)
                        }
                    }
                }
                .onDelete(perform: deleteSessions)
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addSession) {
                        Label("Add Session", systemImage: "plus")
                    }
                }
            }
        }
    }
    
    private func addSession() {
        let newSession = WorkoutSession(date: Date(), routineName: "New Routine")
        modelContext.insert(newSession)
    }
    
    private func deleteSessions(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(sessions[index])
            }
        }
    }
}

#Preview {
    WorkoutLogView()
}
