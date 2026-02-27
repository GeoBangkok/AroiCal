import SwiftUI

struct WeeklyGoalStep: View {
    @Environment(LanguageManager.self) private var lang
    @Binding var profile: UserProfile

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 12) {
                AroiCalHeader()
                Text(firstName.isEmpty
                     ? lang.t("Weekly Goal", thai: "เป้าหมายรายสัปดาห์", japanese: "週間目標")
                     : lang.t("\(firstName)'s Weekly Goal", thai: "เป้าหมายรายสัปดาห์ของ\(firstName)", japanese: "\(firstName)さんの週間目標"))
                    .font(.title.bold())
                Text(lang.t("How fast do you want to progress?", thai: "คุณต้องการก้าวหน้าเร็วแค่ไหน?", japanese: "どのくらいのペースで進めたいですか？"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 24) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", profile.weeklyLossKg))
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                        .animation(.snappy, value: profile.weeklyLossKg)
                    Text(lang.t("kg/week", thai: "กก./สัปดาห์", japanese: "kg/週"))
                        .font(.title2.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                paceIndicator

                VStack(spacing: 8) {
                    Slider(value: $profile.weeklyLossKg, in: 0.1...1.5, step: 0.1)
                        .tint(Color(red: 1, green: 0.42, blue: 0.21))
                    HStack {
                        Text(lang.t("Slow", thai: "ช้า", japanese: "ゆっくり"))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Spacer()
                        Text(lang.t("Fast", thai: "เร็ว", japanese: "速い"))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
        .sensoryFeedback(.selection, trigger: Int(profile.weeklyLossKg * 10))
    }

    private var paceIndicator: some View {
        let pace: (String, String, String, String)
        if profile.weeklyLossKg <= 0.3 {
            pace = ("tortoise", lang.t("Gentle & Sustainable", thai: "ค่อยเป็นค่อยไป", japanese: "ゆるやかで持続可能"), "green", "")
        } else if profile.weeklyLossKg <= 0.7 {
            pace = ("hare", lang.t("Recommended", thai: "แนะนำ", japanese: "おすすめ"), "orange", "")
        } else {
            pace = ("bolt.fill", lang.t("Aggressive", thai: "เข้มข้น", japanese: "積極的"), "red", "")
        }

        return HStack(spacing: 8) {
            Image(systemName: pace.0)
                .foregroundStyle(pace.2 == "green" ? .green : pace.2 == "orange" ? .orange : .red)
            Text(pace.1)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(.ultraThinMaterial, in: .capsule)
    }

    private var firstName: String {
        let t = profile.name.trimmingCharacters(in: .whitespaces)
        return t.components(separatedBy: " ").first ?? t
    }
}
