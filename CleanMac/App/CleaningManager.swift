import Foundation
import Combine
import AppKit

// MARK: - Cleaning Mode Options

enum CleaningMode: String, CaseIterable, Identifiable {
    case full = "Full (Keyboard + Trackpad + Mouse)"
    case keyboardOnly = "Keyboard Only"
    case trackpadOnly = "Trackpad & Mouse Only"

    var id: String { rawValue }
}

// MARK: - CleaningManager

/// Central controller for all cleaning mode logic.
final class CleaningManager: ObservableObject {
    static let shared = CleaningManager()

    // MARK: Published state

    @Published var isActive: Bool = false
    @Published var secondsRemaining: Int = 120
    @Published var escHoldProgress: Double = 0.0   // 0.0 – 1.0

    // MARK: Private

    private var autoExitTimer: Timer?
    private var escHoldTimer: Timer?
    private var escHoldStart: Date?
    private var sessionStart: Date?

    private let escHoldDuration: TimeInterval = 3.0

    private let touchBarBlocker = TouchBarBlocker()
    private var settings: SettingsManager { SettingsManager.shared }

    private init() {}

    // MARK: - Public API

    func startCleaning() {
        guard !isActive else { return }

        // Ensure accessibility permission
        guard PermissionsHelper.shared.hasAccessibility else {
            PermissionsHelper.shared.requestIfNeeded()
            return
        }

        sessionStart = Date()
        secondsRemaining = settings.autoExitSeconds
        isActive = true

        // Activate event blocking
        EventTapManager.shared.start(mode: settings.cleaningMode)

        // Block Touch Bar
        touchBarBlocker.block()

        // Show overlay on all screens
        OverlayWindowManager.shared.showOverlay()

        // Start auto-exit countdown
        startAutoExitTimer()

        // Global hotkey is still needed to re-register; but ESC is handled inside EventTap
    }

    func stopCleaning() {
        guard isActive else { return }

        isActive = false
        escHoldProgress = 0.0
        escHoldStart = nil

        // Stop event blocking
        EventTapManager.shared.stop()

        // Unblock Touch Bar
        touchBarBlocker.unblock()

        // Hide overlay
        OverlayWindowManager.shared.hideOverlay()

        // Stop timers
        autoExitTimer?.invalidate()
        autoExitTimer = nil
        escHoldTimer?.invalidate()
        escHoldTimer = nil

        // Record stats
        if let start = sessionStart {
            let duration = Date().timeIntervalSince(start)
            StatsManager.shared.recordSession(duration: duration)
            sessionStart = nil
        }

        // Sound feedback
        if settings.playExitSound {
            NSSound.beep()
        }
    }

    // MARK: - ESC Hold Logic (called by EventTapManager)

    func escKeyBegan() {
        escHoldStart = Date()
        escHoldProgress = 0.0
        startEscHoldTimer()
    }

    func escKeyEnded() {
        escHoldStart = nil
        escHoldProgress = 0.0
        escHoldTimer?.invalidate()
        escHoldTimer = nil
    }

    // MARK: - Private Timers

    private func startAutoExitTimer() {
        autoExitTimer?.invalidate()
        autoExitTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.secondsRemaining > 0 {
                self.secondsRemaining -= 1
            } else {
                self.stopCleaning()
            }
        }
        RunLoop.main.add(autoExitTimer!, forMode: .common)
    }

    private func startEscHoldTimer() {
        escHoldTimer?.invalidate()
        escHoldTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self, let start = self.escHoldStart else { return }
            let elapsed = Date().timeIntervalSince(start)
            self.escHoldProgress = min(elapsed / self.escHoldDuration, 1.0)
            if elapsed >= self.escHoldDuration {
                self.stopCleaning()
            }
        }
        RunLoop.main.add(escHoldTimer!, forMode: .common)
    }
}
