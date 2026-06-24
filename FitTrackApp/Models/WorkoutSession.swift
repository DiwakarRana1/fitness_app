import Foundation
import SwiftData

@Model
final class WorkoutSession {
    var id: UUID
    var date: Date
    var routineName: String
    @Relationship(deleteRule: .cascade) var exercises: [ExerciseLog]

    init(id: UUID = UUID(), date: Date = Date(), routineName: String = "", exercises: [ExerciseLog] = []) {
        self.id = id
        self.date = date
        self.routineName = routineName
        self.exercises = exercises
    }
}

@Model
final class ExerciseLog {
    var id: UUID
    var name: String
    @Relationship(deleteRule: .cascade) var sets: [ExerciseSet]

    init(id: UUID = UUID(), name: String = "", sets: [ExerciseSet] = []) {
        self.id = id
        self.name = name
        self.sets = sets
    }
}

@Model
final class ExerciseSet {
    var id: UUID
    var setNumber: Int
    var weight: Double
    var reps: Int
    var isCompleted: Bool

    init(id: UUID = UUID(), setNumber: Int = 1, weight: Double = 0.0, reps: Int = 0, isCompleted: Bool = false) {
        self.id = id
        self.setNumber = setNumber
        self.weight = weight
        self.reps = reps
        self.isCompleted = isCompleted
    }
}
