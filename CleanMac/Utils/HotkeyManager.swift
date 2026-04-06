import Foundation
import AppKit
import Carbon.HIToolbox

/// Registers a global hotkey using Carbon Event Manager.
final class HotkeyManager {
    static let shared = HotkeyManager()
    private init() {}

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?

    func register() {
        unregister()

        let keyCode = UInt32(SettingsManager.shared.hotkeyKeyCode)
        // Convert NSEvent modifier flags int to Carbon modifier format
        let nsModifiers = SettingsManager.shared.hotkeyModifiers
        var carbonMods: UInt32 = 0
        if nsModifiers & Int(NSEvent.ModifierFlags.command.rawValue) != 0 { carbonMods |= UInt32(cmdKey) }
        if nsModifiers & Int(NSEvent.ModifierFlags.shift.rawValue) != 0   { carbonMods |= UInt32(shiftKey) }
        if nsModifiers & Int(NSEvent.ModifierFlags.option.rawValue) != 0  { carbonMods |= UInt32(optionKey) }
        if nsModifiers & Int(NSEvent.ModifierFlags.control.rawValue) != 0 { carbonMods |= UInt32(controlKey) }

        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(0x434C4D43) // "CLMC"
        hotKeyID.id = 1

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, _ -> OSStatus in
                DispatchQueue.main.async {
                    CleaningManager.shared.startCleaning()
                }
                return noErr
            },
            1,
            &eventType,
            nil,
            &eventHandler
        )

        RegisterEventHotKey(
            keyCode,
            carbonMods,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    func unregister() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
        if let handler = eventHandler {
            RemoveEventHandler(handler)
            eventHandler = nil
        }
    }
}
