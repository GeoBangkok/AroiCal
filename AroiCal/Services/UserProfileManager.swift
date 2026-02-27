import Foundation

@Observable
@MainActor
class UserProfileManager {
    var profile: UserProfile

    init() {
        if let data = UserDefaults.standard.data(forKey: "user_profile"),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.profile = decoded
        } else {
            self.profile = UserProfile()
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: "user_profile")
        }
    }

    func applyCalculatedTargets() {
        profile.targetCalories = profile.calculateTDEE()
        let macros = profile.calculateMacros()
        profile.targetProtein = macros.protein
        profile.targetCarbs = macros.carbs
        profile.targetFat = macros.fat
        save()
    }
}
