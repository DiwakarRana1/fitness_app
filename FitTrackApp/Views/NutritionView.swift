import SwiftUI
import SwiftData
import UserNotifications

struct NutritionView: View {
    @Query(sort: \DailyMacroLog.date, order: .reverse) private var logs: [DailyMacroLog]
    @Environment(\.modelContext) private var modelContext
    
    @State private var caloriesInput: String = ""
    @State private var proteinInput: String = ""
    @State private var carbsInput: String = ""
    @State private var fatsInput: String = ""
    
    // Detailed Food Logging
    @State private var foodName: String = ""
    @State private var foodQuantity: String = ""
    @State private var selectedMealType: String = "breakfast"
    @State private var isDietBreak: Bool = false
    
    // Reminders
    @AppStorage("waterReminderEnabled") private var waterReminderEnabled = false
    @AppStorage("waterReminderInterval") private var waterReminderInterval = 2.0 // default every 2 hours
    
    private let mealTypes = ["earlyMorning", "breakfast", "lunch", "dinner", "snack"]
    private let intervalOptions = [1.0, 2.0, 3.0, 4.0]
    
    private var todayMacroLog: DailyMacroLog {
        let calendar = Calendar.current
        if let log = logs.first(where: { calendar.isDateInToday($0.date) }) {
            return log
        }
        let newLog = DailyMacroLog(date: Date())
        modelContext.insert(newLog)
        return newLog
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
                
                Section(header: Text("Water Tracker")) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.blue)
                                .font(.title)
                            VStack(alignment: .leading) {
                                Text("\(todayMacroLog.waterConsumedMl) / \(todayMacroLog.waterTargetMl) mL")
                                    .bold()
                                    .font(.headline)
                                ProgressView(value: Double(todayMacroLog.waterConsumedMl), total: Double(todayMacroLog.waterTargetMl))
                                    .tint(.blue)
                            }
                        }
                        
                        HStack {
                            Button("+250 mL") { incrementWater(by: 250) }
                                .buttonStyle(.bordered)
                            Button("+500 mL") { incrementWater(by: 500) }
                                .buttonStyle(.bordered)
                            Spacer()
                            Button("Reset") { todayMacroLog.waterConsumedMl = 0 }
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("Water Reminders")) {
                    Toggle("Enable Reminders", isOn: $waterReminderEnabled)
                        .onChange(of: waterReminderEnabled) { _, newValue in
                            if newValue {
                                requestNotificationPermissions()
                            } else {
                                cancelNotifications()
                            }
                        }
                    
                    if waterReminderEnabled {
                        Picker("Reminder Interval", selection: $waterReminderInterval) {
                            ForEach(intervalOptions, id: \.self) { hours in
                                Text("Every \(Int(hours)) hour\(hours > 1 ? "s" : "")").tag(hours)
                            }
                        }
                        .onChange(of: waterReminderInterval) { _, _ in
                            scheduleNotifications()
                        }
                    }
                }
                
                Section(header: Text("Log Meal & Diet Breaks")) {
                    VStack(spacing: 12) {
                        TextField("Food Name (e.g. Paneer Bhurji)", text: $foodName)
                        TextField("Quantity (e.g. 1 plate / 200g)", text: $foodQuantity)
                        
                        Picker("Meal Type", selection: $selectedMealType) {
                            Text("Early Morning").tag("earlyMorning")
                            Text("Breakfast").tag("breakfast")
                            Text("Lunch").tag("lunch")
                            Text("Dinner").tag("dinner")
                            Text("Snack").tag("snack")
                        }
                        .pickerStyle(.menu)
                        
                        Toggle(isOn: $isDietBreak) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("This breaks my diet plan")
                            }
                        }
                        
                        HStack {
                            TextField("Est. Cals", text: $caloriesInput)
                                #if os(iOS)
                                .keyboardType(.numberPad)
                                #endif
                            TextField("Est. Prot (g)", text: $proteinInput)
                                #if os(iOS)
                                .keyboardType(.numberPad)
                                #endif
                        }
                        
                        Button(action: addMeal) {
                            Text("Log Meal")
                                .bold()
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(foodName.isEmpty || foodQuantity.isEmpty)
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("Today's Food Diary")) {
                    if todayMacroLog.meals.isEmpty {
                        Text("No meals logged yet today.")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(todayMacroLog.meals) { meal in
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(meal.name)
                                            .font(.headline)
                                        if meal.isDietBreak {
                                            Text("Diet Deviation")
                                                .font(.system(size: 10, weight: .bold))
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.red.opacity(0.1))
                                                .foregroundColor(.red)
                                                .cornerRadius(4)
                                        }
                                    }
                                    Text("\(meal.quantity) | \(meal.mealType.capitalized)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("\(meal.calories) kcal")
                                    .bold()
                            }
                        }
                        .onDelete(perform: deleteMeal)
                    }
                }
            }
            .navigationTitle("Nutrition")
        }
    }
    
    private func incrementWater(by amount: Int) {
        todayMacroLog.waterConsumedMl += amount
    }
    
    private func addMeal() {
        let c = Int(caloriesInput) ?? 0
        let p = Int(proteinInput) ?? 0
        let carb = Int(carbsInput) ?? 0
        let f = Int(fatsInput) ?? 0
        
        let newMeal = MealLog(
            date: Date(),
            name: foodName,
            quantity: foodQuantity,
            mealType: selectedMealType,
            isDietBreak: isDietBreak,
            calories: c,
            protein: p,
            carbs: carb,
            fats: f
        )
        
        todayMacroLog.meals.append(newMeal)
        
        // Update totals
        todayMacroLog.consumedCalories += c
        todayMacroLog.consumedProtein += p
        todayMacroLog.consumedCarbs += carb
        todayMacroLog.consumedFats += f
        
        // Reset Inputs
        foodName = ""
        foodQuantity = ""
        isDietBreak = false
        caloriesInput = ""
        proteinInput = ""
        carbsInput = ""
        fatsInput = ""
    }
    
    private func deleteMeal(at offsets: IndexSet) {
        for index in offsets {
            let meal = todayMacroLog.meals[index]
            todayMacroLog.consumedCalories -= meal.calories
            todayMacroLog.consumedProtein -= meal.protein
            todayMacroLog.consumedCarbs -= meal.carbs
            todayMacroLog.consumedFats -= meal.fats
            modelContext.delete(meal)
        }
        todayMacroLog.meals.remove(atOffsets: offsets)
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                scheduleNotifications()
            }
        }
    }
    
    private func scheduleNotifications() {
        cancelNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "Time to drink water! 💧"
        content.body = "Stay hydrated to hit your daily goal."
        content.sound = .default
        
        let timeInterval = waterReminderInterval * 3600.0 // hours to seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: true)
        
        let request = UNNotificationRequest(identifier: "water_reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["water_reminder"])
    }
}

#Preview {
    NutritionView()
}
