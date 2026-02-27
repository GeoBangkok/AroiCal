import SwiftUI

struct NameStep: View {
    @Environment(LanguageManager.self) private var lang
    @Binding var profile: UserProfile
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 12) {
                AroiCalHeader()

                Text(lang.t("What's Your Name?", thai: "ชื่อของคุณคืออะไร?", japanese: "お名前は？"))
                    .font(.title.bold())

                Text(lang.t("Let's make this personal 👋", thai: "มาทำให้เป็นเรื่องส่วนตัวกัน 👋", japanese: "あなただけの体験を作りましょう 👋"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            VStack(spacing: 12) {
                ZStack {
                    if profile.name.isEmpty {
                        Text(lang.t("Your name...", thai: "ชื่อของคุณ...", japanese: "お名前..."))
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(.systemGray4))
                            .allowsHitTesting(false)
                    }

                    TextField("", text: $profile.name)
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))
                        .focused($isFocused)
                        .submitLabel(.continue)
                        .textContentType(.givenName)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
                }

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.72, blue: 0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 3)
                    .padding(.horizontal, 40)
                    .opacity(isFocused ? 1.0 : 0.4)
                    .animation(.easeInOut, value: isFocused)
            }

            Spacer()

            if !profile.name.trimmingCharacters(in: .whitespaces).isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "hand.wave.fill")
                        .foregroundStyle(Color(red: 1, green: 0.72, blue: 0))
                    Text(lang.t("Nice to meet you, \(firstName)!", thai: "ยินดีที่ได้รู้จัก \(firstName)!", japanese: "\(firstName)さん、はじめまして！"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Spacer()
        }
        .animation(.spring(duration: 0.4), value: profile.name.isEmpty)
        .task {
            try? await Task.sleep(for: .milliseconds(400))
            isFocused = true
        }
    }

    private var firstName: String {
        let t = profile.name.trimmingCharacters(in: .whitespaces)
        return t.components(separatedBy: " ").first ?? t
    }
}
