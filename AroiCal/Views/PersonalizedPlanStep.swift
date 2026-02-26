import SwiftUI

struct PersonalizedPlanStep: View {
    @Environment(LanguageManager.self) private var lang
    let profile: UserProfile

    private var calories: Int { profile.calculateTDEE() }
    private var macros: (protein: Int, carbs: Int, fat: Int) { profile.calculateMacros() }
    private var weightDiff: Double { abs(profile.weightKg - profile.desiredWeightKg) }
    private var weeksToGoal: Int { profile.weeklyLossKg > 0 ? max(1, Int(ceil(weightDiff / profile.weeklyLossKg))) : 0 }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    AroiCalHeader()

                    Image(systemName: "sparkles")
                        .font(.largeTitle)
                        .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))
                        .symbolEffect(.bounce, value: true)

                    Text(lang.t("Your Plan is Ready!", thai: "แผนของคุณพร้อมแล้ว!", japanese: "プランが完成しました！"))
                        .font(.title.bold())

                    Text(lang.t("Based on your profile, here's your daily target", thai: "จากข้อมูลของคุณ นี่คือเป้าหมายรายวัน", japanese: "あなたのプロフィールに基づく毎日の目標"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)

                VStack(spacing: 4) {
                    Text("\(calories)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.72, blue: 0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text(lang.t("calories / day", thai: "แคลอรี / วัน", japanese: "カロリー / 日"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    MacroTargetCard(
                        name: lang.t("Protein", thai: "โปรตีน", japanese: "タンパク質"),
                        grams: macros.protein,
                        color: Color(red: 0.35, green: 0.67, blue: 1)
                    )

                    MacroTargetCard(
                        name: lang.t("Carbs", thai: "คาร์บ", japanese: "炭水化物"),
                        grams: macros.carbs,
                        color: Color(red: 1, green: 0.42, blue: 0.21)
                    )

                    MacroTargetCard(
                        name: lang.t("Fat", thai: "ไขมัน", japanese: "脂質"),
                        grams: macros.fat,
                        color: Color(red: 1, green: 0.72, blue: 0)
                    )
                }
                .padding(.horizontal, 24)

                if profile.goal == .lose && weightDiff > 0 {
                    weightLossProjection
                        .padding(.horizontal, 24)
                }

                aroiCalAdvantage
                    .padding(.horizontal, 24)

                Spacer(minLength: 100)
            }
        }
    }

    private var weightLossProjection: some View {
        VStack(spacing: 14) {
            HStack {
                Text(lang.t("Your Journey", thai: "เส้นทางของคุณ", japanese: "あなたの旅"))
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(weeksToGoal) \(lang.t("weeks", thai: "สัปดาห์", japanese: "週間"))")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(red: 1, green: 0.42, blue: 0.21).opacity(0.12), in: .capsule)
            }

            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text(String(format: "%.1f", profile.weightKg))
                        .font(.title3.weight(.bold))
                    Text(lang.t("Now", thai: "ตอนนี้", japanese: "現在"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.systemGray5))
                            .frame(height: 8)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 0.2, green: 0.78, blue: 0.35)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * 0.65, height: 8)

                        Image(systemName: "figure.run")
                            .font(.caption)
                            .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))
                            .offset(x: geo.size.width * 0.6, y: -14)
                    }
                }
                .frame(height: 8)

                VStack(spacing: 4) {
                    Text(String(format: "%.1f", profile.desiredWeightKg))
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color(red: 0.2, green: 0.78, blue: 0.35))
                    Text(lang.t("Goal", thai: "เป้า", japanese: "目標"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
    }

    private var aroiCalAdvantage: some View {
        VStack(spacing: 14) {
            Text(lang.t("Aroi Cal Users See Better Results", thai: "ผู้ใช้ Aroi Cal เห็นผลลัพธ์ที่ดีกว่า", japanese: "Aroi Calユーザーはより良い結果を得ています"))
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.center)

            HStack(spacing: 24) {
                VStack(spacing: 8) {
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.systemGray5))
                            .frame(width: 40, height: 80)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.systemGray3))
                            .frame(width: 40, height: 35)
                    }
                    Text(lang.t("Without\nTracking", thai: "ไม่ติดตาม", japanese: "追跡なし"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 8) {
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.systemGray5))
                            .frame(width: 40, height: 80)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.72, blue: 0)],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(width: 40, height: 70)
                    }
                    Text(lang.t("With\nAroi Cal", thai: "ใช้\nAroi Cal", japanese: "Aroi Cal\n使用"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            HStack(spacing: 6) {
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color(red: 0.2, green: 0.78, blue: 0.35))

                Text(lang.t("2x more likely to reach your goal", thai: "โอกาสถึงเป้าหมายมากกว่า 2 เท่า", japanese: "目標達成率2倍"))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color(red: 0.2, green: 0.78, blue: 0.35))
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
    }
}

struct MacroTargetCard: View {
    let name: String
    let grams: Int
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text("\(grams)g")
                .font(.title2.weight(.bold))

            Text(name)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(color.opacity(0.12), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(color.opacity(0.3), lineWidth: 1)
        )
    }
}
