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

        print("🔧 Configuring Superwall with API key: \(apiKey.prefix(10))...")

        // Configure Superwall with custom purchase controller
        Superwall.configure(
            apiKey: apiKey,
            purchaseController: SuperwallPurchaseController()
        )

        // Set delegate for paywall events
        Superwall.shared.delegate = SuperwallDelegateHandler.shared

        // Set initial subscription status
        Task {
            await StoreManager.shared.checkSubscriptionStatus()
        }

        print("✅ Superwall configured successfully")
    }
}

// MARK: - Superwall Delegate Handler
class SuperwallDelegateHandler: SuperwallDelegate {
    static let shared = SuperwallDelegateHandler()

    private init() {}

    func handleSuperwallEvent(withInfo eventInfo: SuperwallEventInfo) {
        switch eventInfo.event {
        case .paywallOpen(let paywallInfo):
            print("📱 Paywall opened: \(paywallInfo.name)")
        case .paywallClose(let paywallInfo):
            print("📱 Paywall closed: \(paywallInfo.name)")
        case .transactionComplete(let transaction):
            print("✅ Transaction complete: \(transaction.product.productIdentifier)")
            Task {
                await StoreManager.shared.checkSubscriptionStatus()
            }
        case .transactionFail(let error):
            print("❌ Transaction failed: \(error)")
        case .paywallResponseLoadStart:
            print("⏳ Loading paywall...")
        case .paywallResponseLoadComplete:
            print("✅ Paywall loaded successfully")
        case .paywallResponseLoadFail(let error):
            print("❌ Paywall load failed: \(error)")
        default:
            print("ℹ️ Superwall event: \(eventInfo.event)")
        }
    }
}
