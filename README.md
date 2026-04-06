# CleanMac

**Cleaning mode for macOS.** Disable your keyboard, trackpad, and mouse instantly so you can safely wipe your screen and keyboard without triggering shortcuts or opening random apps.

---

## Features

- **Full input blocking** — Keyboard, trackpad, and mouse all silenced during cleaning
- **Touch Bar blocking** — Clears the Touch Bar on supported MacBook Pros
- **Hold ESC to exit** — Hold Escape for 3 seconds; a progress ring shows your hold
- **Auto-exit timer** — Safety net exit after a configurable timeout (default: 2 min)
- **Global hotkey** — Activate with `⌘⇧C` from anywhere, no clicking required
- **Menu bar app** — Lives in your menu bar; no Dock icon cluttering things up
- **Cleaning stats** — Tracks sessions, total time, and day streaks
- **Cleaning reminders** — Optional notifications so you never forget to clean
- **Selective modes** — Block everything, keyboard only, or trackpad/mouse only
- **Launch at login** — Optional, so it's always ready
- **Onboarding** — Friendly first-launch setup with permission guidance

## Requirements

- macOS 13 Ventura or later
- Accessibility permission (required for input blocking — no keystrokes are logged)

## Installation

### Download (Manual)

Download the latest `.dmg` from the [Releases](https://github.com/madhursatija/cleanmac/releases) page.

> **Note:** The app is not notarized. On first launch, right-click the app in Finder → **Open** → **Open** to bypass Gatekeeper. This only needs to be done once.

### Build from Source

Requires Swift 5.9+ and macOS 13+ SDK (comes with Xcode 15+ or Command Line Tools).

```sh
git clone https://github.com/madhursatija/cleanmac.git
cd cleanmac
swift build -c release
```

The built binary will be at `.build/release/CleanMac`.

To build a proper `.app` bundle, open the project in Xcode and use Product → Archive.

## How it Works

1. **Launch** — Click the sparkles icon in your menu bar (or press `⌘⇧C`)
2. **Clean** — Your keyboard, trackpad, and mouse are disabled. A fullscreen dark overlay appears with a countdown
3. **Exit** — Hold `ESC` for 3 seconds (a progress ring fills as you hold), or wait for the auto-exit timer

## Permissions

CleanMac requires **Accessibility** permission to intercept and block input events via macOS's CGEvent tap API. This is the same mechanism used by apps like Karabiner-Elements and Alfred.

**CleanMac does not:**
- Log, store, or transmit any keystrokes
- Access the internet
- Read your files

You can verify this in the source code — it's all right here.

## Architecture

```
CleanMac/
├── App/
│   ├── main.swift              # Entry point
│   ├── CleanMacApp.swift       # App + AppDelegate
│   ├── CleaningManager.swift   # Central state machine
│   └── OnboardingView.swift    # First-launch flow
├── MenuBar/
│   ├── MenuBarController.swift # NSStatusItem controller
│   └── MenuBarView.swift       # Popover UI
├── Overlay/
│   ├── OverlayWindowManager.swift  # Fullscreen NSPanel manager
│   └── OverlayContentView.swift    # Overlay UI (timer, ESC ring)
├── EventBlocking/
│   ├── EventTapManager.swift   # CGEvent tap (keyboard/mouse)
│   └── TouchBarBlocker.swift   # Touch Bar silencer
├── Settings/
│   ├── SettingsManager.swift   # UserDefaults wrapper
│   └── SettingsView.swift      # Preferences UI
├── Stats/
│   └── StatsManager.swift      # Session tracking
├── Reminders/
│   └── ReminderManager.swift   # UNUserNotificationCenter
├── Permissions/
│   └── PermissionsHelper.swift # AXIsProcessTrusted helper
└── Utils/
    ├── HotkeyManager.swift     # Carbon global hotkey
    └── LaunchAtLoginHelper.swift # SMAppService wrapper
```

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

**Good first issues:**
- Custom hotkey recorder UI (currently hardcoded to `⌘⇧C`)
- App icon design
- Homebrew Cask formula
- Localization

## License

MIT — see [LICENSE](LICENSE).

---

*Built because accidentally opening 12 apps while cleaning your keyboard gets old fast.*
