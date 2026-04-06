import AppKit

// Entry point for the CleanMac application.
// This file must be the ONLY file in the module without the @main attribute.
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
