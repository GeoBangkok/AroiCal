import Foundation

@Observable
@MainActor
class WeightLogManager {
    var entries: [WeightEntry] = []

    private let storageKey = "weight_log"

    init() {
        load()
    }

    func logWeight(_ kg: Double, for date: Date = Date()) {
        let calendar = Calendar.current
        if let idx = entries.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            entries[idx] = WeightEntry(date: date, weightKg: kg)
        } else {
            entries.append(WeightEntry(date: date, weightKg: kg))
        }
        entries.sort { $0.date < $1.date }
        save()
    }

    func entryForToday() -> WeightEntry? {
        let calendar = Calendar.current
        return entries.first { calendar.isDateInToday($0.date) }
    }

    func entriesForLastDays(_ count: Int) -> [WeightEntry] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -(count - 1), to: calendar.startOfDay(for: Date()))!
        return entries.filter { $0.date >= startDate }.sorted { $0.date < $1.date }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([WeightEntry].self, from: data) else { return }
        entries = decoded
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
