import SwiftUI

struct BodyMetricsStep: View {
    @Environment(LanguageManager.self) private var lang
    @Binding var profile: UserProfile

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    AroiCalHeader()
                    Text(lang.t("Your Body", thai: "ร่างกายของคุณ", japanese: "あなたの体"))
                        .font(.title.bold())

                    Text(lang.t("We'll use this to calculate your plan", thai: "เราจะใช้ข้อมูลนี้เพื่อคำนวณแผนของคุณ", japanese: "プランの計算に使用します"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)

                VStack(spacing: 16) {
                    MetricCard(
                        title: lang.t("Height", thai: "ส่วนสูง", japanese: "身長"),
                        value: "\(Int(profile.heightCm))",
                        unit: lang.t("cm", thai: "ซม.", japanese: "cm"),
                        icon: "ruler"
                    ) {
                        Slider(value: $profile.heightCm, in: 120...220, step: 1)
                            .tint(Color(red: 1, green: 0.42, blue: 0.21))
                    }

                    MetricCard(
                        title: lang.t("Current Weight", thai: "น้ำหนักปัจจุบัน", japanese: "現在の体重"),
                        value: String(format: "%.1f", profile.weightKg),
                        unit: lang.t("kg", thai: "กก.", japanese: "kg"),
                        icon: "scalemass"
                    ) {
                        Slider(value: $profile.weightKg, in: 0...300, step: 0.5)
                            .tint(Color(red: 1, green: 0.42, blue: 0.21))
                    }

                    MetricCard(
                        title: lang.t("Desired Weight", thai: "น้ำหนักที่ต้องการ", japanese: "目標体重"),
                        value: String(format: "%.1f", profile.desiredWeightKg),
                        unit: lang.t("kg", thai: "กก.", japanese: "kg"),
                        icon: "target"
                    ) {
                        Slider(value: $profile.desiredWeightKg, in: 0...300, step: 0.5)
                            .tint(Color(red: 1, green: 0.42, blue: 0.21))
                    }

                    MetricCard(
                        title: lang.t("Weekly Goal", thai: "เป้าหมายรายสัปดาห์", japanese: "週間目標"),
                        value: String(format: "%.1f", profile.weeklyLossKg),
                        unit: lang.t("kg/week", thai: "กก./สัปดาห์", japanese: "kg/週"),
                        icon: "calendar.badge.minus"
                    ) {
                        Slider(value: $profile.weeklyLossKg, in: 0.1...1.5, step: 0.1)
                            .tint(Color(red: 1, green: 0.42, blue: 0.21))
                    }
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 100)
            }
        }
    }
}

struct MetricCard<Content: View>: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))

                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.title.weight(.bold))

                    Text(unit)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            content
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
    }
}
