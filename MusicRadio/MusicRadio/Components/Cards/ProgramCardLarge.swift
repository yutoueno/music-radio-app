import SwiftUI

struct ProgramCardLarge: View {
    let program: Program
    var onTap: (() -> Void)? = nil
    var onPlay: (() -> Void)? = nil
    var isPlaying: Bool = false

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Artwork
                ZStack(alignment: .bottomTrailing) {
                    ProgramThumbnail(
                        url: program.thumbnailUrl,
                        size: .infinity,
                        cornerRadius: 0
                    )
                    .frame(height: 160)
                    .frame(maxWidth: .infinity)
                    .clipped()

                    // Play button overlay
                    if let onPlay {
                        PlayButton(isPlaying: isPlaying, size: 40) {
                            onPlay()
                        }
                        .padding(12)
                    }
                }

                // Info
                VStack(alignment: .leading, spacing: 6) {
                    // Program type badge
                    if let type = program.programType {
                        HStack(spacing: 4) {
                            Image(systemName: type.iconName)
                                .font(.system(size: 9))
                            Text(type.displayName.uppercased())
                                .font(.system(size: 9, weight: .semibold))
                                .tracking(1.2)
                        }
                        .foregroundColor(CrateColors.accent)
                    }

                    Text(program.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(CrateColors.textPrimary)
                        .lineLimit(2)

                    HStack(spacing: 6) {
                        if let broadcaster = program.broadcaster {
                            AvatarView(
                                url: broadcaster.avatarUrl,
                                name: broadcaster.nickname,
                                size: .small
                            )
                            Text(broadcaster.nickname)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(CrateColors.textSecondary)
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 10))
                            Text(program.durationFormatted)
                                .font(.system(size: 11, weight: .regular, design: .monospaced))
                        }
                        .foregroundColor(CrateColors.textTertiary)
                    }

                    // Stats row
                    HStack(spacing: 12) {
                        if let playCount = program.playCount, playCount > 0 {
                            Label(formatCount(playCount), systemImage: "play.fill")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(CrateColors.textTertiary)
                        }
                        if let favCount = program.favoriteCount, favCount > 0 {
                            Label(formatCount(favCount), systemImage: "heart.fill")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(CrateColors.textTertiary)
                        }
                    }
                }
                .padding(12)
            }
            .background(CrateColors.surface)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(CrateColors.border, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func formatCount(_ count: Int) -> String {
        if count >= 10000 {
            return String(format: "%.1fK", Double(count) / 1000)
        } else if count >= 1000 {
            return String(format: "%.1fK", Double(count) / 1000)
        }
        return "\(count)"
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ProgramCardLarge(
                program: .preview,
                onTap: {},
                onPlay: {},
                isPlaying: false
            )
            .frame(width: 260)

            ProgramCardLarge(
                program: .preview,
                onTap: {},
                onPlay: {},
                isPlaying: true
            )
            .frame(width: 260)
        }
        .padding()
    }
    .background(CrateColors.void)
}
