import SwiftUI

/// The fullscreen overlay shown during cleaning mode.
struct OverlayContentView: View {
    @EnvironmentObject var manager: CleaningManager

    var body: some View {
        ZStack {
            // Background — dark blur
            BlurView()
                .ignoresSafeArea()

            // Dim layer
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Icon
                Image(systemName: "sparkles")
                    .font(.system(size: 64, weight: .thin))
                    .foregroundStyle(.white.opacity(0.9))

                // Title
                Text("Cleaning Mode Active")
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Your keyboard and trackpad are disabled")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))

                Spacer()

                // Countdown timer
                CountdownView(seconds: manager.secondsRemaining)

                // ESC hold ring
                EscHoldIndicator(progress: manager.escHoldProgress)
                    .padding(.bottom, 48)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Countdown

struct CountdownView: View {
    let seconds: Int

    private var minutes: Int { seconds / 60 }
    private var secs: Int { seconds % 60 }

    var body: some View {
        VStack(spacing: 6) {
            Text(String(format: "%d:%02d", minutes, secs))
                .font(.system(size: 52, weight: .thin, design: .monospaced))
                .foregroundStyle(.white.opacity(0.85))
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: seconds)

            Text("Auto-exit in")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
                .textCase(.uppercase)
                .kerning(1.5)
        }
    }
}

// MARK: - ESC Hold Ring

struct EscHoldIndicator: View {
    let progress: Double

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Track
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 4)
                    .frame(width: 64, height: 64)

                // Progress arc
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.white.opacity(progress > 0 ? 0.9 : 0.0),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 64, height: 64)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.05), value: progress)

                // ESC label
                Text("ESC")
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(progress > 0 ? 1.0 : 0.5))
            }

            Text("Hold ESC to exit")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
        }
    }
}

// MARK: - Blur View (NSVisualEffectView wrapper)

struct BlurView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.material = .hudWindow
        v.blendingMode = .behindWindow
        v.state = .active
        v.wantsLayer = true
        return v
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
