import SwiftUI

struct MainTabView: View {
    @Environment(LanguageManager.self) private var lang
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(lang.t("Food", thai: "อาหาร", japanese: "食事"), systemImage: "fork.knife", value: 0) {
                FoodTabView()
            }

            Tab(lang.t("Progress", thai: "ความคืบหน้า", japanese: "進捗"), systemImage: "chart.bar.fill", value: 1) {
                ProgressTabView()
            }

            Tab(lang.t("Settings", thai: "ตั้งค่า", japanese: "設定"), systemImage: "gearshape.fill", value: 2) {
                SettingsTabView()
            }
        }
        .tint(Color(red: 1, green: 0.42, blue: 0.21))
    }
}
