import SwiftUI
import AppTrackingTransparency

struct AgeStep: View {
    @Environment(LanguageManager.self) private var lang
    @Binding var profile: UserProfile

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 12) {
                AroiCalHeader()
                Text(firstName.isEmpty
                     ? lang.t("How Old Are You?", thai: "คุณอายุเท่าไหร่?", japanese: "おいくつですか？")
                     : lang.t("How Old Are You, \(firstName)?", thai: "\(firstName) อายุเท่าไหร่?", japanese: "\(firstName)さん、おいくつですか？"))
                    .font(.title.bold())

                Text(lang.t("This helps us personalize your plan", thai: "ช่วยให้เราปรับแผนให้เหมาะกับคุณ", japanese: "あなたに合ったプランを作成します"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(profile.age)")
                .font(.system(size: 96, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.72, blue: 0)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .contentTransition(.numericText(value: Double(profile.age)))
                .animation(.snappy, value: profile.age)

            Text(lang.t("years old", thai: "ปี", japanese: "歳"))
                .font(.title3)
                .foregroundStyle(.secondary)
                .padding(.top, 4)

            Spacer()

            VStack(spacing: 8) {
                Slider(value: Binding(
                    get: { Double(profile.age) },
                    set: { profile.age = Int($0) }
                ), in: 14...80, step: 1)
                .tint(Color(red: 1, green: 0.42, blue: 0.21))

                HStack {
                    Text("14")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Spacer()
                    Text("80")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .padding(.horizontal, 24)
        .task {
            try? await Task.sleep(for: .milliseconds(800))
            ATTrackingManager.requestTrackingAuthorization { _ in }
        }
    }

    private var firstName: String {
        let t = profile.name.trimmingCharacters(in: .whitespaces)
        return t.components(separatedBy: " ").first ?? t
    }
}
