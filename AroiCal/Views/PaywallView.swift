import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storeManager = StoreManager.shared
    let onContinue: () -> Void

    @State private var selectedPlan: SubscriptionPlan = .annual
    @State private var products: [Product] = []
    @State private var isLoadingProducts = true

    private var isThailand: Bool {
        Locale.current.region?.identifier == "TH"
    }

    private var isJapan: Bool {
        Locale.current.region?.identifier == "JP"
    }

    private var monthlyProduct: Product? {
        products.first { $0.id == "monthly.AroiCal" }
    }

    private var annualProduct: Product? {
        products.first { $0.id == "annual.AroiCal" }
    }

    private var selectedProduct: Product? {
        selectedPlan == .monthly ? monthlyProduct : annualProduct
    }

    private var priceText: String {
        guard let product = selectedProduct else {
            return selectedPlan == .monthly ? "$9.99" : "$39.99"
        }
        return product.displayPrice
    }

    private var perMonthText: String {
        guard let product = annualProduct else {
            return lang.t("≈ $3.33/month", thai: "≈ $3.33/เดือน", japanese: "≈ $3.33/月")
        }

        if let price = product.price as? Decimal {
            let monthlyPrice = price / 12
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.priceFormatStyle.locale
            if let formatted = formatter.string(from: monthlyPrice as NSDecimalNumber) {
                return "≈ \(formatted)/\(lang.t("month", thai: "เดือน", japanese: "月"))"
            }
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
                        // Subscription Plan Selector
                        HStack(spacing: 12) {
                            PlanCard(
                                plan: .monthly,
                                isSelected: selectedPlan == .monthly,
                                product: monthlyProduct,
                                lang: lang
                            ) {
                                selectedPlan = .monthly
                            }

                            PlanCard(
                                plan: .annual,
                                isSelected: selectedPlan == .annual,
                                product: annualProduct,
                                lang: lang,
                                badge: lang.t("SAVE 67%", thai: "ประหยัด 67%", japanese: "67%オフ")
                            ) {
                                selectedPlan = .annual
                            }
                        }
                        .padding(.horizontal, 24)

                        if selectedPlan == .annual {
                            Text(perMonthText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Button {
                            Task {
                                guard let product = selectedProduct else { return }
                                await storeManager.purchase(productID: product.id)
                                if storeManager.isSubscribed {
                                    onContinue()
                                }
                            }
                        } label: {
                            HStack {
                                if storeManager.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text(lang.t("Start Free Trial", thai: "เริ่มทดลองใช้ฟรี", japanese: "無料トライアル開始"))
                                        .font(.headline)
                                }
                            }
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
                        .disabled(storeManager.isLoading || isLoadingProducts)
                        .padding(.horizontal, 24)

                        Text(lang.t("Cancel anytime. No charge during trial.", thai: "ยกเลิกได้ทุกเมื่อ ไม่เก็บเงินระหว่างทดลอง", japanese: "いつでもキャンセル可能。トライアル中は無料。"))
                            .font(.caption)
                            .foregroundStyle(.tertiary)

                        if let error = storeManager.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .padding(.horizontal, 24)
                        }
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

                        Button {
                            Task {
                                await storeManager.restorePurchases()
                                if storeManager.isSubscribed {
                                    onContinue()
                                }
                            }
                        } label: {
                            Text(lang.t("Restore", thai: "กู้คืน", japanese: "復元"))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }

                    Spacer(minLength: 20)
                }
            }
        }
        .task {
            await loadProducts()
        }
    }

    private func loadProducts() async {
        do {
            products = try await storeManager.fetchProducts()
            isLoadingProducts = false
        } catch {
            print("Failed to load products: \(error)")
            isLoadingProducts = false
        }
    }
}

// MARK: - Supporting Types

enum SubscriptionPlan {
    case monthly
    case annual
}

struct PlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let product: Product?
    let lang: LanguageManager
    var badge: String? = nil
    let onTap: () -> Void

    private var title: String {
        switch plan {
        case .monthly:
            return lang.t("Monthly", thai: "รายเดือน", japanese: "月額")
        case .annual:
            return lang.t("Annual", thai: "รายปี", japanese: "年額")
        }
    }

    private var duration: String {
        switch plan {
        case .monthly:
            return lang.t("1 month", thai: "1 เดือน", japanese: "1ヶ月")
        case .annual:
            return lang.t("1 year", thai: "1 ปี", japanese: "1年")
        }
    }

    private var price: String {
        guard let product = product else {
            return plan == .monthly ? "$9.99" : "$39.99"
        }
        return product.displayPrice
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(red: 0.2, green: 0.78, blue: 0.35))
                        .clipShape(Capsule())
                }

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isSelected ? .primary : .secondary)

                Text(price)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(isSelected ? Color(red: 1, green: 0.42, blue: 0.21) : .primary)

                Text(duration)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                isSelected
                    ? Color(red: 1, green: 0.42, blue: 0.21).opacity(0.1)
                    : Color(.secondarySystemGroupedBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        isSelected
                            ? Color(red: 1, green: 0.42, blue: 0.21)
                            : Color(.separator).opacity(0.5),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
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
