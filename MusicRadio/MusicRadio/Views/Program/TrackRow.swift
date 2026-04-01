import SwiftUI

struct TrackRow: View {
    let track: ProgramTrack
    let index: Int
    let isActive: Bool
    let currentRadioTime: TimeInterval
    let onPlay: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Track artwork
            AsyncImage(url: URL(string: track.artworkUrl ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.systemGray5))
                    .overlay {
                        Image(systemName: "music.note")
                            .foregroundColor(.secondary)
                    }
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            // Track info
            VStack(alignment: .leading, spacing: 4) {
                Text(track.trackName)
                    .font(.subheadline)
                    .fontWeight(isActive ? .semibold : .regular)
                    .foregroundColor(isActive ? .accentColor : .primary)
                    .lineLimit(1)

                Text(track.artistName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Timing badge
            Text(track.playTimingFormatted)
                .font(.caption2)
                .fontWeight(.medium)
                .monospacedDigit()
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isActive ? Color.accentColor.opacity(0.15) : Color(.systemGray6))
                )
                .foregroundColor(isActive ? .accentColor : .secondary)

            // Play button
            Button(action: onPlay) {
                Image(systemName: isActive ? "speaker.wave.2.fill" : "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(isActive ? .accentColor : .secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isActive ? Color.accentColor.opacity(0.08) : Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isActive ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}
