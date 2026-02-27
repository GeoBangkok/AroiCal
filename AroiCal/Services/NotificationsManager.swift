import Foundation
import UserNotifications

@Observable
@MainActor
class NotificationsManager {

    var isPermissionGranted: Bool = false

    private let ids = ["aroi.morning", "aroi.lunch", "aroi.dinner"]

    init() {
        checkStatus()
    }

    func checkStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            Task { @MainActor [weak self] in
                self?.isPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }

    func requestAndSchedule(language: AppLanguage) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, _ in
            Task { @MainActor [weak self] in
                withAnimation(.spring) {
                    self?.isPermissionGranted = granted
                }
                if granted {
                    self?.scheduleReminders(language: language)
                }
            }
        }
    }

    func scheduleReminders(language: AppLanguage) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ids)

        let reminders: [(id: String, hour: Int, title: String, body: String)] = [
            (
                id: "aroi.morning",
                hour: 8,
                title: morningTitle(language),
                body: morningBody(language)
            ),
            (
                id: "aroi.lunch",
                hour: 12,
                title: lunchTitle(language),
                body: lunchBody(language)
            ),
            (
                id: "aroi.dinner",
                hour: 18,
                title: dinnerTitle(language),
                body: dinnerBody(language)
            )
        ]

        for reminder in reminders {
            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = reminder.body
            content.sound = .default

            var components = DateComponents()
            components.hour = reminder.hour
            components.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger)
            center.add(request)
        }
    }

    // MARK: - 8 AM – Breakfast
    private func morningTitle(_ lang: AppLanguage) -> String {
        switch lang {
        case .thai:     return "สวัสดีตอนเช้า! ☀️"
        case .japanese: return "おはよう！☀️"
        case .english:  return "Good morning! ☀️"
        }
    }

    private func morningBody(_ lang: AppLanguage) -> String {
        switch lang {
        case .thai:     return "เริ่มวันใหม่ด้วยมื้อเช้าดีๆ แล้วอย่าลืมสแกนแคลอรี่ด้วยนะจ๊ะ 🍳"
        case .japanese: return "朝食を記録して1日を元気にスタートしよう！🍳"
        case .english:  return "Start strong — snap your breakfast and track those calories! 🍳"
        }
    }

    // MARK: - 12 PM – Lunch
    private func lunchTitle(_ lang: AppLanguage) -> String {
        switch lang {
        case .thai:     return "มื้อกลางวันมาแล้ว! 🍜"
        case .japanese: return "ランチタイム！🍜"
        case .english:  return "Lunch time! 🍜"
        }
    }

    private func lunchBody(_ lang: AppLanguage) -> String {
        switch lang {
        case .thai:     return "กินอะไรเที่ยงนี้? ถ่ายรูปแล้วให้ AI คำนวณแคลให้เลย 📸"
        case .japanese: return "今日のランチは何？撮影してカロリーをチェック！📸"
        case .english:  return "What's for lunch? Point, snap, and let AI do the math! 📸"
        }
    }

    // MARK: - 6 PM – Dinner
    private func dinnerTitle(_ lang: AppLanguage) -> String {
        switch lang {
        case .thai:     return "เย็นนี้กินอะไร? 🌙"
        case .japanese: return "夕食の時間！🌙"
        case .english:  return "Dinner time! 🌙"
        }
    }

    private func dinnerBody(_ lang: AppLanguage) -> String {
        switch lang {
        case .thai:     return "บันทึกมื้อเย็นเพื่อรักษาสตรีคของคุณ เกือบครบวันแล้ว ไปได้เลย! 💪"
        case .japanese: return "夕食を記録してストリークをキープ！もう少しで1日完了💪"
        case .english:  return "Log dinner and protect your streak — almost there! 💪"
        }
    }
}
