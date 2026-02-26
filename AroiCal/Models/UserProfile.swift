import Foundation

nonisolated enum Gender: String, Codable, CaseIterable, Sendable {
    case male
    case female
    case other
}

nonisolated enum ActivityLevel: String, Codable, CaseIterable, Sendable {
    case sedentary
    case light
    case moderate
    case active
    case veryActive
}

nonisolated enum GoalType: String, Codable, CaseIterable, Sendable {
    case lose
    case maintain
    case gain
}

nonisolated struct UserProfile: Codable, Sendable {
    var name: String = ""
    var age: Int = 25
    var gender: Gender = .male
    var heightCm: Double = 170
    var weightKg: Double = 70
    var desiredWeightKg: Double = 65
    var weeklyLossKg: Double = 0.5
    var activityLevel: ActivityLevel = .moderate
    var goal: GoalType = .lose
    var targetCalories: Int = 2000
    var targetProtein: Int = 150
    var targetCarbs: Int = 200
    var targetFat: Int = 65
    var difficulties: [String] = []
    var dietGoal: String = "lose"
    var creatorReferral: String = ""

    func calculateTDEE() -> Int {
        let bmr: Double
        switch gender {
        case .male:
            bmr = 10 * weightKg + 6.25 * heightCm - 5 * Double(age) + 5
        case .female:
            bmr = 10 * weightKg + 6.25 * heightCm - 5 * Double(age) - 161
        case .other:
            bmr = 10 * weightKg + 6.25 * heightCm - 5 * Double(age) - 78
        }

        let multiplier: Double
        switch activityLevel {
        case .sedentary: multiplier = 1.2
        case .light: multiplier = 1.375
        case .moderate: multiplier = 1.55
        case .active: multiplier = 1.725
        case .veryActive: multiplier = 1.9
        }

        var tdee = bmr * multiplier

        let deficit = weeklyLossKg * 7700 / 7
        switch goal {
        case .lose: tdee -= deficit
        case .maintain: break
        case .gain: tdee += 300
        }

        return max(1200, Int(tdee))
    }

    func calculateMacros() -> (protein: Int, carbs: Int, fat: Int) {
        let cals = calculateTDEE()
        let protein = Int(Double(cals) * 0.3 / 4)
        let fat = Int(Double(cals) * 0.25 / 9)
        let carbs = Int(Double(cals) * 0.45 / 4)
        return (protein, carbs, fat)
    }
}
