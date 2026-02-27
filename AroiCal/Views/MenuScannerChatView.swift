import SwiftUI
import PhotosUI

enum RecommendationType: String, CaseIterable {
    case healthiest = "healthiest"
    case tastiest = "tastiest"
    case protein = "protein"
    case fiber = "fiber"

    var icon: String {
        switch self {
        case .healthiest: return "heart.fill"
        case .tastiest: return "star.fill"
        case .protein: return "💪"
        case .fiber: return "leaf.fill"
        }
    }

    func displayName(lang: LanguageManager) -> String {
        switch self {
        case .healthiest:
            return lang.t("Healthiest", thai: "สุขภาพดีที่สุด", japanese: "最も健康的")
        case .tastiest:
            return lang.t("Tastiest", thai: "อร่อยที่สุด", japanese: "最も美味しい")
        case .protein:
            return lang.t("High Protein", thai: "โปรตีนสูง", japanese: "高タンパク質")
        case .fiber:
            return lang.t("Fiber/Digestion", thai: "ไฟเบอร์/ย่อย", japanese: "食物繊維/消化")
        }
    }
}

struct MenuScannerChatView: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(\.dismiss) private var dismiss

    @State private var messages: [ChatMessage] = []
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var selectedRecommendationType: RecommendationType?
    @State private var isAnalyzing = false
    @State private var recommendations: String?

    var body: some View {
        NavigationStack {
            ZStack {
                // iMessage-style gradient background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Chat messages area
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Initial bot message
                            if messages.isEmpty && selectedImage == nil {
                                BotMessageBubble(
                                    message: lang.t("👋 Hi! Upload a menu photo or take a screenshot, and I'll help you find the perfect dish!",
                                                   thai: "👋 สวัสดี! อัปโหลดรูปเมนูหรือจับภาพหน้าจอ แล้วฉันจะช่วยคุณหาอาหารที่ดีที่สุด!",
                                                   japanese: "👋 こんにちは！メニュー写真をアップロードするかスクリーンショットを撮ると、最適な料理を見つけるお手伝いをします！")
                                )
                            }

                            // Display uploaded image
                            if let image = selectedImage, !isAnalyzing {
                                UserImageBubble(image: image)
                            }

                            // Show recommendation type selector
                            if selectedImage != nil && selectedRecommendationType == nil && !isAnalyzing {
                                VStack(alignment: .leading, spacing: 12) {
                                    BotMessageBubble(
                                        message: lang.t("What are you looking for?",
                                                       thai: "คุณกำลังมองหาอะไร?",
                                                       japanese: "何をお探しですか？")
                                    )

                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                        ForEach(RecommendationType.allCases, id: \.self) { type in
                                            RecommendationButton(
                                                type: type,
                                                lang: lang
                                            ) {
                                                selectRecommendation(type)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }

                            // Show analyzing state
                            if isAnalyzing {
                                BotTypingBubble()
                            }

                            // Show AI recommendation
                            if let recommendations = recommendations {
                                BotMessageBubble(message: recommendations)
                            }
                        }
                        .padding()
                    }

                    Divider()

                    // iMessage-style input bar
                    HStack(spacing: 12) {
                        // Camera button
                        Button {
                            showCamera = true
                        } label: {
                            Image(systemName: "camera.fill")
                                .font(.title3)
                                .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))
                                .frame(width: 36, height: 36)
                        }

                        // Photo library button
                        Button {
                            showImagePicker = true
                        } label: {
                            Image(systemName: "photo.fill")
                                .font(.title3)
                                .foregroundStyle(Color(red: 0.35, green: 0.67, blue: 1))
                                .frame(width: 36, height: 36)
                        }

                        // Placeholder text
                        Text(lang.t("Upload menu or screenshot...",
                                   thai: "อัปโหลดเมนูหรือภาพหน้าจอ...",
                                   japanese: "メニューまたはスクリーンショットをアップロード..."))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(Capsule())
                    }
                    .padding()
                    .background(.bar)
                }
            }
            .navigationTitle(lang.t("Menu Advisor", thai: "ที่ปรึกษาเมนู", japanese: "メニューアドバイザー"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
            }
            .fullScreenCover(isPresented: $showCamera) {
                ImagePicker(image: $selectedImage, sourceType: .camera)
            }
        }
    }

    private func selectRecommendation(_ type: RecommendationType) {
        selectedRecommendationType = type

        // Start analyzing
        guard let image = selectedImage else { return }

        isAnalyzing = true

        Task {
            do {
                let service = MenuAnalysisService()
                let result = try await service.analyzeMenuWithRecommendation(
                    image: image,
                    recommendationType: type.rawValue
                )

                await MainActor.run {
                    self.recommendations = result
                    self.isAnalyzing = false
                }
            } catch {
                await MainActor.run {
                    self.recommendations = lang.t("Sorry, I couldn't analyze the menu. Please try again.",
                                                 thai: "ขออภัย ฉันไม่สามารถวิเคราะห์เมนูได้ กรุณาลองใหม่อีกครั้ง",
                                                 japanese: "申し訳ございませんが、メニューを分析できませんでした。もう一度お試しください。")
                    self.isAnalyzing = false
                }
            }
        }
    }
}

// MARK: - Chat Message Models
struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let image: UIImage?
}

// MARK: - Chat Bubbles
struct BotMessageBubble: View {
    let message: String

    var body: some View {
        HStack {
            Text(message)
                .font(.body)
                .padding(12)
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .frame(maxWidth: 280, alignment: .leading)

            Spacer()
        }
    }
}

struct UserImageBubble: View {
    let image: UIImage

    var body: some View {
        HStack {
            Spacer()

            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
}

struct BotTypingBubble: View {
    @State private var dotCount = 0

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color(.systemGray3))
                        .frame(width: 8, height: 8)
                        .opacity(dotCount == index ? 1.0 : 0.4)
                }
            }
            .padding(12)
            .background(Color(.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Spacer()
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                dotCount = (dotCount + 1) % 3
            }
        }
    }
}

struct RecommendationButton: View {
    let type: RecommendationType
    let lang: LanguageManager
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                if type == .protein {
                    Text(type.icon)
                        .font(.title2)
                } else {
                    Image(systemName: type.icon)
                        .font(.title3)
                        .foregroundStyle(buttonColor)
                }

                Text(type.displayName(lang: lang))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var buttonColor: Color {
        switch type {
        case .healthiest: return .green
        case .tastiest: return .orange
        case .protein: return .blue
        case .fiber: return .brown
        }
    }
}

#Preview {
    MenuScannerChatView()
        .environment(LanguageManager())
}
