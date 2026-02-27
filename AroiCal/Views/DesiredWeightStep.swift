import SwiftUI

struct DesiredWeightStep: View {
    @Environment(LanguageManager.self) private var lang
    @Binding var profile: UserProfile

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 12) {
                AroiCalHeader()
                Text(firstName.isEmpty
                     ? lang.t("Goal Weight", thai: "น้ำหนักเป้าหมาย", japanese: "目標体重")
                     : lang.t("\(firstName)'s Goal Weight", thai: "น้ำหนักเป้าหมายของ\(firstName)", japanese: "\(firstName)さんの目標体重"))
                    .font(.title.bold())
                Text(lang.t("What weight do you want to reach?", thai: "คุณต้องการน้ำหนักเท่าไหร่?", japanese: "目標の体重は？"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 24) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", profile.desiredWeightKg))
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                        .animation(.snappy, value: profile.desiredWeightKg)
                    Text(lang.t("kg", thai: "กก.", japanese: "kg"))
                        .font(.title2.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                let diff = profile.weightKg - profile.desiredWeightKg
                if abs(diff) > 0.1 {
                    HStack(spacing: 6) {
                        Image(systemName: diff > 0 ? "arrow.down.right" : "arrow.up.right")
                            .foregroundStyle(diff > 0 ? .green : .orange)
                        Text(String(format: "%.1f %@", abs(diff), lang.t("kg to go", thai: "กก. ที่ต้องลด", japanese: "kg の差")))
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(.ultraThinMaterial, in: .capsule)
                }

                VStack(spacing: 8) {
                    Slider(value: $profile.desiredWeightKg, in: 30...200, step: 0.5)
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
        .sensoryFeedback(.selection, trigger: Int(profile.desiredWeightKg * 2))
    }

    private var firstName: String {
        let t = profile.name.trimmingCharacters(in: .whitespaces)
        return t.components(separatedBy: " ").first ?? t
    }
}
