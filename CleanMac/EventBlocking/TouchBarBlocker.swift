import AppKit

/// Blanks out the Touch Bar during cleaning mode by hiding all system controls.
/// Gracefully does nothing on Macs without a Touch Bar.
final class TouchBarBlocker {

    private var blankTouchBar: NSTouchBar?

    func block() {
        // Create an empty Touch Bar and assign to all windows
        blankTouchBar = NSTouchBar()
        for window in NSApp.windows {
            window.touchBar = blankTouchBar
        }
    }

    func unblock() {
        for window in NSApp.windows {
            window.touchBar = nil
        }
        blankTouchBar = nil
    }
}
