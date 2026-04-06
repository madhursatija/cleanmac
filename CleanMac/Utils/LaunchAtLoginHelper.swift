import Foundation
import ServiceManagement

/// Handles Launch at Login via SMAppService (macOS 13+).
enum LaunchAtLoginHelper {
    static func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            // Not fatal — user can still add manually
            print("[LaunchAtLogin] Error: \(error.localizedDescription)")
        }
    }

    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }
}
