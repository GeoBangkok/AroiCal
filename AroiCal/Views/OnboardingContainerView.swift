import SwiftUI

struct OnboardingContainerView: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(UserProfileManager.self) private var profileManager
    @State private var currentStep: Int = 0
    @State private var profile = UserProfile()
    @State private var showPaywall: Bool = false
    @State private var showLoading: Bool = false
    @State private var loadingDone: Bool = false
    let onComplete: () -> Void

    private let totalSteps = 15

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                if !showPaywall && !showLoading {
                    HStack {
                        if currentStep > 0 {
                            Button {
                                withAnimation(.snappy) {
                                    if loadingDone && currentStep == 14 {
                                        currentStep = 13
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
                            currentStep = 14
                        }
                    }
                    .environment(lang)
                } else {
                    TabView(selection: $currentStep) {
                        AgeStep(profile: $profile)
                            .tag(0)

                        GenderStep(profile: $profile)
                            .tag(1)

                        HeightStep(profile: $profile)
                            .tag(2)

                        CurrentWeightStep(profile: $profile)
                            .tag(3)

                        DesiredWeightStep(profile: $profile)
                            .tag(4)

                        WeeklyGoalStep(profile: $profile)
                            .tag(5)

                        ActivityGoalStep(profile: $profile)
                            .tag(6)

                        DifficultiesStep(profile: $profile)
                            .tag(7)

                        WeightLossGraphicStep()
                            .tag(8)

                        DietGoalsStep(profile: $profile)
                            .tag(9)

                        GoalsGraphicStep()
                            .tag(10)

                        CreatorReferralStep(profile: $profile)
                            .tag(11)

                        NotificationsStep()
                            .tag(12)

                        ReviewsStep()
                            .tag(13)

                        PersonalizedPlanStep(profile: profile)
                            .tag(14)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.snappy, value: currentStep)
                }

                if !showPaywall && !showLoading {
                    Button {
                        withAnimation(.snappy) {
                            if currentStep == 13 && !loadingDone {
                                profileManager.profile = profile
                                profileManager.applyCalculatedTargets()
                                showLoading = true
                            } else if currentStep < 14 {
                                currentStep += 1
                            } else {
                                showPaywall = true
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
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView {
                onComplete()
            }
            .environment(lang)
        }
    }

    private var buttonText: String {
        if currentStep == 14 {
            return lang.t("Get Started", thai: "เริ่มต้นใช้งาน", japanese: "始める")
        }
        return lang.t("Continue", thai: "ต่อไป", japanese: "続ける")
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
