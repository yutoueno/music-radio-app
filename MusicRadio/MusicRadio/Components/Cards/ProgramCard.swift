import SwiftUI

struct ProgramCard: View {
    let program: Program
    var onTap: (() -> Void)? = nil
    var onPlay: (() -> Void)? = nil
    var isPlaying: Bool = false

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 12) {
                // Thumbnail
                ProgramThumbnail(
                    url: program.thumbnailUrl,
                    size: 52,
                    cornerRadius: 6
                )

                // Title + Meta
                VStack(alignment: .leading, spacing: 4) {
                    Text(program.title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(red: 232/255, green: 232/255, blue: 232/255))
                        .lineLimit(1)

                    Text(metaText)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(CrateColors.textTertiary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Play Button
                if let onPlay {
                    PlayButton(isPlaying: isPlaying, size: 32) {
                        onPlay()
                    }
                }
            }
            .padding(12)
            .background(CrateColors.surface)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }

    private var metaText: String {
        let creator = program.broadcaster?.nickname ?? "Unknown"
        let duration = program.durationFormatted
        return "\(creator) \u{00B7} \(duration)"
    }
}

// MARK: - Program Thumbnail (reusable)

struct ProgramThumbnail: View {
    let url: String?
    var size: CGFloat = 52
    var cornerRadius: CGFloat = 6

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
                        thumbnailPlaceholder
                    case .empty:
                        SkeletonView(cornerRadius: cornerRadius)
                    @unknown default:
                        thumbnailPlaceholder
                    }
                }
            } else {
                thumbnailPlaceholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var thumbnailPlaceholder: some View {
        ZStack {
            CrateColors.elevated
            Image(systemName: "radio")
                .font(.system(size: size * 0.3))
                .foregroundColor(CrateColors.textTertiary)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 8) {
        ProgramCard(
            program: .preview,
            onTap: {},
            onPlay: {},
            isPlaying: false
        )
        ProgramCard(
            program: .preview,
            onTap: {},
            onPlay: {},
            isPlaying: true
        )
    }
    .padding()
    .background(CrateColors.void)
}

// MARK: - Preview Helper

extension Program {
    static let preview = Program(
        id: "preview-1",
        userId: "user-1",
        title: "Late Night Jazz Session",
        description: "A curated selection of late night jazz tracks",
        thumbnailUrl: nil,
        audioUrl: nil,
        durationSeconds: 3600,
        programType: .music,
        genre: "Jazz",
        status: .published,
        scheduledAt: nil,
        playCount: 1200,
        favoriteCount: 45,
        isFavorited: false,
        broadcaster: ProgramBroadcaster(
            id: "broadcaster-1",
            nickname: "DJ Midnight",
            avatarUrl: nil
        ),
        tracks: [],
        createdAt: Date(),
        updatedAt: Date(),
        publishedAt: Date(),
        shareUrl: "https://example.com/program/preview-1"
    )
}
