import SwiftUI

struct PaywallView: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(\.dismiss) private var dismiss
    let onContinue: () -> Void

    private var isThailand: Bool {
        Locale.current.region?.identifier == "TH"
    }

    private var isJapan: Bool {
        Locale.current.region?.identifier == "JP"
    }

    private var priceText: String {
        if isThailand { return "฿1,390" }
        if isJapan { return "¥5,900" }
        return "$39.99"
    }

    private var perMonthText: String {
        if isThailand {
            return lang.t("≈ ฿116/month", thai: "≈ ฿116/เดือน", japanese: "≈ ฿116/月")
        }
        if isJapan {
            return lang.t("≈ ¥492/month", thai: "≈ ¥492/เดือน", japanese: "≈ ¥492/月")
        }
        return lang.t("≈ $3.33/month", thai: "≈ $3.33/เดือน", japanese: "≈ $3.33/月")
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1, green: 0.42, blue: 0.21).opacity(0.08),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    HStack {
                        Spacer()
                        LanguageFlagButton()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                    VStack(spacing: 16) {
                        AroiCalHeader()

                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.72, blue: 0)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)

                            Image(systemName: "crown.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(.white)
                        }

                        Text(lang.t("Unlock Aroi Cal Pro", thai: "ปลดล็อก Aroi Cal Pro", japanese: "Aroi Cal Proをアンロック"))
                            .font(.title.bold())
                            .multilineTextAlignment(.center)

                        Text(lang.t("Start your 3-day free trial", thai: "เริ่มทดลองใช้ฟรี 3 วัน", japanese: "3日間の無料トライアル"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(
                            icon: "camera.viewfinder",
                            title: lang.t("Unlimited Food Scans", thai: "สแกนอาหารไม่จำกัด", japanese: "無制限のフードスキャン"),
                            subtitle: lang.t("Scan any food, anytime", thai: "สแกนอาหารได้ทุกเวลา", japanese: "いつでも食べ物をスキャン")
                        )
                        FeatureRow(
                            icon: "chart.line.uptrend.xyaxis",
                            title: lang.t("Detailed Progress", thai: "ความคืบหน้าละเอียด", japanese: "詳細な進捗"),
                            subtitle: lang.t("Track macros & trends", thai: "ติดตามมาโครและแนวโน้ม", japanese: "マクロと傾向を追跡")
                        )
                        FeatureRow(
                            icon: "target",
                            title: lang.t("Smart Goals", thai: "เป้าหมายอัจฉริยะ", japanese: "スマート目標"),
                            subtitle: lang.t("AI-personalized targets", thai: "เป้าหมายที่ปรับแต่งโดย AI", japanese: "AIパーソナライズ目標")
                        )
                        FeatureRow(
                            icon: "globe.asia.australia",
                            title: lang.t("Thai Food Database", thai: "ฐานข้อมูลอาหารไทย", japanese: "タイ料理データベース"),
                            subtitle: lang.t("1000+ Thai dishes", thai: "อาหารไทยกว่า 1000 รายการ", japanese: "1000以上のタイ料理")
                        )
                    }
                    .padding(20)
                    .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 20))
                    .padding(.horizontal, 24)

                    VStack(spacing: 12) {
                        VStack(spacing: 4) {
                            Text(lang.t("3 Days Free, Then", thai: "ฟรี 3 วัน จากนั้น", japanese: "3日間無料、その後"))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(priceText)
                                    .font(.system(size: 40, weight: .bold, design: .rounded))

                                Text(lang.t("/ year", thai: "/ ปี", japanese: "/ 年"))
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }

                            Text(perMonthText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Button {
                            onContinue()
                        } label: {
                            Text(lang.t("Start Free Trial", thai: "เริ่มทดลองใช้ฟรี", japanese: "無料トライアル開始"))
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.72, blue: 0)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    in: .rect(cornerRadius: 16)
                                )
                        }
                        .padding(.horizontal, 24)

                        Text(lang.t("Cancel anytime. No charge during trial.", thai: "ยกเลิกได้ทุกเมื่อ ไม่เก็บเงินระหว่างทดลอง", japanese: "いつでもキャンセル可能。トライアル中は無料。"))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    Button {
                        onContinue()
                    } label: {
                        Text(lang.t("Maybe Later", thai: "ไว้ทีหลัง", japanese: "後で"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 16) {
                        Button {} label: {
                            Text(lang.t("Terms", thai: "ข้อตกลง", japanese: "利用規約"))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }

                        Button {} label: {
                            Text(lang.t("Privacy", thai: "ความเป็นส่วนตัว", japanese: "プライバシー"))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }

                        Button {} label: {
                            Text(lang.t("Restore", thai: "กู้คืน", japanese: "復元"))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }

                    Spacer(minLength: 20)
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))
                .frame(width: 40, height: 40)
                .background(Color(red: 1, green: 0.42, blue: 0.21).opacity(0.12), in: .rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "checkmark")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(red: 0.2, green: 0.78, blue: 0.35))
        }
    }
}
