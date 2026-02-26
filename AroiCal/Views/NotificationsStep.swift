import SwiftUI
import UserNotifications

struct NotificationsStep: View {
    @Environment(LanguageManager.self) private var lang
    @State private var animateBell: Bool = false
    @State private var permissionGranted: Bool = false

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

                    Image(systemName: permissionGranted ? "bell.badge.fill" : "bell.fill")
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
                    Text(lang.t("Stay On Track", thai: "ติดตามผลอย่างต่อเนื่อง", japanese: "トラックを維持"))
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
                    title: lang.t("Time to log lunch! 🍜", thai: "ถึงเวลาบันทึกมื้อกลางวัน! 🍜", japanese: "ランチを記録しよう！🍜"),
                    subtitle: lang.t("Don't forget to scan your meal", thai: "อย่าลืมสแกนมื้ออาหารของคุณ", japanese: "食事のスキャンを忘れずに"),
                    time: "12:30 PM"
                )

                notificationPreview(
                    icon: "flame.fill",
                    title: lang.t("5 Day Streak! 🔥", thai: "สตรีค 5 วัน! 🔥", japanese: "5日連続！🔥"),
                    subtitle: lang.t("You're on fire! Keep going", thai: "คุณทำได้เยี่ยม! ไปต่อเลย", japanese: "絶好調！続けよう"),
                    time: "8:00 AM"
                )
            }
            .padding(.horizontal, 24)

            Spacer()

            if !permissionGranted {
                Button {
                    requestNotificationPermission()
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

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            Task { @MainActor in
                withAnimation(.spring) {
                    permissionGranted = granted
                    animateBell = true
                }
            }
        }
    }
}
