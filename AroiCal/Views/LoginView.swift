import SwiftUI

// MARK: - LoginView
struct LoginView: View {
    @Environment(LanguageManager.self) private var lang
    var onGetStarted: () -> Void

    @State private var cardOffset: CGFloat = 340
    @State private var imageScale: CGFloat = 1.08

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {

                // ── Hero image ──────────────────────────────────────────────
                Image("HeroImage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .scaleEffect(imageScale)
                    .ignoresSafeArea()

                // Subtle bottom scrim so the card edge reads cleanly
                LinearGradient(
                    colors: [.clear, .black.opacity(0.18)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // ── Bottom card ─────────────────────────────────────────────
                VStack(alignment: .leading, spacing: 0) {

                    // Drag indicator
                    Capsule()
                        .fill(Color(.systemGray4))
                        .frame(width: 36, height: 4)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 14)
                        .padding(.bottom, 26)

                    // App name
                    Text("AroiCal")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)

                    // Thai tagline
                    Text(lang.t(
                        "Your AI calorie tracker",
                        thai: "ติดตามแคลอรี่ด้วย AI",
                        japanese: "AIカロリートラッカー"
                    ))
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color(.secondaryLabel))
                    .padding(.top, 5)

                    // English secondary line (shown in all languages)
                    if lang.current != .english {
                        Text("scan your calories")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color(.tertiaryLabel))
                            .padding(.top, 2)
                    }

                    // Feature pills
                    HStack(spacing: 8) {
                        featurePill(
                            icon: "camera.fill",
                            text: lang.t("Scan Food", thai: "สแกนอาหาร", japanese: "食事スキャン")
                        )
                        featurePill(
                            icon: "chart.bar.fill",
                            text: lang.t("Track Progress", thai: "ติดตามผล", japanese: "進捗記録")
                        )
                        featurePill(
                            icon: "flame.fill",
                            text: lang.t("Streak", thai: "ต่อเนื่อง", japanese: "連続記録")
                        )
                    }
                    .padding(.top, 20)

                    Spacer(minLength: 20)

                    // CTA button
                    Button(action: onGetStarted) {
                        Text(lang.t(
                            "Get Started",
                            thai: "เริ่มต้นเลย",
                            japanese: "始めましょう"
                        ))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.black, in: .rect(cornerRadius: 16))
                    }

                    // Bottom safe-area pad
                    Spacer()
                        .frame(height: max(geo.safeAreaInsets.bottom, 20) + 8)
                }
                .padding(.horizontal, 28)
                .frame(height: geo.size.height * 0.46)
                .background(
                    Color.white
                        .clipShape(.rect(topLeadingRadius: 38, bottomLeadingRadius: 0,
                                         bottomTrailingRadius: 0, topTrailingRadius: 38))
                        .shadow(color: .black.opacity(0.14), radius: 24, x: 0, y: -6)
                )
                .offset(y: cardOffset)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.spring(duration: 0.75, bounce: 0.08).delay(0.15)) {
                cardOffset = 0
            }
            withAnimation(.easeOut(duration: 1.2).delay(0.1)) {
                imageScale = 1.0
            }
        }
    }

    @ViewBuilder
    private func featurePill(icon: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(.secondaryLabel))
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 7)
        .background(Color(.systemGray6), in: .capsule)
    }
}
