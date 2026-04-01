import SwiftUI
import UIKit

// MARK: - CRATE Play Button

struct CratePlayButton: View {
    enum Size {
        case small
        case medium

        var dimension: CGFloat {
            switch self {
            case .small: return 28
            case .medium: return 44
            }
        }

        var iconScale: CGFloat {
            switch self {
            case .small: return 0.32
            case .medium: return 0.34
            }
        }

        var pauseBarWidth: CGFloat {
            switch self {
            case .small: return 2.0
            case .medium: return 3.0
            }
        }

        var pauseBarSpacing: CGFloat {
            switch self {
            case .small: return 2.5
            case .medium: return 3.5
            }
        }

        var spinnerLineWidth: CGFloat {
            switch self {
            case .small: return 1.5
            case .medium: return 2.0
            }
        }
    }

    enum PlayState {
        case idle
        case playing
        case loading
    }

    let state: PlayState
    var size: Size = .medium
    let action: () -> Void

    @State private var isPressed = false
    @State private var spinnerRotation: Double = 0

    private let haptic = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        Button {
            haptic.impactOccurred()
            action()
        } label: {
            ZStack {
                // Background circle
                Circle()
                    .fill(backgroundFill)
                    .overlay(
                        Circle()
                            .strokeBorder(borderColor, lineWidth: borderWidth)
                    )
                    .frame(width: size.dimension, height: size.dimension)

                // Icon content
                switch state {
                case .idle:
                    PlayTriangleShape()
                        .fill(CrateColors.textTertiary)
                        .frame(
                            width: size.dimension * size.iconScale,
                            height: size.dimension * size.iconScale
                        )
                        .offset(x: size.dimension * 0.03) // Visual centering offset

                case .playing:
                    PauseIconView(
                        barWidth: size.pauseBarWidth,
                        barSpacing: size.pauseBarSpacing,
                        barHeight: size.dimension * size.iconScale
                    )
                    .foregroundColor(CrateColors.void)

                case .loading:
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            CrateColors.void,
                            style: StrokeStyle(
                                lineWidth: size.spinnerLineWidth,
                                lineCap: .round
                            )
                        )
                        .frame(
                            width: size.dimension * 0.4,
                            height: size.dimension * 0.4
                        )
                        .rotationEffect(.degrees(spinnerRotation))
                        .onAppear {
                            withAnimation(
                                .linear(duration: 0.8)
                                .repeatForever(autoreverses: false)
                            ) {
                                spinnerRotation = 360
                            }
                        }
                        .onDisappear {
                            spinnerRotation = 0
                        }
                }
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }

    // MARK: - Style Properties

    private var backgroundFill: Color {
        switch state {
        case .idle:
            return .clear
        case .playing:
            return CrateColors.accent
        case .loading:
            return CrateColors.accent.opacity(0.5)
        }
    }

    private var borderColor: Color {
        switch state {
        case .idle:
            return CrateColors.textDisabled
        case .playing, .loading:
            return .clear
        }
    }

    private var borderWidth: CGFloat {
        switch state {
        case .idle: return 0.5
        case .playing, .loading: return 0
        }
    }
}

// MARK: - Custom Play Triangle Shape

/// Custom triangle that avoids SF Symbols sizing issues at small sizes.
struct PlayTriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Equilateral-ish triangle pointing right
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Pause Icon

/// Two vertical bars for the pause state.
private struct PauseIconView: View {
    let barWidth: CGFloat
    let barSpacing: CGFloat
    let barHeight: CGFloat

    var body: some View {
        HStack(spacing: barSpacing) {
            RoundedRectangle(cornerRadius: barWidth * 0.3)
                .frame(width: barWidth, height: barHeight)
            RoundedRectangle(cornerRadius: barWidth * 0.3)
                .frame(width: barWidth, height: barHeight)
        }
    }
}

// MARK: - Convenience Initializer

extension CratePlayButton {
    /// Creates a CratePlayButton from simple boolean flags.
    init(
        isPlaying: Bool,
        isLoading: Bool = false,
        size: Size = .medium,
        action: @escaping () -> Void
    ) {
        if isLoading {
            self.state = .loading
        } else if isPlaying {
            self.state = .playing
        } else {
            self.state = .idle
        }
        self.size = size
        self.action = action
    }
}

// MARK: - Preview

#Preview("Play Button States") {
    ZStack {
        CrateColors.void.ignoresSafeArea()

        VStack(spacing: 32) {
            Text("Medium")
                .font(.caption)
                .foregroundColor(CrateColors.textSecondary)

            HStack(spacing: 24) {
                CratePlayButton(state: .idle, size: .medium) {}
                CratePlayButton(state: .playing, size: .medium) {}
                CratePlayButton(state: .loading, size: .medium) {}
            }

            Text("Small")
                .font(.caption)
                .foregroundColor(CrateColors.textSecondary)

            HStack(spacing: 24) {
                CratePlayButton(state: .idle, size: .small) {}
                CratePlayButton(state: .playing, size: .small) {}
                CratePlayButton(state: .loading, size: .small) {}
            }
        }
    }
}
