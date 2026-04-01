import SwiftUI

// MARK: - CRATE Waveform View

/// The most important brand component. Vertical bar-style waveform with seek/scrub support.
struct CrateWaveformView: View {
    /// Normalized waveform samples in 0.0...1.0 range.
    let samples: [Float]

    /// Current playback progress (0.0...1.0).
    let progress: Double

    /// Called when user taps or drags to seek.
    let onSeek: (Double) -> Void

    // MARK: - Layout Constants

    private let barWidth: CGFloat = 2
    private let barSpacing: CGFloat = 3 // 5px pitch total
    private let barCornerRadius: CGFloat = 1
    private let minBarHeight: CGFloat = 4
    private let maxBarHeight: CGFloat = 32

    // MARK: - State

    @State private var isDragging = false
    @State private var dragProgress: Double = 0
    @State private var pulsatingOpacity: Double = 0.6

    var body: some View {
        GeometryReader { geometry in
            let totalPitch = barWidth + barSpacing
            let barCount = max(1, Int(geometry.size.width / totalPitch))
            let resampledData = resample(samples, to: barCount)
            let effectiveProgress = isDragging ? dragProgress : progress
            let currentBarIndex = Int(effectiveProgress * Double(barCount - 1))

            HStack(alignment: .center, spacing: barSpacing) {
                ForEach(0..<barCount, id: \.self) { index in
                    let sample = resampledData[index]
                    let barHeight = max(
                        minBarHeight,
                        min(maxBarHeight, CGFloat(sample) * maxBarHeight)
                    )
                    let isPlayed = index <= currentBarIndex
                    let isCurrent = index == currentBarIndex

                    RoundedRectangle(cornerRadius: barCornerRadius)
                        .fill(isPlayed ? CrateColors.accent : CrateColors.textDisabled)
                        .frame(width: barWidth, height: barHeight)
                        .opacity(isCurrent ? pulsatingOpacity : 1.0)
                }
            }
            .frame(maxHeight: .infinity, alignment: .center)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        let percentage = clampProgress(
                            value.location.x / geometry.size.width
                        )
                        dragProgress = percentage
                        onSeek(percentage)
                    }
                    .onEnded { value in
                        let percentage = clampProgress(
                            value.location.x / geometry.size.width
                        )
                        onSeek(percentage)
                        isDragging = false
                    }
            )
        }
        .onAppear {
            startPulseAnimation()
        }
    }

    // MARK: - Pulse Animation

    private func startPulseAnimation() {
        withAnimation(
            .easeInOut(duration: 1.0)
            .repeatForever(autoreverses: true)
        ) {
            pulsatingOpacity = 1.0
        }
    }

    // MARK: - Helpers

    private func clampProgress(_ value: CGFloat) -> Double {
        return Double(max(0, min(1, value)))
    }

    /// Resample the input array to the target count using linear interpolation.
    private func resample(_ data: [Float], to targetCount: Int) -> [Float] {
        guard targetCount > 0 else { return [] }
        guard !data.isEmpty else {
            // Return a subtle idle waveform when no data
            return (0..<targetCount).map { i in
                let normalized = Float(i) / Float(max(1, targetCount - 1))
                return 0.15 + 0.1 * sin(normalized * .pi * 4)
            }
        }
        guard data.count > 1 else {
            return Array(repeating: data[0], count: targetCount)
        }

        var result = [Float](repeating: 0, count: targetCount)
        let ratio = Float(data.count - 1) / Float(max(1, targetCount - 1))

        for i in 0..<targetCount {
            let srcIndex = Float(i) * ratio
            let lower = Int(srcIndex)
            let upper = min(lower + 1, data.count - 1)
            let fraction = srcIndex - Float(lower)
            result[i] = data[lower] * (1 - fraction) + data[upper] * fraction
        }

        return result
    }
}

// MARK: - Preview

#Preview("Waveform View") {
    ZStack {
        CrateColors.void.ignoresSafeArea()

        VStack(spacing: 24) {
            Text("With Data")
                .font(.caption)
                .foregroundColor(CrateColors.textSecondary)

            CrateWaveformView(
                samples: (0..<80).map { _ in Float.random(in: 0.1...1.0) },
                progress: 0.35,
                onSeek: { _ in }
            )
            .frame(height: 40)
            .padding(.horizontal, 16)

            Text("Empty / Loading")
                .font(.caption)
                .foregroundColor(CrateColors.textSecondary)

            CrateWaveformView(
                samples: [],
                progress: 0,
                onSeek: { _ in }
            )
            .frame(height: 40)
            .padding(.horizontal, 16)

            Text("Progress at 75%")
                .font(.caption)
                .foregroundColor(CrateColors.textSecondary)

            CrateWaveformView(
                samples: (0..<120).map { i in
                    0.2 + 0.8 * abs(sin(Float(i) * 0.15))
                },
                progress: 0.75,
                onSeek: { _ in }
            )
            .frame(height: 40)
            .padding(.horizontal, 16)
        }
    }
}
