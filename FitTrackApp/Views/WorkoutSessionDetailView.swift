import SwiftUI
import SwiftData

struct WorkoutSessionDetailView: View {
    @Bindable var session: WorkoutSession
    @Environment(\.modelContext) private var modelContext
    
    @State private var newExerciseName: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Routine Details")) {
                TextField("Routine Name", text: $session.routineName)
            }
            
            Section(header: Text("Add Exercise")) {
                HStack {
                    TextField("Exercise Name (e.g. Squat)", text: $newExerciseName)
                    Button(action: addExercise) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .disabled(newExerciseName.isEmpty)
                }
            }
            
            ForEach(session.exercises) { exercise in
                Section(header: Text(exercise.name)) {
                    ForEach(exercise.sets) { set in
                        WorkoutSetRow(exerciseSet: set)
                    }
                    .onDelete { offsets in
                        deleteSet(from: exercise, at: offsets)
                    }
                    
                    Button(action: { addSet(to: exercise) }) {
                        Label("Add Set", systemImage: "plus")
                    }
                }
            }
        }
        .navigationTitle(session.routineName.isEmpty ? "Workout Session" : session.routineName)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    private func addExercise() {
        let newExercise = ExerciseLog(name: newExerciseName)
        session.exercises.append(newExercise)
        newExerciseName = ""
    }
    
    private func addSet(to exercise: ExerciseLog) {
        let nextSetNum = (exercise.sets.map { $0.setNumber }.max() ?? 0) + 1
        let newSet = ExerciseSet(setNumber: nextSetNum, weight: 0.0, reps: 0)
        exercise.sets.append(newSet)
    }
    
    private func deleteSet(from exercise: ExerciseLog, at offsets: IndexSet) {
        for index in offsets {
            let set = exercise.sets[index]
            modelContext.delete(set)
        }
        exercise.sets.remove(atOffsets: offsets)
    }
}
