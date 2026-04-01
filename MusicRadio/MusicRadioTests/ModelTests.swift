import XCTest
@testable import MusicRadio

final class ModelTests: XCTestCase {

    // MARK: - Helper

    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    // MARK: - Program Model Tests

    func testProgramDecodingWithAllFields() throws {
        let json = """
        {
            "id": "prog-1",
            "user_id": "user-1",
            "title": "Morning Jazz",
            "description": "A smooth jazz program",
            "thumbnail_url": "https://example.com/thumb.jpg",
            "audio_url": "https://example.com/audio.mp3",
            "duration_seconds": 3600,
            "program_type": "music",
            "genre": "Jazz",
            "status": "published",
            "scheduled_at": "2026-01-01T10:00:00Z",
            "play_count": 100,
            "favorite_count": 50,
            "is_favorited": true,
            "broadcaster": {
                "id": "bc-1",
                "nickname": "DJ Cool",
                "avatar_url": "https://example.com/avatar.jpg"
            },
            "tracks": [],
            "created_at": "2025-12-01T00:00:00Z",
            "updated_at": "2025-12-15T00:00:00Z",
            "published_at": "2025-12-15T12:00:00Z",
            "share_url": "https://example.com/share/prog-1"
        }
        """.data(using: .utf8)!

        let decoder = makeDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let program = try decoder.decode(Program.self, from: json)

        XCTAssertEqual(program.id, "prog-1")
        XCTAssertEqual(program.userId, "user-1")
        XCTAssertEqual(program.title, "Morning Jazz")
        XCTAssertEqual(program.description, "A smooth jazz program")
        XCTAssertEqual(program.thumbnailUrl, "https://example.com/thumb.jpg")
        XCTAssertEqual(program.audioUrl, "https://example.com/audio.mp3")
        XCTAssertEqual(program.durationSeconds, 3600)
        XCTAssertEqual(program.programType, .music)
        XCTAssertEqual(program.genre, "Jazz")
        XCTAssertEqual(program.status, .published)
        XCTAssertEqual(program.playCount, 100)
        XCTAssertEqual(program.favoriteCount, 50)
        XCTAssertEqual(program.isFavorited, true)
        XCTAssertNotNil(program.broadcaster)
        XCTAssertEqual(program.broadcaster?.nickname, "DJ Cool")
        XCTAssertNotNil(program.tracks)
        XCTAssertEqual(program.tracks?.count, 0)
        XCTAssertEqual(program.shareUrl, "https://example.com/share/prog-1")
    }

    func testProgramDecodingWithMinimalFields() throws {
        let json = """
        {
            "id": "prog-2",
            "title": "Minimal Program"
        }
        """.data(using: .utf8)!

        let program = try makeDecoder().decode(Program.self, from: json)

        XCTAssertEqual(program.id, "prog-2")
        XCTAssertEqual(program.title, "Minimal Program")
        XCTAssertNil(program.userId)
        XCTAssertNil(program.description)
        XCTAssertNil(program.thumbnailUrl)
        XCTAssertNil(program.audioUrl)
        XCTAssertNil(program.durationSeconds)
        XCTAssertNil(program.programType)
        XCTAssertNil(program.genre)
        XCTAssertNil(program.status)
        XCTAssertNil(program.scheduledAt)
        XCTAssertNil(program.playCount)
        XCTAssertNil(program.favoriteCount)
        XCTAssertNil(program.isFavorited)
        XCTAssertNil(program.broadcaster)
        XCTAssertNil(program.tracks)
        XCTAssertNil(program.createdAt)
        XCTAssertNil(program.updatedAt)
        XCTAssertNil(program.publishedAt)
        XCTAssertNil(program.shareUrl)
    }

    // MARK: - durationFormatted

    func testDurationFormattedZeroSeconds() throws {
        let json = """
        {"id": "p1", "title": "T", "duration_seconds": 0}
        """.data(using: .utf8)!
        let program = try makeDecoder().decode(Program.self, from: json)
        // 0 seconds -> "0:00"
        XCTAssertEqual(program.durationFormatted, "0:00")
    }

