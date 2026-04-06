import SwiftUI
import AppKit

// NOTE: @main is NOT used here — main.swift is the entry point.
// This file holds the App struct (used for the Settings scene) and AppDelegate.

struct CleanMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarController: MenuBarController?
    var onboardingWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide from Dock
        NSApp.setActivationPolicy(.accessory)

        // Initialise the shared CleaningManager early
        _ = CleaningManager.shared

        // Setup menu bar
        menuBarController = MenuBarController()

        // Schedule notifications if needed
        ReminderManager.shared.scheduleIfNeeded()

        // First launch onboarding
        if !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
            showOnboarding()
        } else {
            PermissionsHelper.shared.requestIfNeeded()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        CleaningManager.shared.stopCleaning()
    }

    // MARK: - Onboarding

    func showOnboarding() {
        let view = OnboardingView {
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            self.onboardingWindow?.close()
            self.onboardingWindow = nil
            PermissionsHelper.shared.requestIfNeeded()
        }
        let hosting = NSHostingController(rootView: view)
        let win = NSWindow(contentViewController: hosting)
        win.title = "Welcome to CleanMac"
        win.styleMask = [.titled, .closable]
        win.isReleasedWhenClosed = false
        win.center()
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        onboardingWindow = win
    }
}
