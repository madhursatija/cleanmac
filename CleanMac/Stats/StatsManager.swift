import Foundation
import Combine

// MARK: - Cleaning Session

struct CleaningSession: Codable, Identifiable {
    var id: UUID = UUID()
    let date: Date
    let duration: TimeInterval

    var formattedDuration: String {
        let mins = Int(duration) / 60
        let secs = Int(duration) % 60
        if mins > 0 {
            return "\(mins)m \(secs)s"
        }
        return "\(secs)s"
    }
}

// MARK: - StatsManager

final class StatsManager: ObservableObject {
    static let shared = StatsManager()
    private init() { load() }

    @Published var sessions: [CleaningSession] = []

    // MARK: - Computed Stats

    var totalSessions: Int { sessions.count }

    var totalTime: TimeInterval { sessions.reduce(0) { $0 + $1.duration } }

    var formattedTotalTime: String {
        let total = Int(totalTime)
        let hours = total / 3600
        let mins = (total % 3600) / 60
        if hours > 0 { return "\(hours)h \(mins)m" }
        if mins > 0 { return "\(mins)m" }
        return "\(total)s"
    }

    var longestSession: TimeInterval {
        sessions.map(\.duration).max() ?? 0
    }

    var averageSession: TimeInterval {
        guard !sessions.isEmpty else { return 0 }
        return totalTime / Double(sessions.count)
    }

    /// Streak = consecutive calendar days that had at least one session, ending today
    var currentStreak: Int {
        guard !sessions.isEmpty else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var checkDay = today

        while true {
            let hasCleaned = sessions.contains {
                calendar.startOfDay(for: $0.date) == checkDay
            }
            if hasCleaned {
                streak += 1
                checkDay = calendar.date(byAdding: .day, value: -1, to: checkDay)!
            } else {
                break
            }
        }
        return streak
    }

    var lastCleanedDate: Date? {
        sessions.map(\.date).max()
    }

    // MARK: - Record

    func recordSession(duration: TimeInterval) {
        let session = CleaningSession(date: Date(), duration: duration)
        sessions.append(session)
        save()

        // Update last cleaned for reminders
        UserDefaults.standard.set(Date(), forKey: "lastCleanedDate")
    }

    // MARK: - Persistence

    private let saveKey = "cleaningSessionsV1"

    private func save() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([CleaningSession].self, from: data)
        else { return }
        sessions = decoded
    }
}
