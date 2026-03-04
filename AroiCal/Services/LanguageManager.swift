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
        if preferred.hasPrefix("ja") { return .japanese }
        return .thai
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

    /// Extra line spacing for languages that need more vertical breathing room.
    /// Japanese kanji are dense square glyphs — 4pt extra spacing improves readability.
    var lineSpacingAdjust: CGFloat {
        switch current {
        case .japanese: return 4
        case .thai:     return 2
        case .english:  return 0
        }
    }

    /// Minimum scale factor for labels. Japanese text should not shrink as aggressively.
    var minimumScaleFactor: CGFloat {
        switch current {
        case .japanese: return 0.85
        default:        return 0.75
        }
    }
}
