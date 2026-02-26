import SwiftUI

struct CreatorReferralStep: View {
    @Environment(LanguageManager.self) private var lang
    @Binding var profile: UserProfile
    @FocusState private var isFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(spacing: 8) {
                    AroiCalHeader()

                    Image(systemName: "person.2.badge.gearshape")
                        .font(.system(size: 48))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.72, blue: 0)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.bottom, 4)

                    Text(lang.t("Who Sent You?", thai: "ใครแนะนำคุณมา?", japanese: "誰に紹介されましたか？"))
                        .font(.title.bold())
                        .multilineTextAlignment(.center)

                    Text(lang.t("Which creator referred you to the app?", thai: "ครีเอเตอร์คนไหนแนะนำแอพนี้ให้คุณ?", japanese: "どのクリエイターがこのアプリを紹介しましたか？"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)

                VStack(alignment: .leading, spacing: 8) {
                    Text(lang.t("Creator Name or Handle", thai: "ชื่อครีเอเตอร์หรือแฮนเดิล", japanese: "クリエイター名またはハンドル"))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        Image(systemName: "at")
                            .font(.title3)
                            .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))

                        TextField(
                            lang.t("e.g. @creator_name", thai: "เช่น @ชื่อครีเอเตอร์", japanese: "例: @creator_name"),
                            text: $profile.creatorReferral
                        )
                        .font(.body)
                        .focused($isFocused)
                    }
                    .padding(16)
                    .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(
                                isFocused ? Color(red: 1, green: 0.42, blue: 0.21) : Color.clear,
                                lineWidth: 2
                            )
                    )
                }
                .padding(.horizontal, 24)

                VStack(spacing: 12) {
                    Image(systemName: "gift.fill")
                        .font(.title2)
                        .foregroundStyle(Color(red: 1, green: 0.72, blue: 0))

                    Text(lang.t("Referrals help us partner with creators who spread the word about healthy living!", thai: "การแนะนำช่วยให้เราร่วมมือกับครีเอเตอร์ที่เผยแพร่เรื่องการใช้ชีวิตเพื่อสุขภาพ!", japanese: "紹介はヘルシーライフを広めるクリエイターとの提携に役立ちます！"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(Color(red: 1, green: 0.72, blue: 0).opacity(0.08), in: .rect(cornerRadius: 16))
                .padding(.horizontal, 24)

                Text(lang.t("You can skip this if no one referred you", thai: "ข้ามได้หากไม่มีใครแนะนำคุณ", japanese: "紹介者がいない場合はスキップできます"))
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                Spacer(minLength: 100)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }
}
