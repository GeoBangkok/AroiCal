import SwiftUI

struct ProgressTabView: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(UserProfileManager.self) private var profileManager
    @Environment(DailyLogManager.self) private var logManager
    @State private var selectedRange: Int = 7

    private var recentLogs: [DailyLog] { logManager.logsForLastDays(selectedRange) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    rangePicker

                    weeklyCaloriesCard

                    macroBreakdownCard

                    streakCard

                    if !recentLogs.isEmpty {
                        dailyBreakdownSection
                    } else {
                        emptyState
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
                    LanguageFlagButton()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var rangePicker: some View {
        HStack(spacing: 0) {
            ForEach([7, 14, 30], id: \.self) { days in
                Button {
                    withAnimation(.snappy) { selectedRange = days }
                } label: {
                    Text(lang.t("\(days)D", thai: "\(days)วัน", japanese: "\(days)日"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(selectedRange == days ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(
                            selectedRange == days
                                ? Color(red: 1, green: 0.42, blue: 0.21)
                                : Color.clear,
                            in: .rect(cornerRadius: 10)
                        )
                }
            }
        }
        .padding(4)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
        .padding(.top, 8)
    }

    private var weeklyCaloriesCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(lang.t("Avg. Calories", thai: "แคลอรีเฉลี่ย", japanese: "平均カロリー"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    let avg = averageCalories
                    Text("\(avg)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                }

                Spacer()

                let diff = averageCalories - profileManager.profile.targetCalories
                if diff != 0 {
                    VStack(alignment: .trailing, spacing: 2) {
                        Image(systemName: diff > 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(diff > 0 ? .red : .green)

                        Text("\(abs(diff)) \(lang.t("cal", thai: "แคล", japanese: "cal"))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        Text(diff > 0
                             ? lang.t("over target", thai: "เกินเป้า", japanese: "目標超過")
                             : lang.t("under target", thai: "ต่ำกว่าเป้า", japanese: "目標以下"))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            calorieBarChart
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 20))
    }

    private var calorieBarChart: some View {
        HStack(alignment: .bottom, spacing: 6) {
            let target = profileManager.profile.targetCalories
            let days = min(selectedRange, 7)
            let calendar = Calendar.current

            ForEach(0..<days, id: \.self) { dayOffset in
                let date = calendar.date(byAdding: .day, value: -(days - 1 - dayOffset), to: Date())!
                let log = recentLogs.first { calendar.isDate($0.date, inSameDayAs: date) }
                let cals = log?.totalCalories ?? 0
                let height = target > 0 ? min(Double(cals) / Double(target), 1.5) : 0

                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            cals > target
                                ? AnyShapeStyle(Color.red.opacity(0.7))
                                : AnyShapeStyle(LinearGradient(
                                    colors: [Color(red: 1, green: 0.42, blue: 0.21), Color(red: 1, green: 0.72, blue: 0)],
                                    startPoint: .bottom,
                                    endPoint: .top
                                ))
                        )
                        .frame(height: max(4, 100 * height))

                    Text(dayLabel(date))
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 120)
    }

    private var macroBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(lang.t("Avg. Macros", thai: "มาโครเฉลี่ย", japanese: "平均マクロ"))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                MacroProgressRing(
                    label: lang.t("Protein", thai: "โปรตีน", japanese: "タンパク質"),
                    current: averageProtein,
                    target: Double(profileManager.profile.targetProtein),
                    color: Color(red: 0.35, green: 0.67, blue: 1)
                )

                MacroProgressRing(
                    label: lang.t("Carbs", thai: "คาร์บ", japanese: "炭水化物"),
                    current: averageCarbs,
                    target: Double(profileManager.profile.targetCarbs),
                    color: Color(red: 1, green: 0.42, blue: 0.21)
                )

                MacroProgressRing(
                    label: lang.t("Fat", thai: "ไขมัน", japanese: "脂質"),
                    current: averageFat,
                    target: Double(profileManager.profile.targetFat),
                    color: Color(red: 1, green: 0.72, blue: 0)
                )
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 20))
    }

    private var streakCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "flame.fill")
                .font(.title)
                .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))

            VStack(alignment: .leading, spacing: 2) {
                Text("\(calculateStreak()) \(lang.t("Day Streak", thai: "วันติดต่อกัน", japanese: "日連続"))")
                    .font(.headline)

                Text(lang.t("Keep logging to maintain your streak!", thai: "บันทึกต่อเนื่องเพื่อรักษาสถิติ!", japanese: "記録を続けて連続記録を維持！"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 20))
    }

    private var dailyBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(lang.t("Daily Breakdown", thai: "สรุปรายวัน", japanese: "日別内訳"))
                .font(.headline)

            ForEach(recentLogs.reversed()) { log in
                HStack {
                    Text(log.date, format: .dateTime.month(.abbreviated).day())
                        .font(.subheadline.weight(.medium))
                        .frame(width: 60, alignment: .leading)

                    Spacer()

                    HStack(spacing: 12) {
                        Label("\(log.totalCalories)", systemImage: "flame")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.21))

                        Text("\(log.entries.count) \(lang.t("meals", thai: "มื้อ", japanese: "食"))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text(lang.t("No data yet", thai: "ยังไม่มีข้อมูล", japanese: "データがありません"))
                .font(.headline)

            Text(lang.t("Start scanning food to see your progress", thai: "เริ่มสแกนอาหารเพื่อดูความคืบหน้า", japanese: "食事をスキャンして進捗を確認"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }

    private var averageCalories: Int {
        guard !recentLogs.isEmpty else { return 0 }
        return recentLogs.reduce(0) { $0 + $1.totalCalories } / recentLogs.count
    }

    private var averageProtein: Double {
        guard !recentLogs.isEmpty else { return 0 }
        return recentLogs.reduce(0) { $0 + $1.totalProtein } / Double(recentLogs.count)
    }

    private var averageCarbs: Double {
        guard !recentLogs.isEmpty else { return 0 }
        return recentLogs.reduce(0) { $0 + $1.totalCarbs } / Double(recentLogs.count)
    }

    private var averageFat: Double {
        guard !recentLogs.isEmpty else { return 0 }
        return recentLogs.reduce(0) { $0 + $1.totalFat } / Double(recentLogs.count)
    }

    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = Date()

        for _ in 0..<365 {
            if logManager.logs.contains(where: { calendar.isDate($0.date, inSameDayAs: checkDate) && !$0.entries.isEmpty }) {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }
        return streak
    }

    private func dayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: lang.localeIdentifier)
        return String(formatter.string(from: date).prefix(2))
    }
}

struct MacroProgressRing: View {
    let label: String
    let current: Double
    let target: Double
    let color: Color

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(current / target, 1.0)
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 6)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Text("\(Int(current))g")
                    .font(.system(.caption2, design: .rounded, weight: .bold))
            }
            .frame(width: 60, height: 60)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
