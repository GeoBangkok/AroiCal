import SwiftUI
import PhotosUI
import SuperwallKit

struct FoodTabView: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(UserProfileManager.self) private var profileManager
    @Environment(DailyLogManager.self) private var logManager
    @StateObject private var storeManager = StoreManager.shared
    @State private var showCamera: Bool = false
    @State private var showPhotoPicker: Bool = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isAnalyzing: Bool = false
    @State private var scannedEntry: FoodEntry?
    @State private var showResult: Bool = false
    @State private var selectedDate: Date = Date()
    @State private var showStreakCard: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var analyzingImageData: Data?
    @State private var showManualEntry: Bool = false
    @State private var showScanOptions: Bool = false
    @State private var pendingScanAction: ScanAction? = nil

    private var selectedLog: DailyLog? { logManager.logForDate(selectedDate) }
    private var entries: [FoodEntry] { selectedLog?.entries ?? [] }
    private var isToday: Bool { Calendar.current.isDateInToday(selectedDate) }
    private var caloriesConsumed: Int { entries.reduce(0) { $0 + $1.calories } }
    private var caloriesLeft: Int { max(0, profileManager.profile.targetCalories - caloriesConsumed) }
    private var streak: Int { logManager.currentStreak() }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    dateSelector

                    if showStreakCard && streak > 0 && isToday {
                        streakCongratsCard
                    }

                    caloriesSummaryCard

                    if isToday {
                        scanSection
                    }

                    if !entries.isEmpty {
                        entriesSection
                    } else {
                        emptyStateView
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
            }
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .principal) {
                    AroiCalHeader()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        LanguageFlagButton()
                        streakBadge
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showResult) {
                if let entry = scannedEntry {
                    FoodResultSheet(entry: entry) {
                        logManager.addEntry(entry)
                        showResult = false
                        scannedEntry = nil
                        withAnimation(.spring(duration: 0.5)) {
                            showStreakCard = true
                        }
                    }
                    .environment(lang)
                }
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) { _, newValue in
                guard let item = newValue else { return }
                Task {
                    await processSelectedPhoto(item)
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraProxyView { imageData in
                    showCamera = false
                    if let data = imageData {
                        Task { await analyzeFood(imageData: data) }
                    }
                }
            }
            .sheet(isPresented: $showManualEntry) {
                ManualFoodEntryView { entry in
                    logManager.addEntry(entry)
                    showManualEntry = false
                    withAnimation(.spring(duration: 0.5)) {
                        showStreakCard = true
                    }
                }
                .environment(lang)
            }
            .sheet(isPresented: $showScanOptions) {
                ScanOptionsSheet(lang: lang) { action in
                    showScanOptions = false
                    pendingScanAction = action
                }
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
            }
            .onChange(of: showScanOptions) { _, isShowing in
                guard !isShowing, let action = pendingScanAction else { return }
                pendingScanAction = nil

                // Trigger paywall for AI-powered scans, but not manual entry
                if action != .manual {
                    triggerPaywallForScan(action: action)
                } else {
                    // Manual entry is always free
                    showManualEntry = true
                }
            }
            .alert("Analysis Failed", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .overlay {
                if isAnalyzing {
                    AnalyzingOverlay(lang: lang, imageData: analyzingImageData)
                }
            }
        }
    }

    private var dateSelector: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(-13..<1, id: \.self) { offset in
                        let date = Calendar.current.date(byAdding: .day, value: offset, to: Calendar.current.startOfDay(for: Date()))!
                        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                        let hasEntries = logManager.logForDate(date)?.entries.isEmpty == false

                        Button {
                            withAnimation(.snappy) {
                                selectedDate = date
                                showStreakCard = false
                            }
                        } label: {
                            VStack(spacing: 6) {
                                Text(dayOfWeek(date))
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)

                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(.system(.body, design: .rounded, weight: .bold))
                                    .foregroundStyle(isSelected ? .white : .primary)

                                Circle()
                                    .fill(hasEntries
                                          ? (isSelected ? Color.white : Color(red: 1, green: 0.42, blue: 0.21))
                                          : Color.clear)
                                    .frame(width: 5, height: 5)
                            }
                            .frame(width: 44, height: 72)
                            .background(
                                isSelected
                                    ? AnyShapeStyle(LinearGradient(
                                        colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.55, blue: 0.1)],
                                        startPoint: .top, endPoint: .bottom
                                    ))
                                    : AnyShapeStyle(Color(.secondarySystemGroupedBackground)),
                                in: .rect(cornerRadius: 14)
                            )
                        }
                        .id(offset)
                    }
                }
                .padding(.vertical, 4)
            }
            .contentMargins(.horizontal, 0)
            .onAppear {
                proxy.scrollTo(0, anchor: .trailing)
            }
        }
    }

    private var streakBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .foregroundStyle(streak > 0 ? Color(red: 1, green: 0.42, blue: 0.21) : .secondary)
            Text("\(streak)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(streak > 0 ? Color(red: 1, green: 0.42, blue: 0.21) : .secondary)
        }
    }

    private var streakCongratsCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.72, blue: 0)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)

                Image(systemName: "flame.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(lang.t("Congrats! \(streak) Day Streak!", thai: "ยินดีด้วย! สตรีค \(streak) วัน!", japanese: "おめでとう！\(streak)日連続！"))
                    .font(.subheadline.weight(.bold))

                Text(lang.t("Keep logging to maintain your streak", thai: "บันทึกต่อเพื่อรักษาสตรีคของคุณ", japanese: "ストリークを維持するために記録を続けよう"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                withAnimation { showStreakCard = false }
            } label: {
                Image(systemName: "xmark")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(
            Color(red: 1, green: 0.42, blue: 0.21).opacity(0.1),
            in: .rect(cornerRadius: 16)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color(red: 1, green: 0.42, blue: 0.21).opacity(0.3), lineWidth: 1)
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private var caloriesSummaryCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isToday
                         ? lang.t("Remaining Today", thai: "เหลือวันนี้", japanese: "本日の残り")
                         : lang.t("Remaining", thai: "เหลือ", japanese: "残り"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(caloriesLeft)")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(caloriesLeft > 0 ? Color.primary : Color.red)

                        Text(lang.t("cal", thai: "แคล", japanese: "cal"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                CalorieRing(
                    consumed: caloriesConsumed,
                    target: profileManager.profile.targetCalories
                )
                .frame(width: 80, height: 80)
            }

            HStack(spacing: 0) {
                MacroBar(
                    label: lang.t("Protein", thai: "โปรตีน", japanese: "タンパク質"),
                    current: entries.reduce(0) { $0 + $1.protein },
                    target: Double(profileManager.profile.targetProtein),
                    color: Color(red: 0.35, green: 0.67, blue: 1)
                )

                MacroBar(
                    label: lang.t("Carbs", thai: "คาร์บ", japanese: "炭水化物"),
                    current: entries.reduce(0) { $0 + $1.carbs },
                    target: Double(profileManager.profile.targetCarbs),
                    color: Color(red: 1, green: 0.42, blue: 0.21)
                )

                MacroBar(
                    label: lang.t("Fat", thai: "ไขมัน", japanese: "脂質"),
                    current: entries.reduce(0) { $0 + $1.fat },
                    target: Double(profileManager.profile.targetFat),
                    color: Color(red: 1, green: 0.72, blue: 0)
                )
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 20))
        .padding(.top, 4)
    }

    private var scanSection: some View {
        Button {
            showScanOptions = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "camera.viewfinder")
                    .font(.title2)

                Text(lang.t("Scan Your Food", thai: "สแกนอาหารของคุณ", japanese: "食事をスキャン"))
                    .font(.headline)

                Spacer()

                Image(systemName: "chevron.up")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.white)
            .padding(20)
            .background(
                LinearGradient(
                    colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.55, blue: 0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: .rect(cornerRadius: 16)
            )
        }
    }

    private var entriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isToday
                 ? lang.t("Today's Meals", thai: "มื้ออาหารวันนี้", japanese: "今日の食事")
                 : lang.t("Meals", thai: "มื้ออาหาร", japanese: "食事"))
                .font(.headline)

            ForEach(entries) { entry in
                FoodEntryCard(entry: entry, lang: lang) {
                    withAnimation { logManager.removeEntry(entry, from: selectedDate) }
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 40))
                .foregroundStyle(Color(.systemGray3))

            Text(isToday
                 ? lang.t("No meals logged yet", thai: "ยังไม่มีมื้ออาหาร", japanese: "まだ食事が記録されていません")
                 : lang.t("No meals on this day", thai: "ไม่มีมื้ออาหารในวันนี้", japanese: "この日の食事はありません"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private func dayOfWeek(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: lang.localeIdentifier)
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }

    private func processSelectedPhoto(_ item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        await analyzeFood(imageData: data)
    }

    private func analyzeFood(imageData: Data) async {
        analyzingImageData = imageData
        isAnalyzing = true
        let service = FoodAnalysisService()

        do {
            let entry = try await service.analyzeFood(imageData: imageData)
            scannedEntry = entry
            showResult = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isAnalyzing = false
        analyzingImageData = nil
    }

    private func triggerPaywallForScan(action: ScanAction) {
        Task {
            // Check subscription status first
            await storeManager.checkSubscriptionStatus()

            // If already subscribed, proceed directly
            if storeManager.isSubscribed {
                await MainActor.run {
                    switch action {
                    case .camera: showCamera = true
                    case .photo: showPhotoPicker = true
                    case .manual: break
                    }
                }
                return
            }

            // Not subscribed - show paywall based on scan type
            let eventName: String
            switch action {
            case .camera: eventName = "food_scan_camera"
            case .photo: eventName = "food_scan_photo"
            case .manual: return // Manual entry doesn't trigger paywall
            }

            // Register the event - Superwall will decide whether to present paywall
            print("🔔 Registering event: \(eventName)")
            Superwall.shared.register(placement: eventName)

            // After paywall interaction (purchase or dismiss), check subscription
            // The purchase controller will update subscription status
            // For now, we let Superwall handle the paywall presentation
            // Users who subscribe will be able to use features on next attempt
        }
    }
}

// MARK: - Scan action type
fileprivate enum ScanAction { case camera, photo, manual }

// MARK: - Scan options bottom sheet
private struct ScanOptionsSheet: View {
    let lang: LanguageManager
    let onSelect: (ScanAction) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(lang.t("How would you like to scan?", thai: "คุณต้องการสแกนอย่างไร?", japanese: "どのようにスキャンしますか？"))
                .font(.headline)
                .padding(.top, 4)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                scanOption(
                    icon: "camera.fill",
                    color: Color(red: 1, green: 0.42, blue: 0.21),
                    title: lang.t("Camera", thai: "กล้อง", japanese: "カメラ"),
                    subtitle: lang.t("Take a photo", thai: "ถ่ายรูป", japanese: "写真を撮る"),
                    action: .camera
                )
                scanOption(
                    icon: "photo.on.rectangle",
                    color: Color(red: 0.35, green: 0.67, blue: 1),
                    title: lang.t("Gallery", thai: "แกลเลอรี", japanese: "ギャラリー"),
                    subtitle: lang.t("Upload photo", thai: "อัปโหลดรูป", japanese: "写真をアップ"),
                    action: .photo
                )
                scanOption(
                    icon: "pencil.circle.fill",
                    color: Color(red: 0.6, green: 0.4, blue: 1),
                    title: lang.t("Manual", thai: "บันทึกเอง", japanese: "手動入力"),
                    subtitle: lang.t("Enter manually", thai: "ป้อนด้วยตนเอง", japanese: "手入力する"),
                    action: .manual
                )
            }
        }
        .padding(20)
    }

    private func scanOption(icon: String, color: Color, title: String, subtitle: String, action: ScanAction) -> some View {
        Button { onSelect(action) } label: {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 48, height: 48)
                    .background(color.opacity(0.12), in: .rect(cornerRadius: 12))

                VStack(spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
        }
    }
}