    func testDurationFormattedSixtySeconds() throws {
        let json = """
        {"id": "p2", "title": "T", "duration_seconds": 60}
        """.data(using: .utf8)!
        let program = try makeDecoder().decode(Program.self, from: json)
        // 60 seconds -> "1:00"
        XCTAssertEqual(program.durationFormatted, "1:00")
    }

    func testDurationFormattedOneHour() throws {
        let json = """
        {"id": "p3", "title": "T", "duration_seconds": 3600}
        """.data(using: .utf8)!
        let program = try makeDecoder().decode(Program.self, from: json)
        // 3600 seconds -> "1:00:00"
        XCTAssertEqual(program.durationFormatted, "1:00:00")
    }

    func testDurationFormattedMixed() throws {
        let json = """
        {"id": "p4", "title": "T", "duration_seconds": 3661}
        """.data(using: .utf8)!
        let program = try makeDecoder().decode(Program.self, from: json)
        // 3661 seconds -> 1h 1m 1s -> "1:01:01"
        XCTAssertEqual(program.durationFormatted, "1:01:01")
    }

    func testDurationFormattedNilDuration() throws {
        let json = """
        {"id": "p5", "title": "T"}
        """.data(using: .utf8)!
        let program = try makeDecoder().decode(Program.self, from: json)
        XCTAssertEqual(program.durationFormatted, "--:--")
    }

    // MARK: - ProgramType enum

    func testProgramTypeRawValues() {
        XCTAssertEqual(ProgramType.music.rawValue, "music")
        XCTAssertEqual(ProgramType.talk.rawValue, "talk")
        XCTAssertEqual(ProgramType.mixed.rawValue, "mixed")
    }

    func testProgramTypeDisplayNames() {
        XCTAssertEqual(ProgramType.music.displayName, "Music")
        XCTAssertEqual(ProgramType.talk.displayName, "Talk")
        XCTAssertEqual(ProgramType.mixed.displayName, "Mixed")
    }

    func testProgramTypeIconNames() {
        XCTAssertEqual(ProgramType.music.iconName, "music.note")
        XCTAssertEqual(ProgramType.talk.iconName, "mic")
        XCTAssertEqual(ProgramType.mixed.iconName, "music.mic")
    }

    func testProgramTypeCaseIterable() {
        XCTAssertEqual(ProgramType.allCases.count, 3)
    }

    // MARK: - ProgramStatus enum

    func testProgramStatusRawValues() {
        XCTAssertEqual(ProgramStatus.draft.rawValue, "draft")
        XCTAssertEqual(ProgramStatus.published.rawValue, "published")
        XCTAssertEqual(ProgramStatus.archived.rawValue, "archived")
    }

    func testProgramStatusDisplayNames() {
        XCTAssertEqual(ProgramStatus.draft.displayName, "Draft")
        XCTAssertEqual(ProgramStatus.published.displayName, "Published")
        XCTAssertEqual(ProgramStatus.archived.displayName, "Archived")
    }

    // MARK: - Program Equatable

    func testProgramEquatableSameId() throws {
        let json1 = """
        {"id": "same-id", "title": "Title A"}
        """.data(using: .utf8)!
        let json2 = """
        {"id": "same-id", "title": "Title B"}
        """.data(using: .utf8)!
        let decoder = makeDecoder()
        let p1 = try decoder.decode(Program.self, from: json1)
        let p2 = try decoder.decode(Program.self, from: json2)
        XCTAssertEqual(p1, p2)
    }

    func testProgramEquatableDifferentId() throws {
        let json1 = """
        {"id": "id-1", "title": "Title"}
        """.data(using: .utf8)!
        let json2 = """
        {"id": "id-2", "title": "Title"}
        """.data(using: .utf8)!
        let decoder = makeDecoder()
        let p1 = try decoder.decode(Program.self, from: json1)
        let p2 = try decoder.decode(Program.self, from: json2)
        XCTAssertNotEqual(p1, p2)
    }

    // MARK: - ProgramBroadcaster

    func testProgramBroadcasterDecoding() throws {
        let json = """
        {
            "id": "bc-1",
            "nickname": "DJ Cool",
            "avatar_url": "https://example.com/avatar.jpg"
        }
        """.data(using: .utf8)!
        let broadcaster = try makeDecoder().decode(ProgramBroadcaster.self, from: json)
        XCTAssertEqual(broadcaster.id, "bc-1")
        XCTAssertEqual(broadcaster.nickname, "DJ Cool")
        XCTAssertEqual(broadcaster.avatarUrl, "https://example.com/avatar.jpg")
    }

