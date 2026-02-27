import SwiftUI

struct DietGoalsStep: View {
    @Environment(LanguageManager.self) private var lang
    @Binding var profile: UserProfile

    private var goals: [(id: String, icon: String, en: String, th: String, jp: String, desc: String, descTh: String, descJp: String)] {
        [
            ("lose", "arrow.down.heart", "Lose Weight", "ลดน้ำหนัก", "減量する",
             "Burn fat and slim down", "เผาผลาญไขมันและลดหุ่น", "脂肪を燃焼してスリムに"),
            ("gain", "arrow.up.heart", "Gain Weight", "เพิ่มน้ำหนัก", "体重を増やす",
             "Build muscle and mass", "สร้างกล้ามเนื้อและมวลกาย", "筋肉と体重を増やす"),
            ("toned", "figure.strengthtraining.functional", "Stay Toned", "รักษาหุ่น", "引き締まった体を維持",
             "Maintain and sculpt your body", "รักษาและกระชับหุ่น", "体を維持し引き締める"),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(spacing: 8) {
                    AroiCalHeader()

                    Text(firstName.isEmpty
                         ? lang.t("What's Your Main Goal?", thai: "เป้าหมายหลักของคุณคืออะไร?", japanese: "あなたのメインゴールは？")
                         : lang.t("What's \(firstName)'s Main Goal?", thai: "เป้าหมายหลักของ\(firstName)คืออะไร?", japanese: "\(firstName)さんのメインゴールは？"))
                        .font(.title.bold())
                        .multilineTextAlignment(.center)

                    Text(lang.t("We'll create the perfect plan for you", thai: "เราจะสร้างแผนที่เหมาะกับคุณ", japanese: "あなたに最適なプランを作成します"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)

                VStack(spacing: 12) {
                    ForEach(goals, id: \.id) { goal in
                        let isSelected = profile.dietGoal == goal.id
                        Button {
                            withAnimation(.snappy) {
                                profile.dietGoal = goal.id
                            }
                        } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            isSelected
                                                ? AnyShapeStyle(LinearGradient(
                                                    colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.72, blue: 0)],
                                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                                ))
                                                : AnyShapeStyle(Color(red: 1, green: 0.42, blue: 0.21).opacity(0.12))
                                        )
                                        .frame(width: 52, height: 52)

                                    Image(systemName: goal.icon)
                                        .font(.title3)
                                        .foregroundStyle(isSelected ? .white : Color(red: 1, green: 0.42, blue: 0.21))
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(lang.t(goal.en, thai: goal.th, japanese: goal.jp))
                                        .font(.headline)
                                        .foregroundStyle(.primary)

                                    Text(lang.t(goal.desc, thai: goal.descTh, japanese: goal.descJp))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .font(.title2)
                                    .foregroundStyle(isSelected ? Color(red: 1, green: 0.42, blue: 0.21) : Color(.systemGray3))
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.secondarySystemGroupedBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .strokeBorder(
                                                isSelected ? Color(red: 1, green: 0.42, blue: 0.21) : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                            )
                        }
                        .sensoryFeedback(.selection, trigger: isSelected)
                    }
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 100)
            }
        }
    }

    private var firstName: String {
        let t = profile.name.trimmingCharacters(in: .whitespaces)
        return t.components(separatedBy: " ").first ?? t
    }
}
