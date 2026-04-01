import SwiftUI

struct WaveformView: View {
    let samples: [Float]
    let progress: Double
    let onSeek: (Double) -> Void

    @State private var isDragging = false

    var body: some View {
        GeometryReader { geometry in
            let barWidth: CGFloat = 3
            let barSpacing: CGFloat = 2
            let totalBarWidth = barWidth + barSpacing
            let barCount = samples.isEmpty ? Int(geometry.size.width / totalBarWidth) : samples.count
            let effectiveSamples = samples.isEmpty
                ? Array(repeating: Float(0.3), count: barCount)
                : samples

            ZStack(alignment: .leading) {
                // Background bars
                HStack(alignment: .center, spacing: barSpacing) {
                    ForEach(0..<effectiveSamples.count, id: \.self) { index in
                        let height = max(4, CGFloat(effectiveSamples[index]) * geometry.size.height)
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(Color(.systemGray4))
                            .frame(width: barWidth, height: height)
                    }
                }

                // Progress overlay
                HStack(alignment: .center, spacing: barSpacing) {
                    ForEach(0..<effectiveSamples.count, id: \.self) { index in
                        let height = max(4, CGFloat(effectiveSamples[index]) * geometry.size.height)
                        let barProgress = Double(index) / Double(max(1, effectiveSamples.count - 1))
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(barProgress <= progress ? Color.accentColor : Color.clear)
                            .frame(width: barWidth, height: height)
                    }
                }

                // Playhead
                let playheadX = geometry.size.width * CGFloat(progress)
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: 2, height: geometry.size.height)
                    .offset(x: playheadX)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        let percentage = max(0, min(1, value.location.x / geometry.size.width))
                        onSeek(Double(percentage))
                    }
                    .onEnded { value in
                        isDragging = false
                        let percentage = max(0, min(1, value.location.x / geometry.size.width))
                        onSeek(Double(percentage))
                    }
            )
        }
    }
}
