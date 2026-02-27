import SwiftUI
import UserNotifications

struct NotificationsStep: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(NotificationsManager.self) private var notifications
    let name: String
    @State private var animateBell: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                AroiCalHeader()

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 1, green: 0.42, blue: 0.21).opacity(0.2),
                                    Color(red: 1, green: 0.42, blue: 0.21).opacity(0.05),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)

                    Image(systemName: notifications.isPermissionGranted ? "bell.badge.fill" : "bell.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.72, blue: 0)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .symbolEffect(.bounce, value: animateBell)
                }

                VStack(spacing: 8) {
                    Text(name.isEmpty
                         ? lang.t("Stay On Track", thai: "ติดตามผลอย่างต่อเนื่อง", japanese: "トラックを維持")
                         : lang.t("Stay On Track, \(name)!", thai: "ติดตามผลอย่างต่อเนื่อง \(name)!", japanese: "\(name)さん、続けましょう！"))
                        .font(.title.bold())

                    Text(lang.t("Get reminders to log your meals and celebrate your streaks!", thai: "รับการแจ้งเตือนให้บันทึกมื้ออาหารและฉลองสตรีคของคุณ!", japanese: "食事記録のリマインダーとストリークのお祝いを受け取ろう！"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }

            Spacer()

            VStack(spacing: 16) {
                notificationPreview(
                    icon: "fork.knife",
                    title: lang.t("Time to log lunch! 🍜", thai: "มื้อกลางวันมาแล้ว! 🍜", japanese: "ランチタイム！🍜"),
                    subtitle: lang.t("Point, snap, and let AI do the math!", thai: "กินอะไรเที่ยงนี้? ถ่ายรูปแล้วให้ AI คำนวณแคลให้เลย 📸", japanese: "撮影してカロリーをチェック！📸"),
                    time: "12:00 PM"
                )

                notificationPreview(
                    icon: "sun.horizon.fill",
                    title: lang.t("Good morning! ☀️", thai: "สวัสดีตอนเช้า! ☀️", japanese: "おはよう！☀️"),
                    subtitle: lang.t("Start strong — snap your breakfast!", thai: "เริ่มวันใหม่ด้วยการบันทึกมื้อเช้า 🍳", japanese: "朝食を記録して1日をスタート！🍳"),
                    time: "8:00 AM"
                )
            }
            .padding(.horizontal, 24)

            Spacer()

            if !notifications.isPermissionGranted {
                Button {
                    notifications.requestAndSchedule(language: lang.current)
                    withAnimation(.spring) { animateBell = true }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "bell.badge")
                        Text(lang.t("Enable Notifications", thai: "เปิดการแจ้งเตือน", japanese: "通知を有効にする"))
                    }
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
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color(red: 0.2, green: 0.78, blue: 0.35))
                    Text(lang.t("Notifications Enabled!", thai: "เปิดการแจ้งเตือนแล้ว!", japanese: "通知が有効になりました！"))
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.2, green: 0.78, blue: 0.35))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(red: 0.2, green: 0.78, blue: 0.35).opacity(0.12), in: .rect(cornerRadius: 16))
                .padding(.horizontal, 24)
            }

            Spacer(minLength: 80)
        }
        .task {
            try? await Task.sleep(for: .milliseconds(500))
            animateBell = true
            notifications.checkStatus()
        }
    }

    private func notificationPreview(icon: String, title: String, subtitle: String, time: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.55, blue: 0.1)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("AROI CAL")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(time)
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
    }
}
