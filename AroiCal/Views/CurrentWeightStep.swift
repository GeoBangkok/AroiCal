import SwiftUI

struct CurrentWeightStep: View {
    @Environment(LanguageManager.self) private var lang
    @Binding var profile: UserProfile

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 12) {
                AroiCalHeader()
                Text(lang.t("Current Weight", thai: "น้ำหนักปัจจุบัน", japanese: "現在の体重"))
                    .font(.title.bold())
                Text(lang.t("Where are you starting from?", thai: "คุณเริ่มต้นจากจุดไหน?", japanese: "現在の体重を教えてください"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 24) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", profile.weightKg))
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                        .animation(.snappy, value: profile.weightKg)
                    Text(lang.t("kg", thai: "กก.", japanese: "kg"))
                        .font(.title2.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 8) {
                    Slider(value: $profile.weightKg, in: 30...200, step: 0.5)
                        .tint(Color(red: 1, green: 0.42, blue: 0.21))
                    HStack {
                        Text("30")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Spacer()
                        Text("200")
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
        .sensoryFeedback(.selection, trigger: Int(profile.weightKg * 2))
    }
}
