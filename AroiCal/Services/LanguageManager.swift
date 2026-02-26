import SwiftUI

@Observable
@MainActor
class LanguageManager {
    var current: AppLanguage {
        didSet {
            UserDefaults.standard.set(current.rawValue, forKey: "app_language")
        }
    }

    init() {
        if let saved = UserDefaults.standard.string(forKey: "app_language"),
           let lang = AppLanguage(rawValue: saved) {
            self.current = lang
        } else {
            self.current = Self.detectDeviceLanguage()
        }
    }

    private static func detectDeviceLanguage() -> AppLanguage {
        let preferred = Locale.preferredLanguages.first ?? "en"
        if preferred.hasPrefix("th") { return .thai }
        if preferred.hasPrefix("ja") { return .japanese }
        return .english
    }

    func cycleLanguage() {
        let all = AppLanguage.allCases
        guard let idx = all.firstIndex(of: current) else { return }
        let next = all[(idx + 1) % all.count]
        current = next
    }

    func t(_ english: String, thai: String, japanese: String = "") -> String {
        switch current {
        case .thai: return thai
        case .japanese: return japanese.isEmpty ? english : japanese
        case .english: return english
        }
    }

    var isThailand: Bool {
        Locale.current.region?.identifier == "TH"
    }

    var isJapan: Bool {
        Locale.current.region?.identifier == "JP"
    }

    var localeIdentifier: String {
        switch current {
        case .english: return "en"
        case .thai: return "th"
        case .japanese: return "ja"
        }
    }
}
