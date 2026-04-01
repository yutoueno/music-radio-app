import SwiftUI

struct TrackCard: View {
    let track: ProgramTrack
    var isActive: Bool = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 0) {
                // Left accent border
                RoundedRectangle(cornerRadius: 1)
                    .fill(isActive ? CrateColors.accent : CrateColors.border.opacity(0.3))
                    .frame(width: 2)
                    .padding(.vertical, 4)

                HStack(spacing: 10) {
                    // Artwork or music note
                    TrackArtwork(
                        url: track.artworkUrl,
                        size: 40,
                        isActive: isActive
                    )

                    // Track info
                    VStack(alignment: .leading, spacing: 3) {
                        Text(track.title)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(
                                isActive ? CrateColors.accent : CrateColors.textPrimary
                            )
                            .lineLimit(1)

                        Text(track.artistName)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(CrateColors.textSecondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Timing badge
                    Text(track.playTimingFormatted)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .tracking(0.5)
                        .foregroundColor(
                            isActive ? CrateColors.accent : CrateColors.textTertiary
                        )
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            isActive
                                ? CrateColors.accent.opacity(0.12)
                                : CrateColors.elevated
                        )
                        .cornerRadius(4)
                }
                .padding(.leading, 10)
                .padding(.trailing, 12)
                .padding(.vertical, 10)
            }
            .background(
                isActive
                    ? CrateColors.accent.opacity(0.05)
                    : Color.clear
            )
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.25), value: isActive)
    }
}

// MARK: - Track Artwork

struct TrackArtwork: View {
    let url: String?
    var size: CGFloat = 40
    var isActive: Bool = false

    var body: some View {
        Group {
            if let urlString = url, let imageURL = URL(string: urlString) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        artworkPlaceholder
                    case .empty:
                        SkeletonView(cornerRadius: 6)
                    @unknown default:
                        artworkPlaceholder
                    }
                }
            } else {
                artworkPlaceholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var artworkPlaceholder: some View {
        ZStack {
            CrateColors.elevated
            Image(systemName: "music.note")
                .font(.system(size: size * 0.35))
                .foregroundColor(
                    isActive ? CrateColors.accent : CrateColors.textTertiary
                )
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 4) {
        TrackCard(
            track: .preview,
            isActive: false,
            onTap: {}
        )
        TrackCard(
            track: .preview,
            isActive: true,
            onTap: {}
        )
    }
    .padding()
    .background(CrateColors.void)
}

extension ProgramTrack {
    static let preview = ProgramTrack(
        id: "track-1",
        programId: "program-1",
        appleMusicUrl: nil,
        appleMusicTrackId: "1234567890",
        title: "Blue in Green",
        artistName: "Miles Davis",
        artworkUrl: nil,
        playTimingSeconds: 330,
        durationSeconds: 327,
        trackOrder: 1
    )
}
