import SwiftUI
import SwiftData

struct WorkoutSetRow: View {
    @Bindable var exerciseSet: ExerciseSet
    
    var body: some View {
        HStack {
            Text("Set \(exerciseSet.setNumber)")
                .frame(width: 50, alignment: .leading)
            
            TextField("Weight", value: $exerciseSet.weight, format: .number)
                #if os(iOS)
                .keyboardType(.decimalPad)
                #endif
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 70)
            
            Text("kg")
            
            TextField("Reps", value: $exerciseSet.reps, format: .number)
                #if os(iOS)
                .keyboardType(.numberPad)
                #endif
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 60)
            
            Spacer()
            
            Button(action: {
                exerciseSet.isCompleted.toggle()
            }) {
                Image(systemName: exerciseSet.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(exerciseSet.isCompleted ? .green : .gray)
                    .font(.title2)
            }
        }
        .padding(.vertical, 4)
    }
}
