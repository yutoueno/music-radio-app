import SwiftUI

// MARK: - CRATE Mini Player View

/// Floating mini player shown at the bottom of the screen during playback.
/// Displays progress, current program info, favorite toggle, and play/pause controls.
struct CrateMiniPlayerView: View {
    @EnvironmentObject var coordinator: DualPlaybackCoordinator
    @EnvironmentObject var programViewModel: ProgramViewModel

    let onTapExpand: () -> Void
    let onFavoriteTap: () -> Void

    @State private var isVisible = false

    // MARK: - Layout Constants

    private let thumbnailSize: CGFloat = 36
    private let thumbnailCornerRadius: CGFloat = 4
    private let progressBarHeight: CGFloat = 2

    var body: some View {
        VStack(spacing: 0) {
            // Top progress bar
            CrateProgressBar(progress: coordinator.progress)
                .frame(height: progressBarHeight)

            // Content row
            HStack(spacing: 10) {
                // Thumbnail
                thumbnailView

                // Title + Creator
                infoSection

                Spacer(minLength: 4)

                // Heart button
                favoriteButton

                // Play/Pause button
                CratePlayButton(
                    isPlaying: coordinator.playbackState == .playing,
                    isLoading: coordinator.playbackState == .loading,
                    size: .small
                ) {
                    coordinator.togglePlayPause()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(
            VStack(spacing: 0) {
                Rectangle()
                    .fill(CrateColors.border)
                    .frame(height: 1)
                CrateColors.surface
            }
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTapExpand()
        }
        .offset(y: isVisible ? 0 : 80)
        .animation(.easeOut(duration: 0.3), value: isVisible)
        .onAppear {
            isVisible = true
        }
    }

    // MARK: - Subviews

    private var thumbnailView: some View {
        Group {
            if let program = programViewModel.currentProgram {
                AsyncImage(url: URL(string: program.thumbnailUrl ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        thumbnailPlaceholder
                    case .empty:
                        thumbnailPlaceholder
                    @unknown default:
                        thumbnailPlaceholder
                    }
                }
                .frame(width: thumbnailSize, height: thumbnailSize)
                .clipShape(RoundedRectangle(cornerRadius: thumbnailCornerRadius))
            } else {
                thumbnailPlaceholder
                    .frame(width: thumbnailSize, height: thumbnailSize)
            }
        }
    }

    private var thumbnailPlaceholder: some View {
        RoundedRectangle(cornerRadius: thumbnailCornerRadius)
            .fill(CrateColors.elevated)
            .frame(width: thumbnailSize, height: thumbnailSize)
            .overlay {
                Image(systemName: "radio")
                    .font(.system(size: 12))
                    .foregroundColor(CrateColors.textTertiary)
            }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(programViewModel.currentProgram?.title ?? "Not Playing")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(CrateColors.textPrimary)
                .lineLimit(1)

            if let track = coordinator.trackForCurrentTime() {
                HStack(spacing: 3) {
                    Image(systemName: "music.note")
                        .font(.system(size: 9))
                    Text(track.trackName)
                        .font(.system(size: 11))
                }
                .foregroundColor(CrateColors.textSecondary)
                .lineLimit(1)
            } else {
                Text(programViewModel.currentProgram?.broadcaster?.nickname ?? "")
                    .font(.system(size: 11))
                    .foregroundColor(CrateColors.textSecondary)
                    .lineLimit(1)
            }
        }
    }

    private var favoriteButton: some View {
        Button {
            onFavoriteTap()
        } label: {
            Image(systemName: programViewModel.isFavorited ? "heart.fill" : "heart")
                .font(.system(size: 14))
                .foregroundColor(
                    programViewModel.isFavorited
                        ? CrateColors.accent
                        : CrateColors.textTertiary
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Container Modifier

/// View modifier to embed the CrateMiniPlayerView at the bottom of a screen.
struct CrateMiniPlayerModifier: ViewModifier {
    @EnvironmentObject var coordinator: DualPlaybackCoordinator
    @EnvironmentObject var programViewModel: ProgramViewModel

    let onExpand: () -> Void

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content

            if coordinator.playbackState != .idle {
                CrateMiniPlayerView(
                    onTapExpand: onExpand,
                    onFavoriteTap: {
                        Task {
                            await programViewModel.toggleFavorite()
                        }
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

extension View {
    /// Attaches a CRATE-styled mini player to the bottom of this view.
    func crateMiniPlayer(onExpand: @escaping () -> Void) -> some View {
        modifier(CrateMiniPlayerModifier(onExpand: onExpand))
    }
}

// MARK: - Preview

#Preview("Mini Player") {
    ZStack {
        CrateColors.void.ignoresSafeArea()

        VStack {
            Spacer()
            Text("Main Content")
                .foregroundColor(CrateColors.textPrimary)
            Spacer()
        }

        VStack {
            Spacer()
            // Static preview layout mimicking the mini player
            VStack(spacing: 0) {
                CrateProgressBar(progress: 0.4)
                    .frame(height: 2)

                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(CrateColors.elevated)
                        .frame(width: 36, height: 36)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Evening Jazz Mix")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(CrateColors.textPrimary)
                        Text("DJ Smooth")
                            .font(.system(size: 11))
                            .foregroundColor(CrateColors.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "heart")
                        .font(.system(size: 14))
                        .foregroundColor(CrateColors.textTertiary)

                    CratePlayButton(state: .playing, size: .small) {}
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .background(
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(CrateColors.border)
                        .frame(height: 1)
                    CrateColors.surface
                }
            )
        }
    }
}
