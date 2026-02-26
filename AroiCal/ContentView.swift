import SwiftUI

struct ContentView: View {
    @Environment(LanguageManager.self) private var lang
    @AppStorage("has_completed_onboarding") private var hasCompletedOnboarding: Bool = false

    var body: some View {
        if hasCompletedOnboarding {
            MainTabView()
        } else {
            OnboardingContainerView {
                withAnimation(.snappy) {
                    hasCompletedOnboarding = true
                }
            }
        }
    }
}