struct CalorieRing: View {
    let consumed: Int
    let target: Int

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(consumed) / Double(target), 1.0)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 8)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.72, blue: 0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 0) {
                Text("\(Int(progress * 100))")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))

                Text("%")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct MacroBar: View {
    let label: String
    let current: Double
    let target: Double
    let color: Color

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(current / target, 1.0)
    }

    var body: some View {
        VStack(spacing: 6) {
            Text("\(Int(current))/\(Int(target))g")
                .font(.caption2.weight(.semibold))

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))

                    Capsule()
                        .fill(color)
                        .frame(width: max(4, geo.size.width * progress))
                }
            }
            .frame(height: 6)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 4)
    }
}

struct FoodEntryCard: View {
    let entry: FoodEntry
    let lang: LanguageManager
    let onDelete: () -> Void

    private var displayName: String {
        switch lang.current {
        case .thai:
            return entry.nameThai.isEmpty ? entry.name : entry.nameThai
        case .japanese:
            return entry.nameJapanese.isEmpty ? entry.name : entry.nameJapanese
        case .english:
            return entry.name
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if let data = entry.imageData, let uiImage = UIImage(data: data) {
                Color(.secondarySystemBackground)
                    .frame(height: 140)
                    .overlay {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .allowsHitTesting(false)
                    }
                    .clipShape(.rect(cornerRadii: .init(topLeading: 14, topTrailing: 14)))
            }

            HStack(spacing: 14) {
                if entry.imageData == nil {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 1, green: 0.42, blue: 0.21).opacity(0.12))
                        .frame(width: 44, height: 44)
                        .overlay {
                            Image(systemName: "fork.knife")
                                .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))
                        }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(displayName)
                        .font(.subheadline.weight(.semibold))

