import SwiftUI

struct GoalsGraphicStep: View {
    @Environment(LanguageManager.self) private var lang
    @State private var animateIn: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(spacing: 8) {
                    AroiCalHeader()

                    Text(lang.t("Your Unique Mix", thai: "สูตรเฉพาะของคุณ", japanese: "あなただけのミックス"))
                        .font(.title.bold())
                        .multilineTextAlignment(.center)

                    Text(lang.t("Aroi Cal adapts to every goal", thai: "Aroi Cal ปรับตัวกับทุกเป้าหมาย", japanese: "Aroi Calはすべての目標に適応"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 1, green: 0.42, blue: 0.21).opacity(0.15),
                                    Color(red: 1, green: 0.72, blue: 0).opacity(0.05),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 140
                            )
                        )
                        .frame(width: 280, height: 280)
                        .scaleEffect(animateIn ? 1 : 0.5)
                        .opacity(animateIn ? 1 : 0)

                    ForEach(Array(goalItems.enumerated()), id: \.offset) { index, item in
                        let angle = Double(index) * (360.0 / Double(goalItems.count)) - 90
                        let radius: CGFloat = 100

                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(item.color.opacity(0.15))
                                    .frame(width: 56, height: 56)

                                Image(systemName: item.icon)
                                    .font(.title3)
                                    .foregroundStyle(item.color)
                            }
                            Text(lang.t(item.en, thai: item.th, japanese: item.jp))
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .frame(width: 70)
                        }
                        .offset(
                            x: cos(angle * .pi / 180) * radius,
                            y: sin(angle * .pi / 180) * radius
                        )
                        .scaleEffect(animateIn ? 1 : 0)
                        .opacity(animateIn ? 1 : 0)
                    }

                    VStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.title)
                            .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))
                        Text("AROI CAL")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))
                    }
                    .scaleEffect(animateIn ? 1 : 0.5)
                }
                .frame(height: 300)

                VStack(spacing: 14) {
                    featureRow(
                        icon: "brain.head.profile",
                        text: lang.t("AI-powered meal analysis", thai: "วิเคราะห์มื้ออาหารด้วย AI", japanese: "AI搭載の食事分析")
                    )
                    featureRow(
                        icon: "chart.line.uptrend.xyaxis",
                        text: lang.t("Adaptive calorie targets", thai: "เป้าหมายแคลอรีที่ปรับได้", japanese: "適応型カロリー目標")
                    )
                    featureRow(
                        icon: "person.crop.circle.badge.checkmark",
                        text: lang.t("Personalized macro ratios", thai: "สัดส่วนมาโครเฉพาะบุคคล", japanese: "パーソナライズされたマクロ比率")
                    )
                    featureRow(
                        icon: "trophy",
                        text: lang.t("Goal-specific meal suggestions", thai: "แนะนำอาหารตามเป้าหมาย", japanese: "目標に合わせた食事提案")
                    )
                }
                .padding(20)
                .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 20))
                .padding(.horizontal, 24)

                Spacer(minLength: 100)
            }
        }
        .task {
            withAnimation(.spring(duration: 0.8, bounce: 0.3)) {
                animateIn = true
            }
        }
    }

    private var goalItems: [(icon: String, en: String, th: String, jp: String, color: Color)] {
        [
            ("flame.fill", "Fat Burn", "เผาผลาญ", "脂肪燃焼", Color(red: 1, green: 0.42, blue: 0.21)),
            ("figure.strengthtraining.traditional", "Muscle", "กล้ามเนื้อ", "筋肉", Color(red: 0.35, green: 0.67, blue: 1)),
            ("heart.fill", "Health", "สุขภาพ", "健康", Color(red: 0.96, green: 0.26, blue: 0.4)),
            ("bolt.fill", "Energy", "พลังงาน", "エネルギー", Color(red: 1, green: 0.72, blue: 0)),
            ("leaf.fill", "Nutrition", "โภชนาการ", "栄養", Color(red: 0.2, green: 0.78, blue: 0.35)),
        ]
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))
                .frame(width: 28)

            Text(text)
                .font(.subheadline)

            Spacer()

            Image(systemName: "checkmark")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(red: 0.2, green: 0.78, blue: 0.35))
        }
    }
}
