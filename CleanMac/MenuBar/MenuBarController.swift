import AppKit
import SwiftUI

/// Controls the menu bar status item and its popover/menu.
final class MenuBarController {
    private var statusItem: NSStatusItem
    private var popover: NSPopover?
    private var eventMonitor: Any?

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "sparkles", accessibilityDescription: "CleanMac")
            button.image?.isTemplate = true
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        // Register global hotkey
        HotkeyManager.shared.register()

        // Observe cleaning state to update icon
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cleaningStateChanged),
            name: .cleaningStateChanged,
            object: nil
        )
    }

    // MARK: - Toggle popover

    @objc func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }

        if let popover, popover.isShown {
            popover.performClose(sender)
            stopEventMonitor()
        } else {
            let p = NSPopover()
            p.contentViewController = NSHostingController(
                rootView: MenuBarView()
                    .environmentObject(CleaningManager.shared)
                    .environmentObject(SettingsManager.shared)
                    .environmentObject(StatsManager.shared)
            )
            p.behavior = .transient
            p.animates = true
            p.contentSize = NSSize(width: 280, height: 380)
            p.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover = p
            startEventMonitor()
        }
    }

    // MARK: - Close popover on outside click

    private func startEventMonitor() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.popover?.performClose(nil)
            self?.stopEventMonitor()
        }
    }

    private func stopEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        popover = nil
    }

    // MARK: - Icon update

    @objc private func cleaningStateChanged() {
        let active = CleaningManager.shared.isActive
        let iconName = active ? "sparkles.rectangle.stack.fill" : "sparkles"
        statusItem.button?.image = NSImage(systemSymbolName: iconName, accessibilityDescription: "CleanMac")
    }
}

// MARK: - Notification name

extension Notification.Name {
    static let cleaningStateChanged = Notification.Name("cleaningStateChanged")
}
