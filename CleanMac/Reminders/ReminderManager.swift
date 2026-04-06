import Foundation
import UserNotifications

/// Manages scheduled cleaning reminders using UNUserNotificationCenter.
final class ReminderManager {
    static let shared = ReminderManager()
    private init() {}

    private let categoryID = "CLEANING_REMINDER"
    private let actionID = "CLEAN_NOW"
    private let notificationID = "cleanmac.reminder"

    // MARK: - Setup

    func scheduleIfNeeded() {
        let interval = SettingsManager.shared.reminderInterval
        guard interval != .off else {
            cancelReminder()
            return
        }

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            DispatchQueue.main.async { self.scheduleReminder(interval: interval) }
        }

        // Register action category
        let cleanAction = UNNotificationAction(
            identifier: actionID,
            title: "Clean Now",
            options: [.foreground]
        )
        let category = UNNotificationCategory(
            identifier: categoryID,
            actions: [cleanAction],
            intentIdentifiers: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    func scheduleReminder(interval: ReminderInterval) {
        guard let days = interval.days else {
            cancelReminder()
            return
        }

        // Check when last cleaned
        let lastCleaned = UserDefaults.standard.object(forKey: "lastCleanedDate") as? Date ?? .distantPast
        let daysSince = Calendar.current.dateComponents([.day], from: lastCleaned, to: Date()).day ?? 999

        if daysSince >= days {
            // Fire soon (slight delay to avoid immediate ping on launch)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
            deliverNotification(trigger: trigger, overdue: true)
        } else {
            // Schedule for when the interval elapses
            let nextDate = Calendar.current.date(byAdding: .day, value: days, to: lastCleaned) ?? Date()
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: nextDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            deliverNotification(trigger: trigger, overdue: false)
        }
    }

    func cancelReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])
    }

    // MARK: - Private

    private func deliverNotification(trigger: UNNotificationTrigger, overdue: Bool) {
        let content = UNMutableNotificationContent()
        content.title = overdue ? "Time to clean your Mac!" : "Your Mac could use a clean"
        content.body = overdue
            ? "It's been a while since you last cleaned. Your screen and keyboard deserve some love."
            : "Regular cleaning keeps your Mac looking fresh. Open CleanMac to get started."
        content.sound = .default
        content.categoryIdentifier = categoryID

        let request = UNNotificationRequest(
            identifier: notificationID,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}
