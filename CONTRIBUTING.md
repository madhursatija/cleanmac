# Contributing to CleanMac

Thanks for your interest in contributing! CleanMac is a small, focused utility — contributions that keep it focused and reliable are most welcome.

## Getting Started

1. Fork the repo
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/CleanMac.git`
3. Build: `swift build`
4. Make your changes
5. Test on macOS 13+ (and ideally 14+ too)
6. Open a pull request

## Development Setup

Requirements:
- Xcode 15+ **or** Swift 5.9 Command Line Tools
- macOS 13 Ventura or later

```sh
swift build          # Debug build
swift build -c release  # Release build
swift package generate-xcodeproj  # Generate Xcode project (optional)
```

## Code Style

- Swift standard conventions (no external linters required)
- Prefer `final class` for managers/singletons
- Keep UI files in SwiftUI; AppKit wrappers go in `Utils/` or alongside their feature
- No force-unwraps in production paths — use `guard let` or `if let`
- All new types should be in the appropriate subfolder matching the architecture in README

## What We Welcome

- Bug fixes
- Performance improvements to the CGEvent tap callback (keep it fast!)
- UI polish improvements
- New settings/preferences
- Better onboarding
- App icon
- Homebrew Cask formula
- Localization (`.strings` files)
- GitHub Actions improvements

## What We'll Decline

- Dependencies/third-party packages (keep it dependency-free)
- Features that require network access
- Anything that touches keylogging or input recording beyond blocking
- Breaking changes to the minimum macOS 13 requirement without strong justification

## Reporting Issues

Use GitHub Issues. Please include:
- macOS version
- What you expected to happen
- What actually happened
- Steps to reproduce

## Security

If you find a security issue (especially around the Accessibility/CGEvent tap usage), please email rather than opening a public issue. See the README for contact info.
