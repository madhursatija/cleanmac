import Foundation
import Combine

/// Persists and exposes all user-configurable settings.
final class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    // MARK: - Auto-exit timeout

    @Published var autoExitMinutes: Int {
        didSet { UserDefaults.standard.set(autoExitMinutes, forKey: Keys.autoExitMinutes) }
    }

    var autoExitSeconds: Int { autoExitMinutes * 60 }

    // MARK: - Cleaning mode

    @Published var cleaningMode: CleaningMode {
        didSet { UserDefaults.standard.set(cleaningMode.rawValue, forKey: Keys.cleaningMode) }
    }

    // MARK: - Sound

    @Published var playExitSound: Bool {
        didSet { UserDefaults.standard.set(playExitSound, forKey: Keys.playExitSound) }
    }

    // MARK: - Launch at login

    @Published var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: Keys.launchAtLogin)
            LaunchAtLoginHelper.setEnabled(launchAtLogin)
        }
    }

    // MARK: - Global hotkey (stored as key code + modifiers)

    @Published var hotkeyKeyCode: Int {
        didSet { UserDefaults.standard.set(hotkeyKeyCode, forKey: Keys.hotkeyKeyCode) }
    }

    @Published var hotkeyModifiers: Int {
        didSet { UserDefaults.standard.set(hotkeyModifiers, forKey: Keys.hotkeyModifiers) }
    }

    // MARK: - Reminder

    @Published var reminderInterval: ReminderInterval {
        didSet { UserDefaults.standard.set(reminderInterval.rawValue, forKey: Keys.reminderInterval) }
    }

    // MARK: - Init

    private init() {
        // Default values
        let ud = UserDefaults.standard

        autoExitMinutes = ud.integer(forKey: Keys.autoExitMinutes) > 0
            ? ud.integer(forKey: Keys.autoExitMinutes) : 2

        if let raw = ud.string(forKey: Keys.cleaningMode),
           let mode = CleaningMode(rawValue: raw) {
            cleaningMode = mode
        } else {
            cleaningMode = .full
        }

        playExitSound = ud.object(forKey: Keys.playExitSound) as? Bool ?? true

        launchAtLogin = ud.object(forKey: Keys.launchAtLogin) as? Bool ?? false

        hotkeyKeyCode = ud.object(forKey: Keys.hotkeyKeyCode) as? Int ?? 8   // C key
        hotkeyModifiers = ud.object(forKey: Keys.hotkeyModifiers) as? Int ?? 786432 // Cmd+Shift

        if let raw = ud.string(forKey: Keys.reminderInterval),
           let interval = ReminderInterval(rawValue: raw) {
            reminderInterval = interval
        } else {
            reminderInterval = .weekly
        }
    }

    // MARK: - Keys

    private enum Keys {
        static let autoExitMinutes = "autoExitMinutes"
        static let cleaningMode = "cleaningMode"
        static let playExitSound = "playExitSound"
        static let launchAtLogin = "launchAtLogin"
        static let hotkeyKeyCode = "hotkeyKeyCode"
        static let hotkeyModifiers = "hotkeyModifiers"
        static let reminderInterval = "reminderInterval"
    }
}

// MARK: - ReminderInterval

enum ReminderInterval: String, CaseIterable, Identifiable {
    case off = "Off"
    case weekly = "Weekly"
    case biweekly = "Every 2 Weeks"
    case monthly = "Monthly"

    var id: String { rawValue }

    var days: Int? {
        switch self {
        case .off: return nil
        case .weekly: return 7
        case .biweekly: return 14
        case .monthly: return 30
        }
    }
}
