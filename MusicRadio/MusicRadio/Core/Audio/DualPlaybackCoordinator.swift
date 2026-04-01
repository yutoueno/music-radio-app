import Foundation
import Combine
import SwiftUI

final class DualPlaybackCoordinator: ObservableObject {
    @Published private(set) var isRadioPlaying: Bool = false
    @Published private(set) var isMusicPlaying: Bool = false
    @Published private(set) var activeTrackIndex: Int?
    @Published private(set) var currentRadioTime: TimeInterval = 0
    @Published private(set) var radioDuration: TimeInterval = 0
    @Published private(set) var playbackState: PlaybackState = .idle

    let radioPlayer = AudioPlayerManager()
    let musicKitManager = MusicKitManager()

    private var cancellables = Set<AnyCancellable>()
    private var tracks: [ProgramTrack] = []
    private var trackTimingMonitorTimer: Timer?
    private var lastTriggeredTrackIndex: Int?

    enum PlaybackState: Equatable {
        case idle
        case loading
        case playing
        case paused
        case error(String)

        static func == (lhs: PlaybackState, rhs: PlaybackState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading), (.playing, .playing), (.paused, .paused):
                return true
            case (.error(let a), .error(let b)):
                return a == b
            default:
                return false
            }
        }
    }

    init() {
        setupBindings()
        setupInterruptionHandling()
    }

    // MARK: - Setup

    private func setupBindings() {
        radioPlayer.$isPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] playing in
                self?.isRadioPlaying = playing
                if playing {
                    self?.playbackState = .playing
                } else if self?.playbackState == .playing {
                    self?.playbackState = .paused
                }
            }
            .store(in: &cancellables)

        radioPlayer.$currentTime
            .receive(on: DispatchQueue.main)
            .sink { [weak self] time in
                self?.currentRadioTime = time
            }
            .store(in: &cancellables)

        radioPlayer.$duration
            .receive(on: DispatchQueue.main)
            .sink { [weak self] duration in
                self?.radioDuration = duration
            }
            .store(in: &cancellables)

        musicKitManager.$isPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] playing in
                self?.isMusicPlaying = playing
            }
            .store(in: &cancellables)
    }

    private func setupInterruptionHandling() {
        AudioSessionManager.shared.onInterruptionBegan = { [weak self] in
            self?.pauseAll()
        }
        AudioSessionManager.shared.onInterruptionEnded = { [weak self] shouldResume in
            if shouldResume {
                self?.resumeAll()
            }
        }
    }

    // MARK: - Program Loading

    func loadProgram(audioURL: URL, tracks: [ProgramTrack]) async {
        await MainActor.run {
            self.playbackState = .loading
            self.tracks = tracks.sorted { $0.playTimingSeconds < $1.playTimingSeconds }
            self.activeTrackIndex = nil
            self.lastTriggeredTrackIndex = nil
        }
        await radioPlayer.loadAudio(from: audioURL)
        await MainActor.run {
            self.playbackState = .paused
        }
    }

    // MARK: - Playback Control

    func playAll() {
        AudioSessionManager.shared.configureAudioSession()
        radioPlayer.play()
        startTrackTimingMonitor()
        playbackState = .playing
    }

    func pauseAll() {
        radioPlayer.pause()
        musicKitManager.pause()
        stopTrackTimingMonitor()
        playbackState = .paused
    }

    func resumeAll() {
        radioPlayer.play()
        startTrackTimingMonitor()
        // Resume Apple Music only if a track was actively playing
        if isMusicPlaying || activeTrackIndex != nil {
            Task { await musicKitManager.resume() }
        }
        playbackState = .playing
    }

    func stopAll() {
        radioPlayer.stop()
        musicKitManager.stop()
        stopTrackTimingMonitor()
        activeTrackIndex = nil
        lastTriggeredTrackIndex = nil
        playbackState = .idle
    }

    func togglePlayPause() {
        switch playbackState {
        case .playing:
            pauseAll()
        case .paused:
            resumeAll()
        case .idle:
            playAll()
        default:
            break
        }
    }

    func seekRadio(to time: TimeInterval) {
        radioPlayer.seek(to: time)
        // Reset track triggering state for re-evaluation
        lastTriggeredTrackIndex = nil
        evaluateTrackTiming(at: time)
    }

    func seekRadioToPercentage(_ percentage: Double) {
        radioPlayer.seekToPercentage(percentage)
        lastTriggeredTrackIndex = nil
        evaluateTrackTiming(at: radioDuration * percentage)
    }

    // MARK: - Manual Track Playback

    func playTrackManually(at index: Int) async {
        guard index >= 0, index < tracks.count else { return }
        let track = tracks[index]

        await MainActor.run {
            self.activeTrackIndex = index
        }

        // Enable ducking while Apple Music plays over radio
        AudioSessionManager.shared.enableDucking(true)
        await musicKitManager.playTrack(appleMusicID: track.appleMusicTrackId)
    }

    func stopCurrentTrack() {
        musicKitManager.stop()
        AudioSessionManager.shared.enableDucking(false)
        activeTrackIndex = nil
    }

    // MARK: - Track Timing Monitor

    private func startTrackTimingMonitor() {
        stopTrackTimingMonitor()
        trackTimingMonitorTimer = Timer.scheduledTimer(
            withTimeInterval: 0.5,
            repeats: true
        ) { [weak self] _ in
            guard let self = self else { return }
            self.evaluateTrackTiming(at: self.currentRadioTime)
        }
    }

    private func stopTrackTimingMonitor() {
        trackTimingMonitorTimer?.invalidate()
        trackTimingMonitorTimer = nil
    }

    private func evaluateTrackTiming(at currentTime: TimeInterval) {
        guard !tracks.isEmpty else { return }

        // Find which track should be active at the current time
        var matchedIndex: Int?
        for (index, track) in tracks.enumerated() {
            let trackStart = TimeInterval(track.playTimingSeconds)
            // Consider a track "active" within a 1-second window
            if abs(currentTime - trackStart) < 1.0 {
                matchedIndex = index
                break
            }
        }

        // Determine which track region we're in (for highlighting)
        var currentRegionIndex: Int?
        for (index, track) in tracks.enumerated().reversed() {
            if currentTime >= TimeInterval(track.playTimingSeconds) {
                currentRegionIndex = index
                break
            }
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Update active track highlight
            if currentRegionIndex != self.activeTrackIndex {
                self.activeTrackIndex = currentRegionIndex
            }

            // Auto-trigger track playback at timing point
            if let matchedIndex = matchedIndex,
               matchedIndex != self.lastTriggeredTrackIndex {
                self.lastTriggeredTrackIndex = matchedIndex
                Task {
                    await self.triggerTrackPlayback(at: matchedIndex)
                }
            }
        }
    }

    private func triggerTrackPlayback(at index: Int) async {
        guard index >= 0, index < tracks.count else { return }
        let track = tracks[index]

        AudioSessionManager.shared.enableDucking(true)
        await musicKitManager.playTrack(appleMusicID: track.appleMusicTrackId)
    }

    // MARK: - Track Info

    func trackForCurrentTime() -> ProgramTrack? {
        guard let index = activeTrackIndex, index < tracks.count else { return nil }
        return tracks[index]
    }

    func allTracks() -> [ProgramTrack] {
        return tracks
    }

    var progress: Double {
        guard radioDuration > 0 else { return 0 }
        return currentRadioTime / radioDuration
    }

    deinit {
        stopTrackTimingMonitor()
    }
}
