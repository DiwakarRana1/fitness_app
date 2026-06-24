import Foundation
import SwiftData

@Model
final class DailyMacroLog {
    var id: UUID
    var date: Date
    var targetCalories: Int
    var targetProtein: Int
    var targetCarbs: Int
    var targetFats: Int
    var consumedCalories: Int
    var consumedProtein: Int
    var consumedCarbs: Int
    var consumedFats: Int

    init(id: UUID = UUID(), date: Date = Date(), targetCalories: Int = 2000, targetProtein: Int = 150, targetCarbs: Int = 200, targetFats: Int = 65, consumedCalories: Int = 0, consumedProtein: Int = 0, consumedCarbs: Int = 0, consumedFats: Int = 0) {
        self.id = id
        self.date = date
        self.targetCalories = targetCalories
        self.targetProtein = targetProtein
        self.targetCarbs = targetCarbs
        self.targetFats = targetFats
        self.consumedCalories = consumedCalories
        self.consumedProtein = consumedProtein
        self.consumedCarbs = consumedCarbs
        self.consumedFats = consumedFats
    }
}
