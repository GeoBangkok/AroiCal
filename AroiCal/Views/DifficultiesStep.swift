import SwiftUI

struct DifficultiesStep: View {
    @Environment(LanguageManager.self) private var lang
    @Binding var profile: UserProfile

    private var difficulties: [(id: String, icon: String, en: String, th: String, jp: String)] {
        [
            ("portions", "takeoutbag.and.cup.and.straw", "Controlling portions", "ควบคุมปริมาณอาหาร", "食事量のコントロール"),
            ("snacking", "moon.stars", "Late night snacking", "กินดึก", "夜食"),
            ("emotional", "heart.circle", "Emotional eating", "กินตามอารมณ์", "感情的な食事"),
            ("motivation", "bolt.slash", "Lack of motivation", "ขาดแรงจูงใจ", "モチベーション不足"),
            ("busy", "clock", "Too busy to cook", "ไม่มีเวลาทำอาหาร", "料理する時間がない"),
            ("knowledge", "questionmark.circle", "Not knowing what to eat", "ไม่รู้ว่าควรกินอะไร", "何を食べるべきかわからない"),
            ("cravings", "birthday.cake", "Sweet cravings", "อยากของหวาน", "甘いもの欲"),
            ("eating_out", "fork.knife.circle", "Eating out too often", "กินนอกบ้านบ่อย", "外食が多い"),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    AroiCalHeader()

                    Text(lang.t("What's Holding You Back?", thai: "อะไรที่ถ่วงคุณอยู่?", japanese: "何が障壁ですか？"))
                        .font(.title.bold())
                        .multilineTextAlignment(.center)

                    Text(lang.t("Select all that apply", thai: "เลือกทั้งหมดที่ตรงกับคุณ", japanese: "当てはまるものをすべて選択"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(difficulties, id: \.id) { item in
                        let isSelected = profile.difficulties.contains(item.id)
                        Button {
                            withAnimation(.snappy) {
                                if isSelected {
                                    profile.difficulties.removeAll { $0 == item.id }
                                } else {
                                    profile.difficulties.append(item.id)
                                }
                            }
                        } label: {
                            VStack(spacing: 10) {
                                Image(systemName: item.icon)
                                    .font(.title2)
                                    .foregroundStyle(isSelected ? .white : Color(red: 1, green: 0.42, blue: 0.21))

                                Text(lang.t(item.en, thai: item.th, japanese: item.jp))
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(isSelected ? .white : .primary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .background(
                                isSelected
                                    ? AnyShapeStyle(LinearGradient(
                                        colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.55, blue: 0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    : AnyShapeStyle(Color(.secondarySystemGroupedBackground)),
                                in: .rect(cornerRadius: 16)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(
                                        isSelected ? Color.clear : Color(.systemGray4),
                                        lineWidth: 1
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
}
