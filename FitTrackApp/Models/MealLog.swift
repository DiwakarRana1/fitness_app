import Foundation
import SwiftData

@Model
final class MealLog {
    var id: UUID
    var date: Date
    var name: String
    var quantity: String
    var mealType: String // earlyMorning, breakfast, lunch, dinner, snack
    var isDietBreak: Bool
    var calories: Int
    var protein: Int
    var carbs: Int
    var fats: Int

    init(id: UUID = UUID(), date: Date = Date(), name: String = "", quantity: String = "", mealType: String = "breakfast", isDietBreak: Bool = false, calories: Int = 0, protein: Int = 0, carbs: Int = 0, fats: Int = 0) {
        self.id = id
        self.date = date
        self.name = name
        self.quantity = quantity
        self.mealType = mealType
        self.isDietBreak = isDietBreak
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fats = fats
    }
}
