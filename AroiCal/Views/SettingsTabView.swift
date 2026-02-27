import SwiftUI

struct SettingsTabView: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(UserProfileManager.self) private var profileManager
    @State private var showEditProfile: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @AppStorage("has_completed_onboarding") private var hasCompletedOnboarding: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    profileHeader
                }
                .listRowBackground(Color(.secondarySystemGroupedBackground))

                Section(lang.t("Language", thai: "ภาษา", japanese: "言語")) {
                    ForEach(AppLanguage.allCases, id: \.self) { language in
                        Button {
                            withAnimation { lang.current = language }
                        } label: {
                            HStack(spacing: 12) {
                                Text(language.flag)
                                    .font(.title3)

                                Text(language.displayName)
                                    .foregroundStyle(.primary)

                                Spacer()

                                if lang.current == language {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                }

                Section(lang.t("Daily Targets", thai: "เป้าหมายรายวัน", japanese: "毎日の目標")) {
                    targetRow(
                        icon: "flame.fill",
                        label: lang.t("Calories", thai: "แคลอรี", japanese: "カロリー"),
                        value: "\(profileManager.profile.targetCalories) \(lang.t("cal", thai: "แคล", japanese: "cal"))"
                    )
                    targetRow(
                        icon: "p.circle.fill",
                        label: lang.t("Protein", thai: "โปรตีน", japanese: "タンパク質"),
                        value: "\(profileManager.profile.targetProtein)g"
                    )
                    targetRow(
                        icon: "c.circle.fill",
                        label: lang.t("Carbs", thai: "คาร์บ", japanese: "炭水化物"),
                        value: "\(profileManager.profile.targetCarbs)g"
                    )
                    targetRow(
                        icon: "f.circle.fill",
                        label: lang.t("Fat", thai: "ไขมัน", japanese: "脂質"),
                        value: "\(profileManager.profile.targetFat)g"
                    )
                }

                Section(lang.t("About", thai: "เกี่ยวกับ", japanese: "アプリについて")) {
                    HStack {
                        Text(lang.t("Version", thai: "เวอร์ชัน", japanese: "バージョン"))
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    Button {} label: {
                        Text(lang.t("Rate Aroi Cal", thai: "ให้คะแนน Aroi Cal", japanese: "Aroi Calを評価"))
                    }

                    Link(destination: URL(string: "https://aroical.lovable.app/support")!) {
                        Text(lang.t("Support", thai: "ฝ่ายสนับสนุน", japanese: "サポート"))
                    }

                    Link(destination: URL(string: "https://aroical.lovable.app/privacy")!) {
                        Text(lang.t("Privacy Policy", thai: "นโยบายความเป็นส่วนตัว", japanese: "プライバシーポリシー"))
                    }

                    Link(destination: URL(string: "https://aroical.lovable.app/terms")!) {
                        Text(lang.t("Terms of Service", thai: "ข้อกำหนดการใช้งาน", japanese: "利用規約"))
                    }
                }

                Section {
                    Button {} label: {
                        Text(lang.t("Restore Purchases", thai: "กู้คืนการซื้อ", japanese: "購入を復元"))
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        HStack {
                            Spacer()
                            Text(lang.t("Delete Account", thai: "ลบบัญชี", japanese: "アカウント削除"))
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    AroiCalHeader()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    LanguageFlagButton()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showEditProfile) {
                EditProfileSheet()
                    .environment(lang)
                    .environment(profileManager)
            }
            .alert(lang.t("Delete Account?", thai: "ลบบัญชี?", japanese: "アカウント削除?"), isPresented: $showDeleteConfirmation) {
                Button(lang.t("Cancel", thai: "ยกเลิก", japanese: "キャンセル"), role: .cancel) { }
                Button(lang.t("Delete", thai: "ลบ", japanese: "削除"), role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text(lang.t("This will delete all your data and return you to the login screen. This action cannot be undone.",
                           thai: "การดำเนินการนี้จะลบข้อมูลทั้งหมดของคุณและนำคุณกลับไปยังหน้าเข้าสู่ระบบ ไม่สามารถยกเลิกการดำเนินการนี้ได้",
                           japanese: "すべてのデータが削除され、ログイン画面に戻ります。この操作は元に戻せません。"))
            }
        }
    }

    private func deleteAccount() {
        // Clear all user data
        profileManager.profile = UserProfile()

        // Reset onboarding state
        hasCompletedOnboarding = false

        // Clear daily logs
        if let logManager = profileManager as? DailyLogManager {
            // Reset logs if there's a method to do so
        }
    }

    private var profileHeader: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.72, blue: 0)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                Text(String(profileManager.profile.name.prefix(1)).uppercased())
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(profileManager.profile.name.isEmpty
                     ? lang.t("User", thai: "ผู้ใช้", japanese: "ユーザー")
                     : profileManager.profile.name)
                    .font(.headline)

                Text(goalText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                showEditProfile = true
            } label: {
                Text(lang.t("Edit", thai: "แก้ไข", japanese: "編集"))
                    .font(.subheadline.weight(.medium))
            }
        }
        .padding(.vertical, 4)
    }

    private func targetRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))
                .frame(width: 24)

            Text(label)

            Spacer()

            Text(value)
                .foregroundStyle(.secondary)
        }
    }

    private var goalText: String {
        switch profileManager.profile.goal {
        case .lose: return lang.t("Goal: Lose Weight", thai: "เป้าหมาย: ลดน้ำหนัก", japanese: "目標: 減量")
        case .maintain: return lang.t("Goal: Maintain Weight", thai: "เป้าหมาย: รักษาน้ำหนัก", japanese: "目標: 体重維持")
        case .gain: return lang.t("Goal: Gain Weight", thai: "เป้าหมาย: เพิ่มน้ำหนัก", japanese: "目標: 増量")
        }
    }
}

struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageManager.self) private var lang
    @Environment(UserProfileManager.self) private var profileManager
    @State private var editedProfile: UserProfile = UserProfile()

    var body: some View {
        NavigationStack {
            Form {
                Section(lang.t("Personal", thai: "ส่วนตัว", japanese: "個人情報")) {
                    TextField(lang.t("Name", thai: "ชื่อ", japanese: "名前"), text: $editedProfile.name)

                    Stepper(
                        "\(lang.t("Age", thai: "อายุ", japanese: "年齢")): \(editedProfile.age)",
                        value: $editedProfile.age,
                        in: 14...80
                    )

                    Picker(lang.t("Gender", thai: "เพศ", japanese: "性別"), selection: $editedProfile.gender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(genderLabel(gender)).tag(gender)
                        }
                    }
                }

                Section(lang.t("Body", thai: "ร่างกาย", japanese: "体")) {
                    HStack {
                        Text(lang.t("Height", thai: "ส่วนสูง", japanese: "身長"))
                        Spacer()
                        Text("\(Int(editedProfile.heightCm)) \(lang.t("cm", thai: "ซม.", japanese: "cm"))")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $editedProfile.heightCm, in: 120...220, step: 1)

                    HStack {
                        Text(lang.t("Current Weight", thai: "น้ำหนักปัจจุบัน", japanese: "現在の体重"))
                        Spacer()
                        Text(String(format: "%.1f \(lang.t("kg", thai: "กก.", japanese: "kg"))", editedProfile.weightKg))
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $editedProfile.weightKg, in: 0...300, step: 0.5)

                    HStack {
                        Text(lang.t("Desired Weight", thai: "น้ำหนักที่ต้องการ", japanese: "目標体重"))
                        Spacer()
                        Text(String(format: "%.1f \(lang.t("kg", thai: "กก.", japanese: "kg"))", editedProfile.desiredWeightKg))
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $editedProfile.desiredWeightKg, in: 0...300, step: 0.5)

                    HStack {
                        Text(lang.t("Weekly Loss", thai: "ลดต่อสัปดาห์", japanese: "週間減量"))
                        Spacer()
                        Text(String(format: "%.1f \(lang.t("kg/week", thai: "กก./สัปดาห์", japanese: "kg/週"))", editedProfile.weeklyLossKg))
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $editedProfile.weeklyLossKg, in: 0.1...1.5, step: 0.1)
                }

                Section(lang.t("Activity & Goal", thai: "กิจกรรมและเป้าหมาย", japanese: "活動と目標")) {
                    Picker(lang.t("Activity", thai: "กิจกรรม", japanese: "活動"), selection: $editedProfile.activityLevel) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            Text(activityLabel(level)).tag(level)
                        }
                    }

                    Picker(lang.t("Goal", thai: "เป้าหมาย", japanese: "目標"), selection: $editedProfile.goal) {
                        ForEach(GoalType.allCases, id: \.self) { goal in
                            Text(goalLabel(goal)).tag(goal)
                        }
                    }
                }
            }
            .navigationTitle(lang.t("Edit Profile", thai: "แก้ไขโปรไฟล์", japanese: "プロフィール編集"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.t("Cancel", thai: "ยกเลิก", japanese: "キャンセル")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(lang.t("Save", thai: "บันทึก", japanese: "保存")) {
                        profileManager.profile = editedProfile
                        profileManager.applyCalculatedTargets()
                        dismiss()
                    }
                }
            }
            .task {
                editedProfile = profileManager.profile
            }
        }
    }

    private func genderLabel(_ gender: Gender) -> String {
        switch gender {
        case .male: return lang.t("Male", thai: "ชาย", japanese: "男性")
        case .female: return lang.t("Female", thai: "หญิง", japanese: "女性")
        case .other: return lang.t("Other", thai: "อื่นๆ", japanese: "その他")
        }
    }

    private func activityLabel(_ level: ActivityLevel) -> String {
        switch level {
        case .sedentary: return lang.t("Sedentary", thai: "นั่งทำงาน", japanese: "座りがち")
        case .light: return lang.t("Light", thai: "เล็กน้อย", japanese: "軽い")
        case .moderate: return lang.t("Moderate", thai: "ปานกลาง", japanese: "中程度")
        case .active: return lang.t("Active", thai: "มาก", japanese: "活発")
        case .veryActive: return lang.t("Very Active", thai: "หนักมาก", japanese: "非常に活発")
        }
    }

    private func goalLabel(_ goal: GoalType) -> String {
        switch goal {
        case .lose: return lang.t("Lose Weight", thai: "ลดน้ำหนัก", japanese: "減量")
        case .maintain: return lang.t("Maintain", thai: "รักษาน้ำหนัก", japanese: "維持")
        case .gain: return lang.t("Gain Weight", thai: "เพิ่มน้ำหนัก", japanese: "増量")
        }
    }
}
