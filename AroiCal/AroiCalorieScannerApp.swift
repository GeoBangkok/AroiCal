import SwiftUI

@main
struct AroiCalorieScannerApp: App {
    @State private var languageManager = LanguageManager()
    @State private var profileManager = UserProfileManager()
    @State private var logManager = DailyLogManager()
    @State private var notificationsManager = NotificationsManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(languageManager)
                .environment(profileManager)
                .environment(logManager)
                .environment(notificationsManager)
        }
    }
}
