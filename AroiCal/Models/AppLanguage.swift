import Foundation

nonisolated enum AppLanguage: String, CaseIterable, Codable, Sendable {
    case english = "en"
    case thai = "th"
    case japanese = "ja"

    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .thai: return "🇹🇭"
        case .japanese: return "🇯🇵"
        }
    }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .thai: return "ไทย"
        case .japanese: return "日本語"
        }
    }
}
