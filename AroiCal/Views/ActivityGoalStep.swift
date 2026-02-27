import SwiftUI

struct ActivityGoalStep: View {
    @Environment(LanguageManager.self) private var lang
    @Binding var profile: UserProfile

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(spacing: 8) {
                    AroiCalHeader()
                    Text(firstName.isEmpty
                         ? lang.t("Activity & Goal", thai: "กิจกรรมและเป้าหมาย", japanese: "活動と目標")
                         : lang.t("\(firstName)'s Activity & Goal", thai: "กิจกรรมและเป้าหมายของ\(firstName)", japanese: "\(firstName)さんの活動と目標"))
                        .font(.title.bold())

                    Text(lang.t("Help us personalize your plan", thai: "ช่วยเราปรับแต่งแผนของคุณ", japanese: "プランをカスタマイズします"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)

                VStack(alignment: .leading, spacing: 12) {
                    Text(lang.t("Activity Level", thai: "ระดับกิจกรรม", japanese: "活動レベル"))
                        .font(.headline)
                        .padding(.horizontal, 24)

                    VStack(spacing: 8) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            Button {
                                profile.activityLevel = level
                            } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: activityIcon(level))
                                        .font(.title3)
                                        .foregroundStyle(profile.activityLevel == level ? .white : Color(red: 1, green: 0.42, blue: 0.21))
                                        .frame(width: 40, height: 40)
                                        .background(
                                            profile.activityLevel == level
                                                ? Color(red: 1, green: 0.42, blue: 0.21)
                                                : Color(red: 1, green: 0.42, blue: 0.21).opacity(0.12),
                                            in: .rect(cornerRadius: 10)
                                        )

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(activityLabel(level))
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.primary)

                                        Text(activityDesc(level))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    if profile.activityLevel == level {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))
                                    }
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(.secondarySystemGroupedBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .strokeBorder(
                                                    profile.activityLevel == level
                                                        ? Color(red: 1, green: 0.42, blue: 0.21)
                                                        : Color.clear,
                                                    lineWidth: 2
                                                )
                                        )
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(lang.t("Your Goal", thai: "เป้าหมายของคุณ", japanese: "あなたの目標"))
                        .font(.headline)
                        .padding(.horizontal, 24)

                    HStack(spacing: 10) {
                        ForEach(GoalType.allCases, id: \.self) { goal in
                            Button {
                                profile.goal = goal
                            } label: {
                                VStack(spacing: 10) {
                                    Image(systemName: goalIcon(goal))
                                        .font(.title2)

                                    Text(goalLabel(goal))
                                        .font(.caption.weight(.semibold))
                                }
                                .foregroundStyle(profile.goal == goal ? .white : .primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 90)
                                .background(
                                    profile.goal == goal
                                        ? AnyShapeStyle(LinearGradient(
                                            colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.72, blue: 0)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        : AnyShapeStyle(Color(.secondarySystemGroupedBackground)),
                                    in: .rect(cornerRadius: 14)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer(minLength: 100)
            }
        }
    }

    private func activityIcon(_ level: ActivityLevel) -> String {
        switch level {
        case .sedentary: return "figure.seated.side"
        case .light: return "figure.walk"
        case .moderate: return "figure.run"
        case .active: return "figure.hiking"
        case .veryActive: return "figure.strengthtraining.traditional"
        }
    }

    private func activityLabel(_ level: ActivityLevel) -> String {
        switch level {
        case .sedentary: return lang.t("Sedentary", thai: "นั่งทำงาน", japanese: "座りがち")
        case .light: return lang.t("Lightly Active", thai: "ออกกำลังเล็กน้อย", japanese: "軽い運動")
        case .moderate: return lang.t("Moderately Active", thai: "ออกกำลังปานกลาง", japanese: "中程度の運動")
        case .active: return lang.t("Active", thai: "ออกกำลังมาก", japanese: "活発")
        case .veryActive: return lang.t("Very Active", thai: "ออกกำลังหนักมาก", japanese: "非常に活発")
        }
    }

    private func activityDesc(_ level: ActivityLevel) -> String {
        switch level {
        case .sedentary: return lang.t("Little to no exercise", thai: "แทบไม่ได้ออกกำลังกาย", japanese: "ほとんど運動しない")
        case .light: return lang.t("1-3 days/week", thai: "1-3 วัน/สัปดาห์", japanese: "週1-3日")
        case .moderate: return lang.t("3-5 days/week", thai: "3-5 วัน/สัปดาห์", japanese: "週3-5日")
        case .active: return lang.t("6-7 days/week", thai: "6-7 วัน/สัปดาห์", japanese: "週6-7日")
        case .veryActive: return lang.t("Athlete / physical job", thai: "นักกีฬา / งานใช้แรง", japanese: "アスリート/肉体労働")
        }
    }

    private func goalIcon(_ goal: GoalType) -> String {
        switch goal {
        case .lose: return "arrow.down.circle"
        case .maintain: return "equal.circle"
        case .gain: return "arrow.up.circle"
        }
    }

    private func goalLabel(_ goal: GoalType) -> String {
        switch goal {
        case .lose: return lang.t("Lose\nWeight", thai: "ลด\nน้ำหนัก", japanese: "減量")
        case .maintain: return lang.t("Maintain\nWeight", thai: "รักษา\nน้ำหนัก", japanese: "維持")
        case .gain: return lang.t("Gain\nWeight", thai: "เพิ่ม\nน้ำหนัก", japanese: "増量")
        }
    }

    private var firstName: String {
        let t = profile.name.trimmingCharacters(in: .whitespaces)
        return t.components(separatedBy: " ").first ?? t
    }
}