    func testProgramBroadcasterDecodingNilAvatar() throws {
        let json = """
        {
            "id": "bc-2",
            "nickname": "DJ Minimal"
        }
        """.data(using: .utf8)!
        let broadcaster = try makeDecoder().decode(ProgramBroadcaster.self, from: json)
        XCTAssertEqual(broadcaster.id, "bc-2")
        XCTAssertEqual(broadcaster.nickname, "DJ Minimal")
        XCTAssertNil(broadcaster.avatarUrl)
    }

    // MARK: - User Model Tests

    func testUserDecoding() throws {
        let json = """
        {
            "id": "user-1",
            "email": "test@example.com",
            "is_active": true,
            "is_admin": false,
            "email_verified": true,
            "nickname": "TestUser",
            "avatar_url": "https://example.com/avatar.jpg",
            "message": "Hello!"
        }
        """.data(using: .utf8)!
        let user = try makeDecoder().decode(User.self, from: json)
        XCTAssertEqual(user.id, "user-1")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.isActive, true)
        XCTAssertEqual(user.isAdmin, false)
        XCTAssertEqual(user.emailVerified, true)
        XCTAssertEqual(user.nickname, "TestUser")
        XCTAssertEqual(user.avatarUrl, "https://example.com/avatar.jpg")
        XCTAssertEqual(user.message, "Hello!")
    }

    func testUserDecodingOptionalFields() throws {
        let json = """
        {
            "id": "user-2",
            "email": "minimal@example.com"
        }
        """.data(using: .utf8)!
        let user = try makeDecoder().decode(User.self, from: json)
        XCTAssertEqual(user.id, "user-2")
        XCTAssertEqual(user.email, "minimal@example.com")
        XCTAssertNil(user.isActive)
        XCTAssertNil(user.isAdmin)
        XCTAssertNil(user.emailVerified)
        XCTAssertNil(user.nickname)
        XCTAssertNil(user.avatarUrl)
        XCTAssertNil(user.message)
    }

    func testUserEquatable() throws {
        let json1 = """
        {"id": "u1", "email": "a@b.com"}
        """.data(using: .utf8)!
        let json2 = """
        {"id": "u1", "email": "different@b.com"}
        """.data(using: .utf8)!
        let decoder = makeDecoder()
        let u1 = try decoder.decode(User.self, from: json1)
        let u2 = try decoder.decode(User.self, from: json2)
        XCTAssertEqual(u1, u2)
    }

    // MARK: - UserProfile Tests

    func testUserProfileDecoding() throws {
        let json = """
        {
            "id": "up-1",
            "nickname": "ProfileUser",
            "avatar_url": "https://example.com/avatar.jpg",
            "wallpaper_url": "https://example.com/wall.jpg",
            "message": "Bio text",
            "follower_count": 42,
            "program_count": 10,
            "following_count": 5,
            "favorite_count": 20
        }
        """.data(using: .utf8)!
        let profile = try makeDecoder().decode(UserProfile.self, from: json)
        XCTAssertEqual(profile.id, "up-1")
        XCTAssertEqual(profile.nickname, "ProfileUser")
        XCTAssertEqual(profile.avatarUrl, "https://example.com/avatar.jpg")
        XCTAssertEqual(profile.wallpaperUrl, "https://example.com/wall.jpg")
        XCTAssertEqual(profile.message, "Bio text")
        XCTAssertEqual(profile.followerCount, 42)
        XCTAssertEqual(profile.programCount, 10)
        XCTAssertEqual(profile.followingCount, 5)
        XCTAssertEqual(profile.favoriteCount, 20)
    }

    func testUserProfileDecodingOptionalFields() throws {
        let json = """
        {
            "id": "up-2",
            "nickname": "Minimal",
            "follower_count": 0
        }
        """.data(using: .utf8)!
        let profile = try makeDecoder().decode(UserProfile.self, from: json)
        XCTAssertEqual(profile.id, "up-2")
        XCTAssertEqual(profile.nickname, "Minimal")
        XCTAssertNil(profile.avatarUrl)
        XCTAssertNil(profile.wallpaperUrl)
        XCTAssertNil(profile.message)
        XCTAssertEqual(profile.followerCount, 0)
        XCTAssertNil(profile.programCount)
        XCTAssertNil(profile.followingCount)
        XCTAssertNil(profile.favoriteCount)
    }

    // MARK: - ProgramTrack Model Tests

    func testProgramTrackDecoding() throws {
        let json = """
        {
            "id": "track-1",
            "program_id": "prog-1",
            "apple_music_url": "https://music.apple.com/track/123",
            "apple_music_track_id": "123456",
            "title": "Cool Song",
            "artist_name": "Cool Artist",
            "artwork_url": "https://example.com/artwork.jpg",
            "play_timing_seconds": 120,
            "duration_seconds": 240,
            "track_order": 2
        }
        """.data(using: .utf8)!
        let track = try makeDecoder().decode(ProgramTrack.self, from: json)
        XCTAssertEqual(track.id, "track-1")
        XCTAssertEqual(track.programId, "prog-1")
        XCTAssertEqual(track.appleMusicUrl, "https://music.apple.com/track/123")
        XCTAssertEqual(track.appleMusicTrackId, "123456")
        XCTAssertEqual(track.title, "Cool Song")
        XCTAssertEqual(track.artistName, "Cool Artist")
        XCTAssertEqual(track.artworkUrl, "https://example.com/artwork.jpg")
        XCTAssertEqual(track.playTimingSeconds, 120)
        XCTAssertEqual(track.durationSeconds, 240)
        XCTAssertEqual(track.trackOrder, 2)
    }

    func testProgramTrackTrackNameAlias() throws {
        let json = """
        {
            "id": "t1",
            "apple_music_track_id": "abc",
            "title": "Song Title",
            "artist_name": "Artist",
            "play_timing_seconds": 0
        }
        """.data(using: .utf8)!
        let track = try makeDecoder().decode(ProgramTrack.self, from: json)
        XCTAssertEqual(track.trackName, "Song Title")
        XCTAssertEqual(track.trackName, track.title)
    }

    // MARK: - playTimingFormatted

    func testPlayTimingFormattedZero() throws {
        let json = """
        {
            "id": "t1",
            "apple_music_track_id": "abc",
            "title": "T",
            "artist_name": "A",
            "play_timing_seconds": 0
        }
        """.data(using: .utf8)!
        let track = try makeDecoder().decode(ProgramTrack.self, from: json)
        // 0 seconds -> "00:00:00"
        XCTAssertEqual(track.playTimingFormatted, "00:00:00")
    }

    func testPlayTimingFormattedMinutesAndSeconds() throws {
        let json = """
        {
            "id": "t2",
            "apple_music_track_id": "abc",
            "title": "T",
            "artist_name": "A",
            "play_timing_seconds": 125
        }
        """.data(using: .utf8)!
        let track = try makeDecoder().decode(ProgramTrack.self, from: json)
        // 125 seconds -> 0h 2m 5s -> "00:02:05"
        XCTAssertEqual(track.playTimingFormatted, "00:02:05")
    }

    func testPlayTimingFormattedHours() throws {
        let json = """
        {
            "id": "t3",
            "apple_music_track_id": "abc",
            "title": "T",
            "artist_name": "A",
            "play_timing_seconds": 3661
        }
        """.data(using: .utf8)!
        let track = try makeDecoder().decode(ProgramTrack.self, from: json)
        // 3661 seconds -> 1h 1m 1s -> "01:01:01"
        XCTAssertEqual(track.playTimingFormatted, "01:01:01")
    }

    // MARK: - playTimingInterval

    func testPlayTimingInterval() throws {
        let json = """
        {
            "id": "t4",
            "apple_music_track_id": "abc",
            "title": "T",
            "artist_name": "A",
            "play_timing_seconds": 300
        }
        """.data(using: .utf8)!
        let track = try makeDecoder().decode(ProgramTrack.self, from: json)
        XCTAssertEqual(track.playTimingInterval, 300.0, accuracy: 0.001)
    }

    // MARK: - sortOrder

    func testSortOrderWithTrackOrder() throws {
        let json = """
        {
            "id": "t5",
            "apple_music_track_id": "abc",
            "title": "T",
            "artist_name": "A",
            "play_timing_seconds": 0,
            "track_order": 5
        }
        """.data(using: .utf8)!
        let track = try makeDecoder().decode(ProgramTrack.self, from: json)
        XCTAssertEqual(track.sortOrder, 5)
    }

    func testSortOrderDefaultsToZero() throws {
        let json = """
        {
            "id": "t6",
            "apple_music_track_id": "abc",
            "title": "T",
            "artist_name": "A",
            "play_timing_seconds": 0
        }
        """.data(using: .utf8)!
        let track = try makeDecoder().decode(ProgramTrack.self, from: json)
        XCTAssertNil(track.trackOrder)
        XCTAssertEqual(track.sortOrder, 0)
    }

    // MARK: - ProgramTrack Equatable

    func testProgramTrackEquatable() throws {
        let json1 = """
        {"id": "t-same", "apple_music_track_id": "a", "title": "A", "artist_name": "X", "play_timing_seconds": 0}
        """.data(using: .utf8)!
        let json2 = """
        {"id": "t-same", "apple_music_track_id": "b", "title": "B", "artist_name": "Y", "play_timing_seconds": 100}
        """.data(using: .utf8)!
        let decoder = makeDecoder()
        let t1 = try decoder.decode(ProgramTrack.self, from: json1)
        let t2 = try decoder.decode(ProgramTrack.self, from: json2)
        XCTAssertEqual(t1, t2)
    }

    // MARK: - EditableTrack Tests

    func testEditableTrackInitFromProgramTrack() throws {
        let json = """
        {
            "id": "track-1",
            "apple_music_track_id": "am-123",
            "title": "My Song",
            "artist_name": "Artist",
            "artwork_url": "https://example.com/art.jpg",
            "play_timing_seconds": 60,
            "track_order": 3
        }
        """.data(using: .utf8)!
        let programTrack = try makeDecoder().decode(ProgramTrack.self, from: json)
        let editable = EditableTrack(from: programTrack)

        XCTAssertEqual(editable.id, "track-1")
        XCTAssertEqual(editable.appleMusicTrackId, "am-123")
        XCTAssertEqual(editable.trackName, "My Song")
        XCTAssertEqual(editable.artistName, "Artist")
        XCTAssertEqual(editable.artworkUrl, "https://example.com/art.jpg")
        XCTAssertEqual(editable.playTimingSeconds, 60)
        XCTAssertEqual(editable.sortOrder, 3)
    }

    func testEditableTrackInitFromProgramTrackNilTrackOrder() throws {
        let json = """
        {
            "id": "track-2",
            "apple_music_track_id": "am-456",
            "title": "Another Song",
            "artist_name": "Artist2",
            "play_timing_seconds": 0
        }
        """.data(using: .utf8)!
        let programTrack = try makeDecoder().decode(ProgramTrack.self, from: json)
        let editable = EditableTrack(from: programTrack)
        XCTAssertEqual(editable.sortOrder, 0)
    }

    func testEditableTrackDirectInit() {
        let editable = EditableTrack(
            appleMusicTrackId: "am-789",
            trackName: "Direct Song",
            artistName: "Direct Artist",
            artworkUrl: "https://example.com/direct.jpg",
            playTimingSeconds: 90,
            sortOrder: 1
        )
        XCTAssertFalse(editable.id.isEmpty)
        XCTAssertEqual(editable.appleMusicTrackId, "am-789")
        XCTAssertEqual(editable.trackName, "Direct Song")
        XCTAssertEqual(editable.artistName, "Direct Artist")
        XCTAssertEqual(editable.artworkUrl, "https://example.com/direct.jpg")
        XCTAssertEqual(editable.playTimingSeconds, 90)
        XCTAssertEqual(editable.sortOrder, 1)
    }

    func testEditableTrackDirectInitDefaults() {
        let editable = EditableTrack(
            appleMusicTrackId: "am-000",
            trackName: "Default Song",
            artistName: "Default Artist",
            artworkUrl: nil
        )
        XCTAssertEqual(editable.playTimingSeconds, 0)
        XCTAssertEqual(editable.sortOrder, 0)
        XCTAssertNil(editable.artworkUrl)
    }

    func testEditableTrackToTrackInput() {
        let editable = EditableTrack(
            appleMusicTrackId: "am-input",
            trackName: "Input Song",
            artistName: "Input Artist",
            artworkUrl: "https://example.com/input.jpg",
            playTimingSeconds: 45,
            sortOrder: 2
        )
        let input = editable.toTrackInput()
        XCTAssertEqual(input.appleMusicTrackId, "am-input")
        XCTAssertEqual(input.title, "Input Song")
        XCTAssertEqual(input.artistName, "Input Artist")
        XCTAssertEqual(input.artworkUrl, "https://example.com/input.jpg")
        XCTAssertEqual(input.playTimingSeconds, 45)
        XCTAssertEqual(input.trackOrder, 2)
    }

    func testEditableTrackToTrackInputNilArtwork() {
        let editable = EditableTrack(
            appleMusicTrackId: "am-nil",
            trackName: "No Art",
            artistName: "Artist",
            artworkUrl: nil
        )
        let input = editable.toTrackInput()
        XCTAssertNil(input.artworkUrl)
    }

    // MARK: - APIResponse Tests

    func testAPIResponseDecoding() throws {
        let json = """
        {
            "data": {
                "id": "prog-api",
                "title": "API Program"
            }
        }
        """.data(using: .utf8)!
        let response = try makeDecoder().decode(APIResponse<Program>.self, from: json)
        XCTAssertEqual(response.data.id, "prog-api")
        XCTAssertEqual(response.data.title, "API Program")
    }

    // MARK: - PaginatedResponse Tests

    func testPaginatedResponseDecoding() throws {
        let json = """
        {
            "data": [
                {"id": "p1", "title": "Program 1"},
                {"id": "p2", "title": "Program 2"}
            ],
            "meta": {
                "page": 1,
                "per_page": 30,
                "total": 50,
                "has_next": true
            }
        }
        """.data(using: .utf8)!
        let response = try makeDecoder().decode(PaginatedResponse<Program>.self, from: json)
        XCTAssertEqual(response.data.count, 2)
        XCTAssertEqual(response.data[0].id, "p1")
        XCTAssertEqual(response.data[1].title, "Program 2")
        XCTAssertEqual(response.meta.page, 1)
        XCTAssertEqual(response.meta.perPage, 30)
        XCTAssertEqual(response.meta.total, 50)
        XCTAssertTrue(response.meta.hasNext)
    }

    func testPaginatedResponseEmptyData() throws {
        let json = """
        {
            "data": [],
            "meta": {
                "page": 1,
                "per_page": 30,
                "total": 0,
                "has_next": false
            }
        }
        """.data(using: .utf8)!
        let response = try makeDecoder().decode(PaginatedResponse<Program>.self, from: json)
        XCTAssertTrue(response.data.isEmpty)
        XCTAssertEqual(response.meta.total, 0)
        XCTAssertFalse(response.meta.hasNext)
    }

    // MARK: - PaginationMeta Tests

    func testPaginationMetaDecoding() throws {
        let json = """
        {
            "page": 3,
            "per_page": 10,
            "total": 100,
            "has_next": true
        }
        """.data(using: .utf8)!
        let meta = try makeDecoder().decode(PaginationMeta.self, from: json)
        XCTAssertEqual(meta.page, 3)
        XCTAssertEqual(meta.perPage, 10)
        XCTAssertEqual(meta.total, 100)
        XCTAssertTrue(meta.hasNext)
    }

    // MARK: - AuthResponse Tests

    func testAuthResponseDecoding() throws {
        let json = """
        {
            "access_token": "eyJhbGciOiJIUzI1NiJ9.access",
            "refresh_token": "eyJhbGciOiJIUzI1NiJ9.refresh",
            "user": {
                "id": "user-auth",
                "email": "auth@example.com"
            }
        }
        """.data(using: .utf8)!
        let response = try makeDecoder().decode(AuthResponse.self, from: json)
        XCTAssertEqual(response.accessToken, "eyJhbGciOiJIUzI1NiJ9.access")
        XCTAssertEqual(response.refreshToken, "eyJhbGciOiJIUzI1NiJ9.refresh")
        XCTAssertEqual(response.user.id, "user-auth")
        XCTAssertEqual(response.user.email, "auth@example.com")
    }
}
