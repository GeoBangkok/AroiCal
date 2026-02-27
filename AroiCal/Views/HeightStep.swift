import SwiftUI

struct HeightStep: View {
    @Environment(LanguageManager.self) private var lang
    @Binding var profile: UserProfile

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 12) {
                AroiCalHeader()
                Text(firstName.isEmpty
                     ? lang.t("How Tall Are You?", thai: "คุณสูงเท่าไหร่?", japanese: "身長は？")
                     : lang.t("How Tall Are You, \(firstName)?", thai: "\(firstName) สูงเท่าไหร่?", japanese: "\(firstName)さんの身長は？"))
                    .font(.title.bold())
                Text(lang.t("This helps us calculate your needs", thai: "ช่วยให้เราคำนวณความต้องการของคุณ", japanese: "あなたのニーズを計算するのに役立ちます"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 24) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(Int(profile.heightCm))")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                        .animation(.snappy, value: Int(profile.heightCm))
                    Text(lang.t("cm", thai: "ซม.", japanese: "cm"))
                        .font(.title2.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 8) {
                    Slider(value: $profile.heightCm, in: 120...220, step: 1)
                        .tint(Color(red: 1, green: 0.42, blue: 0.21))
                    HStack {
                        Text("120")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Spacer()
                        Text("220")
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
        .sensoryFeedback(.selection, trigger: Int(profile.heightCm))
    }

    private var firstName: String {
        let t = profile.name.trimmingCharacters(in: .whitespaces)
        return t.components(separatedBy: " ").first ?? t
    }
}
