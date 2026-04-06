import Foundation
import CoreGraphics
import AppKit

/// Manages CGEvent taps to block keyboard and/or mouse/trackpad input.
final class EventTapManager {
    static let shared = EventTapManager()
    private init() {}

    var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var currentMode: CleaningMode = .full

    // MARK: - Start / Stop

    func start(mode: CleaningMode) {
        currentMode = mode
        installTap(mode: mode)
    }

    func stop() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil
    }

    // MARK: - Private

    private func installTap(mode: CleaningMode) {
        // Remove existing tap first
        stop()

        // Build the event mask based on mode
        var mask: CGEventMask = 0

        if mode == .full || mode == .keyboardOnly {
            mask |= (1 << CGEventType.keyDown.rawValue)
            mask |= (1 << CGEventType.keyUp.rawValue)
            mask |= (1 << CGEventType.flagsChanged.rawValue)
        }

        if mode == .full || mode == .trackpadOnly {
            mask |= (1 << CGEventType.leftMouseDown.rawValue)
            mask |= (1 << CGEventType.leftMouseUp.rawValue)
            mask |= (1 << CGEventType.rightMouseDown.rawValue)
            mask |= (1 << CGEventType.rightMouseUp.rawValue)
            mask |= (1 << CGEventType.otherMouseDown.rawValue)
            mask |= (1 << CGEventType.otherMouseUp.rawValue)
            mask |= (1 << CGEventType.scrollWheel.rawValue)
            mask |= (1 << CGEventType.mouseMoved.rawValue)
            mask |= (1 << CGEventType.leftMouseDragged.rawValue)
            mask |= (1 << CGEventType.rightMouseDragged.rawValue)
        }

        // The callback is a C function — use an unmanaged pointer to bridge self
        let selfPtr = Unmanaged.passRetained(self).toOpaque()

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: eventTapCallback,
            userInfo: selfPtr
        ) else {
            // Accessibility not granted
            PermissionsHelper.shared.requestIfNeeded()
            Unmanaged<EventTapManager>.fromOpaque(selfPtr).release()
            return
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }
}

// MARK: - CGEvent tap callback (must be a free C function)

private func eventTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {

    // Tap disabled event — re-enable
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let ptr = userInfo {
            let manager = Unmanaged<EventTapManager>.fromOpaque(ptr).takeUnretainedValue()
            if let tap = manager.eventTap {
                CGEvent.tapEnable(tap: tap, enable: true)
            }
        }
        return Unmanaged.passRetained(event)
    }

    let cleaning = CleaningManager.shared

    // Handle ESC key specially — allow through but track hold
    if type == .keyDown {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        if keyCode == 53 { // ESC keycode
            DispatchQueue.main.async { cleaning.escKeyBegan() }
            return nil // Suppress the actual ESC key event
        }
    }

    if type == .keyUp {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        if keyCode == 53 {
            DispatchQueue.main.async { cleaning.escKeyEnded() }
            return nil
        }
    }

    // Suppress all other matched events
    return nil
}
