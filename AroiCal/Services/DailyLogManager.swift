import Foundation

@Observable
@MainActor
class DailyLogManager {
    var logs: [DailyLog] = []

    private let storageKey = "daily_logs"

    init() {
        loadLogs()
    }

    private func loadLogs() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([DailyLog].self, from: data) else { return }
        logs = decoded
    }

    private func saveLogs() {
        if let data = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    func todayLog() -> DailyLog {
        let calendar = Calendar.current
        if let existing = logs.first(where: { calendar.isDateInToday($0.date) }) {
            return existing
        }
        let newLog = DailyLog()
        logs.insert(newLog, at: 0)
        saveLogs()
        return newLog
    }

    func logForDate(_ date: Date) -> DailyLog? {
        let calendar = Calendar.current
        return logs.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func addEntry(_ entry: FoodEntry) {
        let calendar = Calendar.current
        if let index = logs.firstIndex(where: { calendar.isDateInToday($0.date) }) {
            logs[index].entries.append(entry)
        } else {
            var newLog = DailyLog()
            newLog.entries.append(entry)
            logs.insert(newLog, at: 0)
        }
        saveLogs()
    }

    func removeEntry(_ entry: FoodEntry, from date: Date) {
        let calendar = Calendar.current
        if let logIndex = logs.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            logs[logIndex].entries.removeAll { $0.id == entry.id }
            saveLogs()
        }
    }

    func removeEntry(_ entry: FoodEntry) {
        let calendar = Calendar.current
        if let logIndex = logs.firstIndex(where: { calendar.isDateInToday($0.date) }) {
            logs[logIndex].entries.removeAll { $0.id == entry.id }
            saveLogs()
        }
    }

    func currentStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        while true {
            let hasEntries = logs.contains { log in
                calendar.isDate(log.date, inSameDayAs: checkDate) && !log.entries.isEmpty
            }
            if hasEntries {
                streak += 1
                guard let previous = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = previous
            } else {
                break
            }
        }
        return streak
    }

    func logsForLastDays(_ count: Int) -> [DailyLog] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -(count - 1), to: calendar.startOfDay(for: Date()))!
        return logs.filter { $0.date >= startDate }.sorted { $0.date < $1.date }
    }
}
