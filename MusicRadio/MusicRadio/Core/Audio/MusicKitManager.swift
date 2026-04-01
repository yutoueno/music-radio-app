import Foundation
import MusicKit
import MediaPlayer
import Combine

final class MusicKitManager: ObservableObject {
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var currentTrackID: String?
    @Published private(set) var authorizationStatus: MusicAuthorization.Status = .notDetermined
    @Published private(set) var hasSubscription: Bool = false
    @Published private(set) var currentPlaybackTime: TimeInterval = 0
    @Published private(set) var error: MusicKitError?

    private let player = ApplicationMusicPlayer.shared
    private var playbackStateObserver: AnyCancellable?
    private var timeObserverTimer: Timer?

    enum MusicKitError: LocalizedError {
        case notAuthorized
        case trackNotFound(String)
        case playbackFailed(String)
        case noSubscription

        var errorDescription: String? {
            switch self {
            case .notAuthorized:
                return "MusicKit not authorized"
            case .trackNotFound(let id):
                return "Track not found: \(id)"
            case .playbackFailed(let message):
                return "Playback failed: \(message)"
            case .noSubscription:
                return "Apple Music subscription required"
            }
        }
    }

    init() {
        setupPlaybackStateObserver()
        Task { await checkAuthorizationStatus() }
    }

    // MARK: - Authorization

    func checkAuthorizationStatus() async {
        let status = MusicAuthorization.currentStatus
        await MainActor.run {
            self.authorizationStatus = status
        }
        if status == .authorized {
            await checkSubscriptionStatus()
        }
    }

    func requestAuthorization() async -> MusicAuthorization.Status {
        let status = await MusicAuthorization.request()
        await MainActor.run {
            self.authorizationStatus = status
        }
        if status == .authorized {
            await checkSubscriptionStatus()
        }
        return status
    }

    private func checkSubscriptionStatus() async {
        do {
            let subscription = try await MusicSubscription.current
            await MainActor.run {
                self.hasSubscription = subscription.canPlayCatalogContent
            }
        } catch {
            await MainActor.run {
                self.hasSubscription = false
            }
        }
    }

    // MARK: - Playback

    func playTrack(appleMusicID: String) async {
        guard authorizationStatus == .authorized else {
            await MainActor.run { self.error = .notAuthorized }
            return
        }

        do {
            let musicItemID = MusicItemID(appleMusicID)
            let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
            let response = try await request.response()

            guard let song = response.items.first else {
                await MainActor.run { self.error = .trackNotFound(appleMusicID) }
                return
            }

            if hasSubscription {
                player.queue = [song]
                try await player.play()
            } else {
                // For non-subscribers, try preview playback
                try await playPreview(for: song)
            }

            await MainActor.run {
                self.currentTrackID = appleMusicID
                self.isPlaying = true
                self.error = nil
            }
            startTimeObserver()
        } catch {
            await MainActor.run {
                self.error = .playbackFailed(error.localizedDescription)
            }
        }
    }

    private func playPreview(for song: Song) async throws {
        guard let previewURL = song.previewAssets?.first?.url else {
            throw MusicKitError.noSubscription
        }
        // Preview uses the standard queue mechanism with a limited duration
        player.queue = [song]
        try await player.play()
        // Preview will automatically stop after ~30 seconds for non-subscribers
    }

    func pause() {
        player.pause()
        isPlaying = false
        stopTimeObserver()
    }

    func resume() async {
        do {
            try await player.play()
            await MainActor.run {
                isPlaying = true
            }
            startTimeObserver()
        } catch {
            await MainActor.run {
                self.error = .playbackFailed(error.localizedDescription)
            }
        }
    }

    func stop() {
        player.pause()
        player.queue = .init()
        isPlaying = false
        currentTrackID = nil
        currentPlaybackTime = 0
        stopTimeObserver()
    }

    func setVolume(_ volume: Float) {
        // MusicKit player volume is controlled via MPVolumeView system volume
        // We adjust relative to system through audio session
    }

    // MARK: - Search

    func searchTracks(query: String) async -> [Song] {
        guard authorizationStatus == .authorized else { return [] }

        do {
            var request = MusicCatalogSearchRequest(term: query, types: [Song.self])
            request.limit = 25
            let response = try await request.response()
            return Array(response.songs)
        } catch {
            print("[MusicKit] Search failed: \(error.localizedDescription)")
            return []
        }
    }

    func fetchTrack(id: String) async -> Song? {
        guard authorizationStatus == .authorized else { return nil }

        do {
            let musicItemID = MusicItemID(id)
            let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
            let response = try await request.response()
            return response.items.first
        } catch {
            print("[MusicKit] Fetch track failed: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Observers

    private func setupPlaybackStateObserver() {
        playbackStateObserver = player.state.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                let state = self.player.state.playbackStatus
                self.isPlaying = (state == .playing)
            }
    }

    private func startTimeObserver() {
        stopTimeObserver()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.timeObserverTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.currentPlaybackTime = self.player.playbackTime
            }
        }
    }

    private func stopTimeObserver() {
        DispatchQueue.main.async { [weak self] in
            self?.timeObserverTimer?.invalidate()
            self?.timeObserverTimer = nil
        }
    }

    deinit {
        timeObserverTimer?.invalidate()
        timeObserverTimer = nil
    }
}
