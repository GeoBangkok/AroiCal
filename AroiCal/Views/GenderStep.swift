import SwiftUI

struct GenderStep: View {
    @Environment(LanguageManager.self) private var lang
    @Binding var profile: UserProfile

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 12) {
                AroiCalHeader()
                Text(firstName.isEmpty
                     ? lang.t("What's Your Gender?", thai: "คุณเป็นเพศอะไร?", japanese: "性別を教えてください")
                     : lang.t("What's Your Gender, \(firstName)?", thai: "\(firstName) เป็นเพศอะไร?", japanese: "\(firstName)さんの性別は？"))
                    .font(.title.bold())

                Text(lang.t("This affects your calorie calculation", thai: "มีผลต่อการคำนวณแคลอรี่", japanese: "カロリー計算に影響します"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(spacing: 16) {
                ForEach(Gender.allCases, id: \.self) { gender in
                    Button {
                        withAnimation(.snappy) {
                            profile.gender = gender
                        }
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: genderIcon(gender))
                                .font(.title)
                                .frame(width: 44)

                            Text(genderLabel(gender))
                                .font(.title3.weight(.semibold))

                            Spacer()

                            Image(systemName: profile.gender == gender ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .foregroundStyle(
                                    profile.gender == gender
                                        ? Color(red: 1, green: 0.42, blue: 0.21)
                                        : Color(.tertiaryLabel)
                                )
                        }
                        .foregroundStyle(profile.gender == gender ? .primary : .secondary)
                        .padding(20)
                        .background(
                            profile.gender == gender
                                ? AnyShapeStyle(
                                    LinearGradient(
                                        colors: [Color(red: 1, green: 0.42, blue: 0.21).opacity(0.15), Color(red: 1, green: 0.72, blue: 0).opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                : AnyShapeStyle(Color(.secondarySystemGroupedBackground)),
                            in: .rect(cornerRadius: 16)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    profile.gender == gender
                                        ? Color(red: 1, green: 0.42, blue: 0.21).opacity(0.5)
                                        : .clear,
                                    lineWidth: 2
                                )
                        )
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()
            Spacer()
        }
    }

    private func genderIcon(_ gender: Gender) -> String {
        switch gender {
        case .male: return "figure.stand"
        case .female: return "figure.stand.dress"
        case .other: return "figure.wave"
        }
    }

    private var firstName: String {
        let t = profile.name.trimmingCharacters(in: .whitespaces)
        return t.components(separatedBy: " ").first ?? t
    }

    private func genderLabel(_ gender: Gender) -> String {
        switch gender {
        case .male: return lang.t("Male", thai: "ชาย", japanese: "男性")
        case .female: return lang.t("Female", thai: "หญิง", japanese: "女性")
        case .other: return lang.t("Other", thai: "อื่นๆ", japanese: "その他")
        }
    }
}
