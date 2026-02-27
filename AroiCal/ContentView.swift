import SwiftUI

struct ContentView: View {
    @Environment(LanguageManager.self) private var lang
    @AppStorage("has_completed_onboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showLogin: Bool = true

    var body: some View {
        if showLogin {
            LoginView {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showLogin = false
                }
            }
            .environment(lang)
        } else if hasCompletedOnboarding {
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
