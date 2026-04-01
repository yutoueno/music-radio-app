import SwiftUI

struct ProgramView: View {
    let programId: String

    @EnvironmentObject var programViewModel: ProgramViewModel
    @EnvironmentObject var coordinator: DualPlaybackCoordinator
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            CrateColors.void.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                if programViewModel.isLoading {
                    loadingState
                } else if let program = programViewModel.currentProgram {
                    VStack(spacing: 0) {
                        // Custom navigation bar
                        customNavBar(program)

                        // Artwork
                        artworkSection(program)

                        // Title + Broadcaster
                        programInfoSection(program)

                        // Waveform + timestamps
                        waveformSection
                            .padding(.top, 24)

                        // Playback controls
                        playbackControls
                            .padding(.top, 20)

                        // Track list
                        trackListSection
                            .padding(.top, CrateTheme.Spacing.sectionGap)

                        // Action buttons
                        actionButtons(program)
                            .padding(.top, CrateTheme.Spacing.sectionGap)
                    }
                    .padding(.bottom, 120)
                } else if let error = programViewModel.errorMessage {
                    errorState(error)
                }
            }
        }
        .navigationBarHidden(true)
        .onFirstAppear {
            await programViewModel.loadProgram(id: programId)
        }
    }

    // MARK: - Custom Navigation Bar

    @ViewBuilder
    private func customNavBar(_ program: Program) -> some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(CrateColors.textPrimary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("NOW PLAYING")
                .crateText(.sectionLabel, color: CrateColors.textTertiary)

            Spacer()

            Menu {
                if let shareUrl = program.shareUrl {
                    Button {
                        presentShareSheet(url: shareUrl, text: program.title)
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
                Button {
                    // Report action placeholder
                } label: {
                    Label("Report", systemImage: "exclamationmark.triangle")
                }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(CrateColors.textPrimary)
                    .frame(width: 44, height: 44)
            }
        }
        .crateScreenPadding()
        .padding(.top, 4)
    }

    // MARK: - Artwork

    @ViewBuilder
    private func artworkSection(_ program: Program) -> some View {
        ProgramThumbnail(
            url: program.thumbnailUrl,
            size: 200,
            cornerRadius: CrateTheme.CornerRadius.large
        )
        .padding(.top, 24)
    }

    // MARK: - Program Info

    @ViewBuilder
    private func programInfoSection(_ program: Program) -> some View {
        VStack(spacing: CrateTheme.Spacing.textGapMedium) {
            Text(program.title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(CrateColors.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            if let broadcaster = program.broadcaster {
                NavigationLink(destination: BroadcasterView(broadcasterId: broadcaster.id)) {
                    HStack(spacing: 4) {
                        Text(broadcaster.nickname)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(CrateColors.textTertiary)

                        if let episode = episodeLabel(program) {
                            Text("\u{00B7}")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(CrateColors.textTertiary)

                            Text(episode)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(CrateColors.textTertiary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 16)
        .crateScreenPadding()
    }

    // MARK: - Waveform

    @ViewBuilder
    private var waveformSection: some View {
        VStack(spacing: 8) {
            CrateWaveformView(
                samples: coordinator.radioPlayer.waveformSamples,
                progress: coordinator.progress,
                onSeek: { percentage in
                    coordinator.seekRadioToPercentage(percentage)
                }
            )
            .frame(height: 40)
            .crateScreenPadding()

            // SF Mono timestamps
            HStack {
                Text(coordinator.currentRadioTime.formattedDuration)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .tracking(CrateTypography.monoTracking)
                    .foregroundColor(CrateColors.textTertiary)

                Spacer()

                Text(coordinator.radioDuration.formattedDuration)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .tracking(CrateTypography.monoTracking)
                    .foregroundColor(CrateColors.textTertiary)
            }
            .crateScreenPadding()
        }
    }

    // MARK: - Playback Controls

    @ViewBuilder
    private var playbackControls: some View {
        HStack(spacing: 40) {
            // Previous / Rewind
            Button {
                coordinator.seekRadio(to: max(0, coordinator.currentRadioTime - 15))
            } label: {
                Image(systemName: "backward.end.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(CrateColors.textSecondary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)

            // Play / Pause (medium CratePlayButton)
            CratePlayButton(
                isPlaying: coordinator.playbackState == .playing,
                isLoading: coordinator.playbackState == .loading,
                size: .medium
            ) {
                if coordinator.playbackState == .idle {
                    Task { await programViewModel.startPlayback(coordinator: coordinator) }
                } else {
                    coordinator.togglePlayPause()
                }
            }

            // Next / Forward
            Button {
                coordinator.seekRadio(to: min(coordinator.radioDuration, coordinator.currentRadioTime + 30))
            } label: {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(CrateColors.textSecondary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Track List

    @ViewBuilder
    private var trackListSection: some View {
        if !programViewModel.tracks.isEmpty {
            TrackListView(
                tracks: programViewModel.tracks,
                activeTrackIndex: coordinator.activeTrackIndex,
                currentRadioTime: coordinator.currentRadioTime,
                onPlayTrack: { index in
                    Task { await coordinator.playTrackManually(at: index) }
                }
            )
        }
    }

    // MARK: - Action Buttons

    @ViewBuilder
    private func actionButtons(_ program: Program) -> some View {
        HStack(spacing: 24) {
            // Favorite
            FavoriteButtonAction(
                isFavorited: programViewModel.isFavorited,
                size: 22
            ) {
                Task { await programViewModel.toggleFavorite() }
            }

            // Follow
            if let broadcaster = program.broadcaster {
                FollowButton(
                    isFollowing: false,
                    onToggle: { _ in
                        // Follow toggle handled via ViewModel
                    }
                )
            }

            // Share
            ShareButton(
                url: program.shareUrl,
                text: program.title,
                size: 18
            )

            Spacer()
        }
        .crateScreenPadding()
    }

    // MARK: - Loading State

    private var loadingState: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 120)

            SkeletonView(cornerRadius: CrateTheme.CornerRadius.large)
                .frame(width: 200, height: 200)

            SkeletonView(cornerRadius: 4)
                .frame(width: 180, height: 16)

            SkeletonView(cornerRadius: 4)
                .frame(width: 120, height: 12)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Error State

    @ViewBuilder
    private func errorState(_ error: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 120)

            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36))
                .foregroundColor(CrateColors.textMuted)

            Text(error)
                .crateText(.caption, color: CrateColors.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                Task { await programViewModel.loadProgram(id: programId) }
            } label: {
                Text("Retry")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(CrateColors.void)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(CrateColors.accent)
                    .cornerRadius(CrateTheme.CornerRadius.pill)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .crateScreenPadding()
    }

    // MARK: - Helpers

    private func episodeLabel(_ program: Program) -> String? {
        if let genre = program.genre, !genre.isEmpty {
            return genre
        }
        if let type = program.programType {
            return type.displayName
        }
        return nil
    }

    private func presentShareSheet(url: String, text: String) {
        var items: [Any] = [text]
        if let shareURL = URL(string: url) {
            items.append(shareURL)
        }
        guard !items.isEmpty else { return }

        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController
        else { return }

        var presenter = rootVC
        while let presented = presenter.presentedViewController {
            presenter = presented
        }

        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = presenter.view
            popover.sourceRect = CGRect(
                x: presenter.view.bounds.midX,
                y: presenter.view.bounds.midY,
                width: 0, height: 0
            )
            popover.permittedArrowDirections = []
        }

        presenter.present(activityVC, animated: true)
    }
}
