import Foundation
import AppKit

/// Helpers for the Accessibility permission required by CGEvent taps.
final class PermissionsHelper {
    static let shared = PermissionsHelper()
    private init() {}

    var hasAccessibility: Bool {
        AXIsProcessTrusted()
    }

    /// Prompt the user to grant Accessibility if not already granted.
    func requestIfNeeded() {
        guard !hasAccessibility else { return }

        DispatchQueue.main.async {
            let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true]
            AXIsProcessTrustedWithOptions(options)
        }
    }

    /// Poll until permission is granted, then call the completion handler.
    func waitForAccessibility(completion: @escaping () -> Void) {
        if hasAccessibility {
            completion()
            return
        }
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if AXIsProcessTrusted() {
                timer.invalidate()
                DispatchQueue.main.async { completion() }
            }
        }
    }
}
