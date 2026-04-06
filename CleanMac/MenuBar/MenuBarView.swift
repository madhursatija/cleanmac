import SwiftUI

/// The popover content shown when clicking the menu bar icon.
struct MenuBarView: View {
    @EnvironmentObject var manager: CleaningManager
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var stats: StatsManager

    @State private var showStats = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection

            Divider()

            // Main action
            actionSection

            Divider()

            // Stats preview
            statsSection

            Divider()

            // Footer
            footerSection
        }
        .frame(width: 280)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 2) {
                Text("CleanMac")
                    .font(.headline)
                Text("Cleaning mode for macOS")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Action

    private var actionSection: some View {
        VStack(spacing: 8) {
            Button {
                CleaningManager.shared.startCleaning()
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Start Cleaning Mode")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(.primary)
            .disabled(manager.isActive)
            .padding(.horizontal, 16)

            Text("Or press ⌘⇧C anywhere")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 12)
    }

    // MARK: - Stats

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cleaning History")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .kerning(0.5)
                .padding(.horizontal, 16)

            HStack(spacing: 0) {
                StatPill(
                    value: "\(stats.totalSessions)",
                    label: "Sessions"
                )
                Divider().frame(height: 30)
                StatPill(
                    value: stats.formattedTotalTime,
                    label: "Total Time"
                )
                Divider().frame(height: 30)
                StatPill(
                    value: "\(stats.currentStreak)",
                    label: "Day Streak"
                )
            }
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 12)
    }

    // MARK: - Footer

    private var footerSection: some View {
        HStack {
            Button("Settings") {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                NSApp.activate(ignoringOtherApps: true)
            }
            .buttonStyle(.plain)
            .font(.callout)

            Spacer()

            Button("Quit") {
                NSApp.terminate(nil)
            }
            .buttonStyle(.plain)
            .font(.callout)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - StatPill

struct StatPill: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }
}
