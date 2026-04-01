import SwiftUI

// MARK: - CRATE Progress Bar

/// A minimal 2px progress bar using CRATE design tokens.
struct CrateProgressBar: View {
    /// Progress value from 0.0 to 1.0.
    let progress: Double

    /// Track height. Defaults to 2px per spec.
    var height: CGFloat = 2

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track background
                RoundedRectangle(cornerRadius: 1)
                    .fill(CrateColors.elevated)
                    .frame(height: height)

                // Fill
                RoundedRectangle(cornerRadius: 1)
                    .fill(CrateColors.accent)
                    .frame(
                        width: geometry.size.width * CGFloat(clampedProgress),
                        height: height
                    )
            }
        }
        .frame(height: height)
    }

    private var clampedProgress: Double {
        max(0, min(1, progress))
    }
}

// MARK: - Interactive Variant

/// A progress bar that supports tap-to-seek and drag-to-scrub.
struct CrateInteractiveProgressBar: View {
    let progress: Double
    let onSeek: (Double) -> Void

    var height: CGFloat = 2
    /// Expanded hit area height for easier interaction.
    var hitAreaHeight: CGFloat = 24

    @State private var isDragging = false
    @State private var dragProgress: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track background
                RoundedRectangle(cornerRadius: 1)
                    .fill(CrateColors.elevated)
                    .frame(height: height)
                    .frame(maxHeight: .infinity, alignment: .center)

                // Fill
                let effectiveProgress = isDragging ? dragProgress : progress
                RoundedRectangle(cornerRadius: 1)
                    .fill(CrateColors.accent)
                    .frame(
                        width: geometry.size.width * CGFloat(max(0, min(1, effectiveProgress))),
                        height: height
                    )
                    .frame(maxHeight: .infinity, alignment: .center)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        let pct = max(0, min(1, Double(value.location.x / geometry.size.width)))
                        dragProgress = pct
                        onSeek(pct)
                    }
                    .onEnded { value in
                        let pct = max(0, min(1, Double(value.location.x / geometry.size.width)))
                        onSeek(pct)
                        isDragging = false
                    }
            )
        }
        .frame(height: hitAreaHeight)
    }
}

// MARK: - Preview

#Preview("Progress Bars") {
    ZStack {
        CrateColors.void.ignoresSafeArea()

        VStack(spacing: 32) {
            Text("0%")
                .font(.caption)
                .foregroundColor(CrateColors.textSecondary)
            CrateProgressBar(progress: 0)
                .padding(.horizontal, 24)

            Text("35%")
                .font(.caption)
                .foregroundColor(CrateColors.textSecondary)
            CrateProgressBar(progress: 0.35)
                .padding(.horizontal, 24)

            Text("75%")
                .font(.caption)
                .foregroundColor(CrateColors.textSecondary)
            CrateProgressBar(progress: 0.75)
                .padding(.horizontal, 24)

            Text("100%")
                .font(.caption)
                .foregroundColor(CrateColors.textSecondary)
            CrateProgressBar(progress: 1.0)
                .padding(.horizontal, 24)

            Text("Interactive (drag me)")
                .font(.caption)
                .foregroundColor(CrateColors.textSecondary)
            CrateInteractiveProgressBar(progress: 0.5) { pct in
                print("Seek to \(pct)")
            }
            .padding(.horizontal, 24)
        }
    }
}
