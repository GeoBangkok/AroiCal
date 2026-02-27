import SwiftUI
import SuperwallKit

struct OnboardingContainerView: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(UserProfileManager.self) private var profileManager
    @StateObject private var storeManager = StoreManager.shared
    @State private var currentStep: Int = 0
    @State private var profile = UserProfile()
    @State private var showLoading: Bool = false
    @State private var loadingDone: Bool = false
    let onComplete: () -> Void

    private let totalSteps = 16

    private var firstName: String {
        let t = profile.name.trimmingCharacters(in: .whitespaces)
        return t.components(separatedBy: " ").first ?? t
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                if !showLoading {
                    HStack {
                        if currentStep > 0 {
                            Button {
                                withAnimation(.snappy) {
                                    if loadingDone && currentStep == 15 {
                                        currentStep = 14
                                        loadingDone = false
                                    } else {
                                        currentStep -= 1
                                    }
                                }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(.primary)
                            }
                        } else {
                            Color.clear.frame(width: 24, height: 24)
                        }
                        Spacer()
                        ProgressDots(current: currentStep, total: totalSteps)
                        Spacer()
                        LanguageFlagButton()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }

                if showLoading {
                    PlanLoadingStep {
                        withAnimation(.snappy) {
                            showLoading = false
                            loadingDone = true
                            currentStep = 15
                        }
                    }
                    .environment(lang)
                } else {
                    TabView(selection: $currentStep) {
                        NameStep(profile: $profile)
                            .tag(0)

                        AgeStep(profile: $profile)
                            .tag(1)

                        GenderStep(profile: $profile)
                            .tag(2)

                        HeightStep(profile: $profile)
                            .tag(3)

                        CurrentWeightStep(profile: $profile)
                            .tag(4)

                        DesiredWeightStep(profile: $profile)
                            .tag(5)

                        WeeklyGoalStep(profile: $profile)
                            .tag(6)

                        ActivityGoalStep(profile: $profile)
                            .tag(7)

                        DifficultiesStep(profile: $profile)
                            .tag(8)

                        WeightLossGraphicStep(name: firstName)
                            .tag(9)

                        DietGoalsStep(profile: $profile)
                            .tag(10)

                        GoalsGraphicStep(name: firstName)
                            .tag(11)

                        CreatorReferralStep(profile: $profile)
                            .tag(12)

                        NotificationsStep(name: firstName)
                            .tag(13)

                        ReviewsStep()
                            .tag(14)

                        PersonalizedPlanStep(profile: profile)
                            .tag(15)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.snappy, value: currentStep)
                }

                if !showLoading {
                    Button {
                        withAnimation(.snappy) {
                            if currentStep == 14 && !loadingDone {
                                profileManager.profile = profile
                                profileManager.applyCalculatedTargets()
                                showLoading = true
                            } else if currentStep < 15 {
                                currentStep += 1
                            } else {
                                // Trigger Superwall paywall at end of onboarding
                                triggerPaywall()
                            }
                        }
                    } label: {
                        Text(buttonText)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.72, blue: 0)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: .rect(cornerRadius: 16)
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }
            }
        }
    }

    private var buttonText: String {
        if currentStep == 15 {
            return lang.t("Get Started", thai: "เริ่มต้นใช้งาน", japanese: "始める")
        }
        return lang.t("Continue", thai: "ต่อไป", japanese: "続ける")
    }

    private func triggerPaywall() {
        Task {
            // Register paywall presentation event
            Superwall.shared.register(placement: "onboarding_complete")

            // Check if user is subscribed
            await storeManager.checkSubscriptionStatus()

            // Complete onboarding regardless of subscription status
            onComplete()
        }
    }
}

struct ProgressDots: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index <= current ? Color(red: 1, green: 0.42, blue: 0.21) : Color(.systemGray4))
                    .frame(width: index == current ? 20 : 6, height: 6)
                    .animation(.snappy, value: current)
            }
        }
    }
}
