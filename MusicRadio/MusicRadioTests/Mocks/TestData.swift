import Foundation
@testable import MusicRadio

// MARK: - Test Data Factory

enum TestData {

    // MARK: - Program

    static func makeProgram(
        id: String = "test-program-1",
        userId: String? = "user-1",
        title: String = "Test Program",
        description: String? = "A test program description",
        thumbnailUrl: String? = nil,
        audioUrl: String? = "https://example.com/audio.mp3",
        durationSeconds: Int? = 3600,
        programType: ProgramType? = .music,
        genre: String? = "Pop",
        status: ProgramStatus? = .published,
        scheduledAt: Date? = nil,
        playCount: Int? = 100,
        favoriteCount: Int? = 10,
        isFavorited: Bool? = false,
        broadcaster: ProgramBroadcaster? = nil,
        tracks: [ProgramTrack]? = nil,
        createdAt: Date? = Date(),
        updatedAt: Date? = Date(),
        publishedAt: Date? = Date(),
        shareUrl: String? = nil
    ) -> Program {
        Program(
            id: id,
            userId: userId,
            title: title,
            description: description,
            thumbnailUrl: thumbnailUrl,
            audioUrl: audioUrl,
            durationSeconds: durationSeconds,
            programType: programType,
            genre: genre,
            status: status,
            scheduledAt: scheduledAt,
            playCount: playCount,
            favoriteCount: favoriteCount,
            isFavorited: isFavorited,
            broadcaster: broadcaster ?? makeProgramBroadcaster(),
            tracks: tracks,
            createdAt: createdAt,
            updatedAt: updatedAt,
            publishedAt: publishedAt,
            shareUrl: shareUrl
        )
    }

    // MARK: - ProgramBroadcaster

    static func makeProgramBroadcaster(
        id: String = "broadcaster-1",
        nickname: String = "Test Broadcaster",
        avatarUrl: String? = nil
    ) -> ProgramBroadcaster {
        ProgramBroadcaster(
            id: id,
            nickname: nickname,
            avatarUrl: avatarUrl
        )
    }

    // MARK: - User

    static func makeUser(
        id: String = "user-1",
        email: String = "test@example.com",
        isActive: Bool? = true,
        isAdmin: Bool? = false,
        emailVerified: Bool? = true,
        nickname: String? = "TestUser",
        avatarUrl: String? = nil,
        message: String? = nil
    ) -> User {
        User(
            id: id,
            email: email,
            isActive: isActive,
            isAdmin: isAdmin,
            emailVerified: emailVerified,
            nickname: nickname,
            avatarUrl: avatarUrl,
            message: message
        )
    }

    // MARK: - UserProfile

    static func makeUserProfile(
        id: String = "user-1",
        nickname: String = "TestUser",
        avatarUrl: String? = nil,
        wallpaperUrl: String? = nil,
        message: String? = "Hello!",
        followerCount: Int = 50,
        programCount: Int? = 5,
        followingCount: Int? = 10,
        favoriteCount: Int? = 20
    ) -> UserProfile {
        UserProfile(
            id: id,
            nickname: nickname,
            avatarUrl: avatarUrl,
            wallpaperUrl: wallpaperUrl,
            message: message,
            followerCount: followerCount,
            programCount: programCount,
            followingCount: followingCount,
            favoriteCount: favoriteCount
        )
    }

    // MARK: - Broadcaster

    static func makeBroadcaster(
        id: String = "broadcaster-1",
        nickname: String = "Test Broadcaster",
        avatarUrl: String? = nil,
        message: String? = "Broadcasting the best music",
        programCount: Int? = 10,
        followerCount: Int = 100,
        isFollowing: Bool? = false
    ) -> Broadcaster {
        Broadcaster(
            id: id,
            nickname: nickname,
            avatarUrl: avatarUrl,
            message: message,
            programCount: programCount,
            followerCount: followerCount,
            isFollowing: isFollowing
        )
    }

    // MARK: - ProgramTrack

    static func makeProgramTrack(
        id: String = "track-1",
        programId: String? = "test-program-1",
        appleMusicUrl: String? = "https://music.apple.com/track/123",
        appleMusicTrackId: String = "apple-track-123",
        title: String = "Test Song",
        artistName: String = "Test Artist",
        artworkUrl: String? = "https://example.com/artwork.jpg",
        playTimingSeconds: Int = 60,
        durationSeconds: Int? = 240,
        trackOrder: Int? = 1
    ) -> ProgramTrack {
        ProgramTrack(
            id: id,
            programId: programId,
            appleMusicUrl: appleMusicUrl,
            appleMusicTrackId: appleMusicTrackId,
            title: title,
            artistName: artistName,
            artworkUrl: artworkUrl,
            playTimingSeconds: playTimingSeconds,
            durationSeconds: durationSeconds,
            trackOrder: trackOrder
        )
    }

    // MARK: - PaginatedResponse

    static func makePaginatedResponse<T: Codable>(
        data: [T],
        page: Int = 1,
        perPage: Int = 30,
        total: Int? = nil,
        hasNext: Bool = false
    ) -> PaginatedResponse<T> {
        PaginatedResponse(
            data: data,
            meta: PaginationMeta(
                page: page,
                perPage: perPage,
                total: total ?? data.count,
                hasNext: hasNext
            )
        )
    }

    // MARK: - AuthResponse

    static func makeAuthResponse(
        accessToken: String = "mock-access-token",
        refreshToken: String = "mock-refresh-token",
        user: User? = nil
    ) -> AuthResponse {
        AuthResponse(
            accessToken: accessToken,
            refreshToken: refreshToken,
            user: user ?? makeUser()
        )
    }

    // MARK: - VerificationResponse

    static func makeVerificationResponse(
        token: String = "mock-verification-token",
        message: String? = "Verification successful"
    ) -> VerificationResponse {
        VerificationResponse(
            token: token,
            message: message
        )
    }

    // MARK: - MessageResponse

    static func makeMessageResponse(
        message: String = "Success"
    ) -> MessageResponse {
        MessageResponse(message: message)
    }

    // MARK: - UploadResponse

    static func makeUploadResponse(
        url: String = "https://example.com/uploads/file.jpg",
        fileName: String? = "file.jpg"
    ) -> UploadResponse {
        UploadResponse(url: url, fileName: fileName)
    }

    // MARK: - Convenience: Lists

    static func makeProgramList(count: Int = 3) -> [Program] {
        (0..<count).map { i in
            makeProgram(
                id: "program-\(i + 1)",
                title: "Program \(i + 1)",
                playCount: (i + 1) * 50
            )
        }
    }

    static func makeTrackList(count: Int = 3, programId: String = "test-program-1") -> [ProgramTrack] {
        (0..<count).map { i in
            makeProgramTrack(
                id: "track-\(i + 1)",
                programId: programId,
                appleMusicTrackId: "apple-track-\(i + 1)",
                title: "Song \(i + 1)",
                artistName: "Artist \(i + 1)",
                playTimingSeconds: i * 120,
                trackOrder: i + 1
            )
        }
    }

    static func makeBroadcasterList(count: Int = 3) -> [Broadcaster] {
        (0..<count).map { i in
            makeBroadcaster(
                id: "broadcaster-\(i + 1)",
                nickname: "Broadcaster \(i + 1)",
                followerCount: (i + 1) * 100
            )
        }
    }
}
