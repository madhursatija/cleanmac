import Foundation
import AppKit
import SwiftUI

/// Manages the fullscreen overlay windows (one per screen).
final class OverlayWindowManager {
    static let shared = OverlayWindowManager()
    private init() {}

    private var overlayWindows: [CleaningOverlayWindow] = []

    func showOverlay() {
        hideOverlay() // Clear any existing

        for screen in NSScreen.screens {
            let win = CleaningOverlayWindow(screen: screen)
            win.makeKeyAndOrderFront(nil)
            overlayWindows.append(win)
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    func hideOverlay() {
        overlayWindows.forEach { $0.close() }
        overlayWindows.removeAll()
    }
}

// MARK: - CleaningOverlayWindow

final class CleaningOverlayWindow: NSPanel {

    init(screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        // Sit above everything — screensaver level
        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.screenSaverWindow)))
        isOpaque = false
        backgroundColor = .clear
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        ignoresMouseEvents = false
        isMovable = false
        isReleasedWhenClosed = false
        hidesOnDeactivate = false

        // Position on the given screen
        setFrame(screen.frame, display: false)

        // SwiftUI content
        let hosting = NSHostingController(
            rootView: OverlayContentView()
                .environmentObject(CleaningManager.shared)
        )
        contentViewController = hosting
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
