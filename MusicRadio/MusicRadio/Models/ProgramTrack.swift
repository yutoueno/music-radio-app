import Foundation

struct ProgramTrack: Codable, Identifiable, Equatable {
    let id: String
    let programId: String?
    let appleMusicUrl: String?
    let appleMusicTrackId: String
    let title: String
    let artistName: String
    let artworkUrl: String?
    let playTimingSeconds: Int
    let durationSeconds: Int?
    let trackOrder: Int?

    /// Alias for backward compatibility with views using `trackName`
    var trackName: String { title }
    /// Alias for backward compatibility with views using `sortOrder`
    var sortOrder: Int { trackOrder ?? 0 }

    var playTimingFormatted: String {
        TimeInterval(playTimingSeconds).formattedTimingHHMMSS
    }

    var playTimingInterval: TimeInterval {
        TimeInterval(playTimingSeconds)
    }

    static func == (lhs: ProgramTrack, rhs: ProgramTrack) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Editable Track (for program editing)

struct EditableTrack: Identifiable, Equatable {
    let id: String
    var appleMusicTrackId: String
    var trackName: String
    var artistName: String
    var artworkUrl: String?
    var playTimingSeconds: Int
    var sortOrder: Int

    init(from track: ProgramTrack) {
        self.id = track.id
        self.appleMusicTrackId = track.appleMusicTrackId
        self.trackName = track.title
        self.artistName = track.artistName
        self.artworkUrl = track.artworkUrl
        self.playTimingSeconds = track.playTimingSeconds
        self.sortOrder = track.trackOrder ?? 0
    }

    init(
        appleMusicTrackId: String,
        trackName: String,
        artistName: String,
        artworkUrl: String?,
        playTimingSeconds: Int = 0,
        sortOrder: Int = 0
    ) {
        self.id = UUID().uuidString
        self.appleMusicTrackId = appleMusicTrackId
        self.trackName = trackName
        self.artistName = artistName
        self.artworkUrl = artworkUrl
        self.playTimingSeconds = playTimingSeconds
        self.sortOrder = sortOrder
    }

    func toTrackInput() -> TrackInput {
        TrackInput(
            appleMusicTrackId: appleMusicTrackId,
            title: trackName,
            artistName: artistName,
            artworkUrl: artworkUrl,
            playTimingSeconds: playTimingSeconds,
            trackOrder: sortOrder
        )
    }
}
