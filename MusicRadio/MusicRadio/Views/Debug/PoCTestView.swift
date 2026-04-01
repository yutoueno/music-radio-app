import SwiftUI

struct DebugPoCTestView: View {
    @StateObject private var coordinator = DualPlaybackCoordinator()
    @State private var testAppleMusicTrackId: String = ""
    @State private var testAudioURL: String = ""
    @State private var logMessages: [String] = []

    var body: some View {
        ScrollView {
            VStack(spacing: CrateTheme.Spacing.sectionGap) {
                headerSection
                statusSection
                inputSection
                controlsSection
                logSection
            }
            .padding(CrateTheme.Spacing.screenMargin)
            .padding(.bottom, 40)
        }
        .background(CrateColors.void)
        .navigationTitle("PoC Test")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: CrateTheme.Spacing.textGapMedium) {
            Image(systemName: "waveform.circle")
                .font(.system(size: 48, weight: .thin))
                .foregroundColor(CrateColors.accent)

            Text("Dual Playback PoC")
                .crateText(.h1)

            Text("Test simultaneous AVAudioPlayer + MusicKit playback")
                .crateText(.caption, color: CrateColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    // MARK: - Status

    private var statusSection: some View {
        VStack(spacing: 14) {
            Text("PLAYBACK STATUS")
                .crateText(.sectionLabel, color: CrateColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 20) {
                statusIndicator(
                    title: "Radio",
                    isActive: coordinator.isRadioPlaying,
                    iconName: "radio"
                )
                statusIndicator(
                    title: "Apple Music",
                    isActive: coordinator.isMusicPlaying,
                    iconName: "music.note"
                )
            }

            HStack(spacing: CrateTheme.Spacing.screenMargin) {
                VStack(alignment: .leading, spacing: CrateTheme.Spacing.textGapSmall) {
                    Text("STATE")
                        .crateText(.meta, color: CrateColors.textTertiary)
                    Text(playbackStateText)
                        .crateText(.body)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: CrateTheme.Spacing.textGapSmall) {
                    Text("RADIO TIME")
                        .crateText(.meta, color: CrateColors.textTertiary)
                    Text(coordinator.currentRadioTime.formattedDuration)
                        .font(CrateTypography.timestamp)
                        .foregroundColor(CrateColors.accent)
                }
            }
        }
        .padding(CrateTheme.Spacing.cardPadding)
        .background(CrateColors.surface)
        .cornerRadius(CrateTheme.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.medium)
                .stroke(CrateColors.border, lineWidth: 0.5)
        )
    }

    private func statusIndicator(title: String, isActive: Bool, iconName: String) -> some View {
        VStack(spacing: CrateTheme.Spacing.textGapMedium) {
            ZStack {
                Circle()
                    .fill(isActive ? CrateColors.success.opacity(0.15) : CrateColors.elevated)
                    .frame(width: 56, height: 56)
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(isActive ? CrateColors.success : CrateColors.textTertiary)
            }

            Text(title)
                .crateText(.caption, color: CrateColors.textSecondary)

            Text(isActive ? "Playing" : "Stopped")
                .crateText(.meta, color: isActive ? CrateColors.success : CrateColors.textTertiary)
        }
    }

    private var playbackStateText: String {
        switch coordinator.playbackState {
        case .idle: return "Idle"
        case .loading: return "Loading..."
        case .playing: return "Playing"
        case .paused: return "Paused"
        case .error(let message): return "Error: \(message)"
        }
    }

    // MARK: - Input

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("TEST CONFIGURATION")
                .crateText(.sectionLabel, color: CrateColors.textSecondary)

            VStack(alignment: .leading, spacing: CrateTheme.Spacing.textGapSmall) {
                Text("Audio URL (radio stream)")
                    .crateText(.meta, color: CrateColors.textTertiary)
                TextField("", text: $testAudioURL)
                    .font(CrateTypography.caption)
                    .foregroundColor(CrateColors.textPrimary)
                    .placeholder(when: testAudioURL.isEmpty) {
                        Text("https://example.com/audio.mp3")
                            .font(CrateTypography.caption)
                            .foregroundColor(CrateColors.textMuted)
                    }
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(CrateColors.elevated)
                    .cornerRadius(CrateTheme.CornerRadius.small)
                    .overlay(
                        RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.small)
                            .stroke(CrateColors.border, lineWidth: 0.5)
                    )
            }

