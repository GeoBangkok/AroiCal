import SwiftUI
import SuperwallKit

@main
struct AroiCalorieScannerApp: App {
    @State private var languageManager = LanguageManager()
    @State private var profileManager = UserProfileManager()
    @State private var logManager = DailyLogManager()
    @State private var notificationsManager = NotificationsManager()

    init() {
        // Configure Superwall
        configureSuperwall()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(languageManager)
                .environment(profileManager)
                .environment(logManager)
                .environment(notificationsManager)
        }
    }

    private func configureSuperwall() {
        // Get API key from Config or environment
        let apiKey = Config.superwallAPIKey

        // Configure Superwall with custom purchase controller
        Superwall.configure(
            apiKey: apiKey,
            purchaseController: SuperwallPurchaseController()
        )

        // Set initial subscription status
        Task {
            await StoreManager.shared.checkSubscriptionStatus()
        }

        print("✅ Superwall configured successfully")
    }
}
