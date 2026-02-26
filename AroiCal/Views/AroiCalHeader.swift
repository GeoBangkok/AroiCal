import SwiftUI

struct AroiCalHeader: View {
    var showFlag: Bool = true
    @Environment(LanguageManager.self) private var lang

    var body: some View {
        Text("AROI CAL")
            .font(.system(.subheadline, design: .rounded, weight: .heavy))
            .tracking(2)
            .foregroundStyle(
                LinearGradient(
                    colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.72, blue: 0)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}

struct LanguageFlagButton: View {
    @Environment(LanguageManager.self) private var lang

    var body: some View {
        Button {
            withAnimation(.snappy) {
                lang.cycleLanguage()
            }
        } label: {
            Text(lang.current.flag)
                .font(.title3)
                .contentTransition(.identity)
        }
    }
}
