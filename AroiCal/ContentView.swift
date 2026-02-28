import SwiftUI

// MARK: - Splash screen for returning users
struct SplashView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            Text("AroiCal")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(.black)
        }
    }
}

// MARK: - Root content router
struct ContentView: View {
    @Environment(LanguageManager.self) private var lang
    @AppStorage("has_completed_onboarding") private var hasCompletedOnboarding: Bool = false

    @State private var showLogin: Bool = true
    @State private var showSplash: Bool = false

    var body: some View {
        Group {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else if showLogin {
                LoginView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showLogin = false
                    }
                }
                .environment(lang)
                .transition(.opacity)
            } else if hasCompletedOnboarding {
                MainTabView()
                    .transition(.opacity)
            } else {
                OnboardingContainerView {
                    withAnimation(.snappy) {
                        hasCompletedOnboarding = true
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: showSplash)
        .animation(.easeInOut(duration: 0.35), value: showLogin)
        .onAppear {
            // Returning user: skip login, show 1-second splash then go straight to app
            if hasCompletedOnboarding {
                showSplash = true
                showLogin = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSplash = false
                    }
                }
            }
        }
        .onChange(of: hasCompletedOnboarding) { _, newValue in
            // Account deleted → return to login screen
            if !newValue {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showLogin = true
                }
            }
        }
    }
}
