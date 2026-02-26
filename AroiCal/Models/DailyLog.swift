import Foundation

struct DailyLog: Identifiable, Codable {
    let id: UUID
    let date: Date
    var entries: [FoodEntry]

    init(id: UUID = UUID(), date: Date = Date(), entries: [FoodEntry] = []) {
        self.id = id
        self.date = date
        self.entries = entries
    }

    var totalCalories: Int {
        entries.reduce(0) { $0 + $1.calories }
    }

    var totalProtein: Double {
        entries.reduce(0) { $0 + $1.protein }
    }

    var totalCarbs: Double {
        entries.reduce(0) { $0 + $1.carbs }
    }

    var totalFat: Double {
        entries.reduce(0) { $0 + $1.fat }
    }
}