                    HStack(spacing: 10) {
                        macroLabel("P", value: entry.protein, color: Color(red: 0.35, green: 0.67, blue: 1))
                        macroLabel("C", value: entry.carbs, color: Color(red: 1, green: 0.42, blue: 0.21))
                        macroLabel("F", value: entry.fat, color: Color(red: 1, green: 0.72, blue: 0))
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(entry.calories)")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))

                    Text(lang.t("cal", thai: "แคล", japanese: "cal"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(14)
        }
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        .contextMenu {
            Button(role: .destructive) { onDelete() } label: {
                Label(lang.t("Delete", thai: "ลบ", japanese: "削除"), systemImage: "trash")
            }
        }
    }

    private func macroLabel(_ letter: String, value: Double, color: Color) -> some View {
        HStack(spacing: 2) {
            Text(letter)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(color)
            Text("\(Int(value))g")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
    }
}

struct AnalyzingOverlay: View {
    let lang: LanguageManager
    var imageData: Data? = nil

    @State private var shimmerX: CGFloat = -180
    @State private var progressValue: Double = 0
    @State private var pulseScale: CGFloat = 1.0

    private let ringSize: CGFloat = 168

    var body: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()

            VStack(spacing: 24) {
                ZStack {
                    if let data = imageData, let uiImage = UIImage(data: data) {
                        // Food image with shimmer
                        ZStack {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: ringSize, height: ringSize)
                                .clipShape(Circle())
                                .scaleEffect(pulseScale)

                            // Shimmer sweep
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.clear, .white.opacity(0.35), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: ringSize, height: ringSize)
                                .offset(x: shimmerX)
                                .clipShape(Circle())
                        }
                    } else {
                        // Fallback icon
                        Circle()
                            .fill(Color(red: 1, green: 0.42, blue: 0.21).opacity(0.18))
                            .frame(width: ringSize, height: ringSize)
                            .overlay {
                                Image(systemName: "fork.knife.circle.fill")
                                    .font(.system(size: 56))
                                    .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))
                                    .scaleEffect(pulseScale)
                            }
                    }

