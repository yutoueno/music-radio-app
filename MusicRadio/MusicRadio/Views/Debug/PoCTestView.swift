import SwiftUI

struct DebugPoCTestView: View {
    @StateObject private var coordinator = DualPlaybackCoordinator()
    @State private var testAppleMusicTrackId: String = ""
    @State private var testAudioURL: String = ""
    @State private var logMessages: [String] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                statusSection
                inputSection
                controlsSection
                logSection
            }
            .padding()
        }
        .navigationTitle("PoC Test")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "waveform.circle")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            Text("Dual Playback PoC")
                .font(.title2)
                .fontWeight(.bold)
            Text("Test simultaneous AVAudioPlayer + MusicKit playback")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Status

    private var statusSection: some View {
        VStack(spacing: 12) {
            Text("Playback Status")
                .font(.headline)

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

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("State")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(playbackStateText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Radio Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(coordinator.currentRadioTime.formattedDuration)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .monospacedDigit()
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func statusIndicator(title: String, isActive: Bool, iconName: String) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isActive ? Color.green.opacity(0.2) : Color(.systemGray5))
                    .frame(width: 56, height: 56)
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(isActive ? .green : .secondary)
            }
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(isActive ? "Playing" : "Stopped")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(isActive ? .green : .secondary)
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
        VStack(alignment: .leading, spacing: 12) {
            Text("Test Configuration")
                .font(.headline)

            VStack(alignment: .leading, spacing: 4) {
                Text("Audio URL (radio stream)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("https://example.com/audio.mp3", text: $testAudioURL)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .font(.subheadline)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Apple Music Track ID")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("e.g. 1440818839", text: $testAppleMusicTrackId)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .font(.subheadline)
            }
        }
    }

    // MARK: - Controls

    private var controlsSection: some View {
        VStack(spacing: 12) {
            Text("Controls")
                .font(.headline)

            // Start dual playback
            Button {
                Task { await startDualPlayback() }
            } label: {
                Label("Start Dual Playback", systemImage: "play.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }

            HStack(spacing: 12) {
                Button {
                    coordinator.togglePlayPause()
                    addLog("Toggle play/pause -> \(playbackStateText)")
                } label: {
                    Label("Toggle", systemImage: "playpause.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }

                Button {
                    coordinator.stopAll()
                    addLog("Stopped all playback")
                } label: {
                    Label("Stop All", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
            }
            .font(.subheadline)
            .buttonStyle(.plain)

            HStack(spacing: 12) {
                Button {
                    Task { await playAppleMusicOnly() }
                } label: {
                    Text("Music Only")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }

                Button {
                    Task { await playRadioOnly() }
                } label: {
                    Text("Radio Only")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
            }
            .font(.subheadline)
            .buttonStyle(.plain)
        }
    }

    // MARK: - Log

    private var logSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Log")
                    .font(.headline)
                Spacer()
                Button("Clear") {
                    logMessages.removeAll()
                }
                .font(.caption)
            }

            if logMessages.isEmpty {
                Text("No log entries yet")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(logMessages.indices, id: \.self) { index in
                        Text(logMessages[index])
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
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
