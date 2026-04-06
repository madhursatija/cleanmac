import SwiftUI

/// First-launch onboarding flow.
struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var step = 0

    var body: some View {
        VStack(spacing: 0) {
            // Step indicator
            HStack(spacing: 6) {
                ForEach(0..<3) { i in
                    Capsule()
                        .fill(i == step ? Color.primary : Color(.separatorColor))
                        .frame(width: i == step ? 20 : 6, height: 6)
                        .animation(.spring(response: 0.3), value: step)
                }
            }
            .padding(.top, 28)

            Spacer()

            // Step content
            Group {
                switch step {
                case 0: WelcomeStep()
                case 1: HowItWorksStep()
                case 2: PermissionsStep(onComplete: onComplete)
                default: EmptyView()
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .animation(.easeInOut(duration: 0.3), value: step)

            Spacer()

            // Navigation
            if step < 2 {
                Button {
                    withAnimation { step += 1 }
                } label: {
                    Text("Continue")
                        .frame(width: 200)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 28)
            }
        }
        .frame(width: 400, height: 380)
    }
}

struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 64))

            Text("Welcome to CleanMac")
                .font(.title)
                .fontWeight(.bold)

            Text("Clean your screen and keyboard safely,\nwithout triggering anything.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct HowItWorksStep: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("How it works")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .center)

            stepRow(icon: "1.circle.fill", title: "Activate", body: "Click the menu bar icon or press ⌘⇧C")
            stepRow(icon: "2.circle.fill", title: "Clean", body: "Your keyboard and trackpad are now disabled")
            stepRow(icon: "3.circle.fill", title: "Exit", body: "Hold ESC for 3 seconds, or wait for auto-exit")
        }
        .padding(.horizontal, 40)
    }

    @ViewBuilder
    private func stepRow(icon: String, title: String, body: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).fontWeight(.semibold)
                Text(body).font(.callout).foregroundStyle(.secondary)
            }
        }
    }
}

struct PermissionsStep: View {
    let onComplete: () -> Void
    @State private var hasPermission = AXIsProcessTrusted()
    @State private var polling = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: hasPermission ? "checkmark.shield.fill" : "lock.shield")
                .font(.system(size: 56))
                .foregroundStyle(hasPermission ? .green : .orange)
                .animation(.easeInOut, value: hasPermission)

            Text("Accessibility Permission")
                .font(.title2)
                .fontWeight(.bold)

            Text("CleanMac needs Accessibility access to intercept keyboard and trackpad events.\n\nYour data is never read — only input events are blocked.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            if hasPermission {
                Button {
                    onComplete()
                } label: {
                    Label("All set — let's go!", systemImage: "checkmark")
                        .frame(width: 200)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            } else {
                Button {
                    openAccessibilityPrefs()
                    startPolling()
                } label: {
                    Text("Grant Permission")
                        .frame(width: 200)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private func openAccessibilityPrefs() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true]
        AXIsProcessTrustedWithOptions(options)
    }

    private func startPolling() {
        guard !polling else { return }
        polling = true
        Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { timer in
            if AXIsProcessTrusted() {
                withAnimation { hasPermission = true }
                timer.invalidate()
            }
        }
    }
}
