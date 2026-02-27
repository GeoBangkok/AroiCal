import SwiftUI

struct MainTabView: View {
    @Environment(LanguageManager.self) private var lang
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            FoodTabView()
                .tabItem {
                    Label(lang.t("Food", thai: "อาหาร", japanese: "食事"), systemImage: "fork.knife")
                }
                .tag(0)

            ProgressTabView()
                .tabItem {
                    Label(lang.t("Progress", thai: "ความคืบหน้า", japanese: "進捗"), systemImage: "chart.bar.fill")
                }
                .tag(1)

            SettingsTabView()
                .tabItem {
                    Label(lang.t("Settings", thai: "ตั้งค่า", japanese: "設定"), systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(Color(red: 1, green: 0.42, blue: 0.21))
    }
}
