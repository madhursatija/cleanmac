import SwiftUI

/// Settings window — all user-configurable preferences.
struct SettingsView: View {
    @ObservedObject var settings = SettingsManager.shared
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsTab()
                .tabItem { Label("General", systemImage: "gearshape") }
                .tag(0)

            CleaningSettingsTab()
                .tabItem { Label("Cleaning", systemImage: "sparkles") }
                .tag(1)

            StatsSettingsTab()
                .tabItem { Label("Stats", systemImage: "chart.bar") }
                .tag(2)

            AboutTab()
                .tabItem { Label("About", systemImage: "info.circle") }
                .tag(3)
        }
        .frame(width: 460, height: 340)
    }
}

// MARK: - General Tab

struct GeneralSettingsTab: View {
    @ObservedObject var settings = SettingsManager.shared

    var body: some View {
        Form {
            Section("Behaviour") {
                Toggle("Launch at login", isOn: $settings.launchAtLogin)
                Toggle("Play sound when exiting cleaning mode", isOn: $settings.playExitSound)
            }

            Section("Auto-exit Timer") {
                Picker("Exit after", selection: $settings.autoExitMinutes) {
                    Text("1 minute").tag(1)
                    Text("2 minutes").tag(2)
                    Text("5 minutes").tag(5)
                    Text("10 minutes").tag(10)
                    Text("Never").tag(999)
                }
                .pickerStyle(.menu)
                .frame(maxWidth: 200)
            }

            Section("Cleaning Reminders") {
                Picker("Remind me to clean", selection: $settings.reminderInterval) {
                    ForEach(ReminderInterval.allCases) { interval in
                        Text(interval.rawValue).tag(interval)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: 200)
                .onChange(of: settings.reminderInterval) { _ in
                    ReminderManager.shared.scheduleIfNeeded()
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Cleaning Tab

struct CleaningSettingsTab: View {
    @ObservedObject var settings = SettingsManager.shared

    var body: some View {
        Form {
            Section("Cleaning Mode") {
                Picker("What to disable", selection: $settings.cleaningMode) {
                    ForEach(CleaningMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.radioGroup)
            }

            Section("Global Shortcut") {
                HStack {
                    Text("Activate with")
                    Spacer()
                    Text("⌘⇧C")
                        .font(.system(.body, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.windowBackgroundColor))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(.separatorColor), lineWidth: 1)
                        )
                }
                Text("Custom hotkey recording coming in v1.1")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Stats Tab

struct StatsSettingsTab: View {
    @ObservedObject var stats = StatsManager.shared

    var body: some View {
        VStack(spacing: 20) {
            // Big numbers
            HStack(spacing: 32) {
                BigStat(value: "\(stats.totalSessions)", label: "Total Sessions", icon: "sparkles")
                BigStat(value: stats.formattedTotalTime, label: "Time Cleaning", icon: "clock")
                BigStat(value: "\(stats.currentStreak)", label: "Day Streak", icon: "flame")
            }

            Divider()

            // Recent sessions
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent Sessions")
                    .font(.headline)
                    .padding(.horizontal)

                if stats.sessions.isEmpty {
                    Text("No sessions yet. Start cleaning!")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    List(stats.sessions.suffix(5).reversed()) { session in
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundStyle(.secondary)
                            Text(session.date, style: .relative)
                                .font(.callout)
                            Spacer()
                            Text(session.formattedDuration)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .listStyle(.plain)
                    .frame(height: 120)
                }
            }
        }
        .padding()
    }
}

struct BigStat: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(minWidth: 80)
    }
}

// MARK: - About Tab

struct AboutTab: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 52))
                .foregroundStyle(.primary)

            Text("CleanMac")
                .font(.title)
                .fontWeight(.bold)

            Text("Version 1.0.0")
                .font(.callout)
                .foregroundStyle(.secondary)

            Text("A lightweight macOS cleaning mode utility.\nDisable your keyboard and trackpad while you clean.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .font(.callout)

            Divider()

            HStack(spacing: 20) {
                Link("GitHub", destination: URL(string: "https://github.com/madhursatija/cleanmac")!)
                    .font(.callout)
                Link("MIT License", destination: URL(string: "https://opensource.org/licenses/MIT")!)
                    .font(.callout)
            }

            Text("Built with Swift & SwiftUI")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