                    // Progress ring
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 5)
                        .frame(width: ringSize + 14, height: ringSize + 14)

                    Circle()
                        .trim(from: 0, to: progressValue)
                        .stroke(
                            LinearGradient(
                                colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.72, blue: 0)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .frame(width: ringSize + 14, height: ringSize + 14)
                        .rotationEffect(.degrees(-90))
                }

                VStack(spacing: 6) {
                    Text(lang.t("Analyzing your food...", thai: "กำลังวิเคราะห์อาหาร...", japanese: "食べ物を分析中..."))
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("\(Int(progressValue * 100))%")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(Color(red: 1, green: 0.72, blue: 0))
                        .contentTransition(.numericText())
                        .animation(.easeInOut, value: progressValue)
                }
            }
            .padding(36)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 28))
        }
        .onAppear {
            // Shimmer sweep — repeats
            withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
                shimmerX = 180
            }
            // Gentle image pulse
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.04
            }
            // Staged progress: 0% → 25% → 50% → 75% → 100% over ~2.5s
            Task {
                withAnimation(.easeOut(duration: 0.5)) { progressValue = 0.25 }
                try? await Task.sleep(nanoseconds: 650_000_000)
                withAnimation(.easeInOut(duration: 0.5)) { progressValue = 0.50 }
                try? await Task.sleep(nanoseconds: 650_000_000)
                withAnimation(.easeInOut(duration: 0.5)) { progressValue = 0.75 }
                try? await Task.sleep(nanoseconds: 650_000_000)
                withAnimation(.easeIn(duration: 0.5)) { progressValue = 1.0 }
            }
        }
    }
}
