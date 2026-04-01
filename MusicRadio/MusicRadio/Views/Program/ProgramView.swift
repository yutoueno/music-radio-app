import SwiftUI

struct ProgramView: View {
    let programId: String

    @EnvironmentObject var programViewModel: ProgramViewModel
    @EnvironmentObject var coordinator: DualPlaybackCoordinator
    var body: some View {
        ScrollView {
            if programViewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 300)
            } else if let program = programViewModel.currentProgram {
                VStack(spacing: 0) {
                    programHeader(program)
                    waveformSection
                    controlsBar(program)
                    trackListSection
                }
                .padding(.bottom, 100)
            } else if let error = programViewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text(error)
                        .foregroundColor(.secondary)
                    Button("Retry") {
                        Task { await programViewModel.loadProgram(id: programId) }
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 300)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    FavoriteButton(isFavorited: programViewModel.isFavorited) {
                        Task { await programViewModel.toggleFavorite() }
                    }
                    if let program = programViewModel.currentProgram {
                        ShareButton(program: program)
                    }
                }
            }
        }
        .onFirstAppear {
            await programViewModel.loadProgram(id: programId)
        }
    }

    // MARK: - Program Header

    @ViewBuilder
    private func programHeader(_ program: Program) -> some View {
        VStack(spacing: 16) {
            // Thumbnail
            AsyncImage(url: URL(string: program.thumbnailUrl ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray5))
                    .overlay {
                        Image(systemName: "radio")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                    }
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)

            // Program Info
            VStack(alignment: .leading, spacing: 8) {
                Text(program.title)
                    .font(.title2)
                    .fontWeight(.bold)

                if let broadcaster = program.broadcaster {
                    NavigationLink(destination: BroadcasterView(broadcasterId: broadcaster.id)) {
                        HStack(spacing: 8) {
                            AsyncImage(url: URL(string: broadcaster.avatarUrl ?? "")) { image in
                                image.avatarStyle(size: 32)
                            } placeholder: {
                                Circle()
                                    .fill(Color(.systemGray4))
                                    .frame(width: 32, height: 32)
                            }

                            Text(broadcaster.nickname)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: 16) {
                    Label("\(program.playCount ?? 0)", systemImage: "play.fill")
                    Label("\(program.favoriteCount ?? 0)", systemImage: "heart.fill")
                    if let programType = program.programType {
                        Label(programType.displayName, systemImage: programType.iconName)
                    }
                    if let duration = program.durationSeconds {
                        Label(TimeInterval(duration).formattedDuration, systemImage: "clock")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)

                if let description = program.description, !description.isEmpty {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(4)
                        .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
        .padding(.top, 8)
    }

    // MARK: - Waveform

    @ViewBuilder
    private var waveformSection: some View {
        VStack(spacing: 8) {
            WaveformView(
                samples: coordinator.radioPlayer.waveformSamples,
                progress: coordinator.progress,
                onSeek: { percentage in
                    coordinator.seekRadioToPercentage(percentage)
                }
            )
            .frame(height: 60)
            .padding(.horizontal)

            HStack {
                Text(coordinator.currentRadioTime.formattedDuration)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
                Spacer()
                Text(coordinator.radioDuration.formattedDuration)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
            .padding(.horizontal)
        }
        .padding(.top, 16)
    }

    // MARK: - Controls

    @ViewBuilder
    private func controlsBar(_ program: Program) -> some View {
        HStack(spacing: 32) {
            Button {
                coordinator.seekRadio(to: max(0, coordinator.currentRadioTime - 15))
            } label: {
                Image(systemName: "gobackward.15")
                    .font(.title2)
            }

            PlayButton(
                isPlaying: coordinator.playbackState == .playing,
                size: 56
            ) {
                if coordinator.playbackState == .idle {
                    Task { await programViewModel.startPlayback(coordinator: coordinator) }
                } else {
                    coordinator.togglePlayPause()
                }
            }

            Button {
                coordinator.seekRadio(to: min(coordinator.radioDuration, coordinator.currentRadioTime + 30))
            } label: {
                Image(systemName: "goforward.30")
                    .font(.title2)
            }
        }
        .padding(.vertical, 16)
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
}

// MARK: - Share Sheet

struct ShareSheetView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