            VStack(alignment: .leading, spacing: CrateTheme.Spacing.textGapSmall) {
                Text("Apple Music Track ID")
                    .crateText(.meta, color: CrateColors.textTertiary)
                TextField("", text: $testAppleMusicTrackId)
                    .font(CrateTypography.caption)
                    .foregroundColor(CrateColors.textPrimary)
                    .placeholder(when: testAppleMusicTrackId.isEmpty) {
                        Text("e.g. 1440818839")
                            .font(CrateTypography.caption)
                            .foregroundColor(CrateColors.textMuted)
                    }
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(CrateColors.elevated)
                    .cornerRadius(CrateTheme.CornerRadius.small)
                    .overlay(
                        RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.small)
                            .stroke(CrateColors.border, lineWidth: 0.5)
                    )
            }
        }
    }

    // MARK: - Controls

    private var controlsSection: some View {
        VStack(spacing: 12) {
            Text("CONTROLS")
                .crateText(.sectionLabel, color: CrateColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Start dual playback
            Button {
                Task { await startDualPlayback() }
            } label: {
                Label("Start Dual Playback", systemImage: "play.circle.fill")
                    .font(CrateTypography.h2)
                    .foregroundColor(CrateColors.void)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(CrateColors.accent)
                    .cornerRadius(CrateTheme.CornerRadius.medium)
            }
            .buttonStyle(.plain)

            HStack(spacing: CrateTheme.Spacing.cardGap) {
                Button {
                    coordinator.togglePlayPause()
                    addLog("Toggle play/pause -> \(playbackStateText)")
                } label: {
                    Label("Toggle", systemImage: "playpause.fill")
                        .font(CrateTypography.caption)
                        .foregroundColor(CrateColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(CrateColors.elevated)
                        .cornerRadius(CrateTheme.CornerRadius.small)
                        .overlay(
                            RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.small)
                                .stroke(CrateColors.border, lineWidth: 0.5)
                        )
                }

                Button {
                    coordinator.stopAll()
                    addLog("Stopped all playback")
                } label: {
                    Label("Stop All", systemImage: "stop.fill")
                        .font(CrateTypography.caption)
                        .foregroundColor(CrateColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(CrateColors.elevated)
                        .cornerRadius(CrateTheme.CornerRadius.small)
                        .overlay(
                            RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.small)
                                .stroke(CrateColors.border, lineWidth: 0.5)
                        )
                }
            }
            .buttonStyle(.plain)

            HStack(spacing: CrateTheme.Spacing.cardGap) {
                Button {
                    Task { await playAppleMusicOnly() }
                } label: {
                    Text("Music Only")
                        .font(CrateTypography.caption)
                        .foregroundColor(CrateColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(CrateColors.elevated)
                        .cornerRadius(CrateTheme.CornerRadius.small)
                        .overlay(
                            RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.small)
                                .stroke(CrateColors.border, lineWidth: 0.5)
                        )
                }

                Button {
                    Task { await playRadioOnly() }
                } label: {
                    Text("Radio Only")
                        .font(CrateTypography.caption)
                        .foregroundColor(CrateColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(CrateColors.elevated)
                        .cornerRadius(CrateTheme.CornerRadius.small)
                        .overlay(
                            RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.small)
                                .stroke(CrateColors.border, lineWidth: 0.5)
                        )
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Log

    private var logSection: some View {
        VStack(alignment: .leading, spacing: CrateTheme.Spacing.inline) {
            HStack {
                Text("LOG")
                    .crateText(.sectionLabel, color: CrateColors.textSecondary)
                Spacer()
                Button("Clear") {
                    logMessages.removeAll()
                }
                .font(CrateTypography.meta)
                .foregroundColor(CrateColors.accent)
                .buttonStyle(.plain)
            }

            if logMessages.isEmpty {
                Text("No log entries yet")
                    .crateText(.caption, color: CrateColors.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                VStack(alignment: .leading, spacing: CrateTheme.Spacing.textGapSmall) {
                    ForEach(logMessages.indices, id: \.self) { index in
                        Text(logMessages[index])
                            .font(CrateTypography.timestamp)
                            .foregroundColor(CrateColors.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(CrateTheme.Spacing.cardPadding)
                .background(CrateColors.surface)
                .cornerRadius(CrateTheme.CornerRadius.small)
                .overlay(
                    RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.small)
                        .stroke(CrateColors.border, lineWidth: 0.5)
                )
            }
        }
    }

    // MARK: - Actions

    private func startDualPlayback() async {
        guard let audioURL = URL(string: testAudioURL), !testAudioURL.isEmpty else {
            addLog("Error: Invalid audio URL")
            return
        }
        guard !testAppleMusicTrackId.isEmpty else {
            addLog("Error: Apple Music Track ID is empty")
            return
        }

        addLog("Loading radio audio...")
        let dummyTrack = ProgramTrack(
            id: "test-track",
            programId: "test-program",
            appleMusicUrl: nil,
            appleMusicTrackId: testAppleMusicTrackId,
            title: "Test Track",
            artistName: "Test Artist",
            artworkUrl: nil,
            playTimingSeconds: 0,
            durationSeconds: nil,
            trackOrder: 0
        )

        await coordinator.loadProgram(audioURL: audioURL, tracks: [dummyTrack])
        addLog("Radio audio loaded (duration: \(coordinator.radioDuration.formattedDuration))")

        coordinator.playAll()
        addLog("Radio playback started")

        addLog("Starting Apple Music track: \(testAppleMusicTrackId)")
        await coordinator.playTrackManually(at: 0)
        addLog("Apple Music playback started: radio=\(coordinator.isRadioPlaying), music=\(coordinator.isMusicPlaying)")
    }

    private func playAppleMusicOnly() async {
        guard !testAppleMusicTrackId.isEmpty else {
            addLog("Error: Apple Music Track ID is empty")
            return
        }
        addLog("Playing Apple Music track only: \(testAppleMusicTrackId)")
        await coordinator.musicKitManager.playTrack(appleMusicID: testAppleMusicTrackId)
        addLog("Apple Music result: isPlaying=\(coordinator.isMusicPlaying)")
    }

    private func playRadioOnly() async {
        guard let audioURL = URL(string: testAudioURL), !testAudioURL.isEmpty else {
            addLog("Error: Invalid audio URL")
            return
        }
        addLog("Loading radio audio...")
        await coordinator.loadProgram(audioURL: audioURL, tracks: [])
        coordinator.playAll()
        addLog("Radio playback started: isPlaying=\(coordinator.isRadioPlaying)")
    }

    private func addLog(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        logMessages.insert("[\(timestamp)] \(message)", at: 0)
    }
}
