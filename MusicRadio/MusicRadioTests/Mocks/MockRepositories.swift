import Foundation
@testable import MusicRadio

// MARK: - Test Error

enum MockError: Error, LocalizedError {
    case mock
    case custom(String)

    var errorDescription: String? {
        switch self {
        case .mock:
            return "Mock error"
        case .custom(let message):
            return message
        }
    }
}

// MARK: - MockProgramRepository

final class MockProgramRepository: ProgramRepositoryProtocol {

    // MARK: Configurable return values

    var recommendedProgramsToReturn: PaginatedResponse<Program> = PaginatedResponse(
        data: [],
        meta: PaginationMeta(page: 1, perPage: 30, total: 0, hasNext: false)
    )
    var programsToReturn: PaginatedResponse<Program> = PaginatedResponse(
        data: [],
        meta: PaginationMeta(page: 1, perPage: 30, total: 0, hasNext: false)
    )
    var searchProgramsToReturn: PaginatedResponse<Program> = PaginatedResponse(
        data: [],
        meta: PaginationMeta(page: 1, perPage: 30, total: 0, hasNext: false)
    )
    var programToReturn: Program?
    var tracksToReturn: [ProgramTrack] = []
    var createdProgramToReturn: Program?
    var updatedProgramToReturn: Program?
    var publishedProgramToReturn: Program?
    var myProgramsToReturn: PaginatedResponse<Program> = PaginatedResponse(
        data: [],
        meta: PaginationMeta(page: 1, perPage: 30, total: 0, hasNext: false)
    )
    var favoriteProgramsToReturn: PaginatedResponse<Program> = PaginatedResponse(
        data: [],
        meta: PaginationMeta(page: 1, perPage: 30, total: 0, hasNext: false)
    )

    // MARK: Error control

    var shouldThrowError: Bool = false
    var shouldThrowErrorForFavorites: Bool = false
    var errorToThrow: Error = MockError.mock

    // MARK: Call tracking

    var fetchRecommendedProgramsCallCount: Int = 0
    var fetchProgramsCallCount: Int = 0
    var searchProgramsCallCount: Int = 0
    var fetchProgramCallCount: Int = 0
    var fetchProgramTracksCallCount: Int = 0
    var createProgramCallCount: Int = 0
    var updateProgramCallCount: Int = 0
    var deleteProgramCallCount: Int = 0
    var publishProgramCallCount: Int = 0
    var fetchMyProgramsCallCount: Int = 0
    var addFavoriteCallCount: Int = 0
    var removeFavoriteCallCount: Int = 0
    var fetchFavoriteProgramsCallCount: Int = 0

    // MARK: Captured arguments

    var lastFetchProgramId: String?
    var lastFetchProgramTracksId: String?
    var lastCreateProgramTitle: String?
    var lastCreateProgramType: ProgramType?
    var lastUpdateProgramId: String?
    var lastDeleteProgramId: String?
    var lastPublishProgramId: String?
    var lastAddFavoriteProgramId: String?
    var lastRemoveFavoriteProgramId: String?
    var lastSearchQuery: String?
    var lastSearchGenre: String?

    // MARK: Protocol methods

    func fetchRecommendedPrograms(page: Int) async throws -> PaginatedResponse<Program> {
        fetchRecommendedProgramsCallCount += 1
        if shouldThrowError { throw errorToThrow }
        return recommendedProgramsToReturn
    }

    func fetchPrograms(page: Int) async throws -> PaginatedResponse<Program> {
        fetchProgramsCallCount += 1
        if shouldThrowError { throw errorToThrow }
        return programsToReturn
    }

    func searchPrograms(query: String?, genre: String?, sortBy: String, sortOrder: String, page: Int) async throws -> PaginatedResponse<Program> {
        searchProgramsCallCount += 1
        lastSearchQuery = query
        lastSearchGenre = genre
        if shouldThrowError { throw errorToThrow }
        return searchProgramsToReturn
    }

    func fetchProgram(id: String) async throws -> Program {
        fetchProgramCallCount += 1
        lastFetchProgramId = id
        if shouldThrowError { throw errorToThrow }
        guard let program = programToReturn else {
            throw MockError.custom("programToReturn not set")
        }
        return program
    }

    func fetchProgramTracks(programId: String) async throws -> [ProgramTrack] {
        fetchProgramTracksCallCount += 1
        lastFetchProgramTracksId = programId
        if shouldThrowError { throw errorToThrow }
        return tracksToReturn
    }

    func createProgram(title: String, description: String?, programType: ProgramType, tracks: [TrackInput]?) async throws -> Program {
        createProgramCallCount += 1
        lastCreateProgramTitle = title
        lastCreateProgramType = programType
        if shouldThrowError { throw errorToThrow }
        guard let program = createdProgramToReturn else {
            throw MockError.custom("createdProgramToReturn not set")
        }
        return program
    }

    func updateProgram(id: String, title: String?, description: String?, tracks: [TrackInput]?) async throws -> Program {
        updateProgramCallCount += 1
        lastUpdateProgramId = id
        if shouldThrowError { throw errorToThrow }
        guard let program = updatedProgramToReturn else {
            throw MockError.custom("updatedProgramToReturn not set")
        }
        return program
    }

    func deleteProgram(id: String) async throws {
        deleteProgramCallCount += 1
        lastDeleteProgramId = id
        if shouldThrowError { throw errorToThrow }
    }

    func publishProgram(id: String) async throws -> Program {
        publishProgramCallCount += 1
        lastPublishProgramId = id
        if shouldThrowError { throw errorToThrow }
        guard let program = publishedProgramToReturn else {
            throw MockError.custom("publishedProgramToReturn not set")
        }
        return program
    }

    func fetchMyPrograms(page: Int) async throws -> PaginatedResponse<Program> {
        fetchMyProgramsCallCount += 1
        if shouldThrowError { throw errorToThrow }
        return myProgramsToReturn
    }

    func addFavorite(programId: String) async throws {
        addFavoriteCallCount += 1
        lastAddFavoriteProgramId = programId
        if shouldThrowError { throw errorToThrow }
    }

    func removeFavorite(programId: String) async throws {
        removeFavoriteCallCount += 1
        lastRemoveFavoriteProgramId = programId
        if shouldThrowError { throw errorToThrow }
    }

    func fetchFavoritePrograms(page: Int) async throws -> PaginatedResponse<Program> {
        fetchFavoriteProgramsCallCount += 1
        if shouldThrowError || shouldThrowErrorForFavorites { throw errorToThrow }
        return favoriteProgramsToReturn
    }
}

// MARK: - MockAuthRepository

final class MockAuthRepository: AuthRepositoryProtocol {

    // MARK: Configurable return values

    var authResponseToReturn: AuthResponse?
    var messageResponseToReturn = MessageResponse(message: "OK")
    var verificationResponseToReturn = VerificationResponse(token: "mock-token", message: nil)

    // MARK: Error control

    var shouldThrowError: Bool = false
    var errorToThrow: Error = MockError.mock

    // MARK: Call tracking

    var signInCallCount: Int = 0
    var signUpCallCount: Int = 0
    var verifyEmailCallCount: Int = 0
    var completeRegistrationCallCount: Int = 0
    var requestPasswordResetCallCount: Int = 0
    var confirmPasswordResetCallCount: Int = 0
    var logoutCallCount: Int = 0

    // MARK: Captured arguments

    var lastSignInEmail: String?
    var lastSignInPassword: String?
    var lastSignUpEmail: String?
    var lastVerifyEmailEmail: String?
    var lastVerifyEmailCode: String?
    var lastCompleteRegistrationToken: String?
    var lastCompleteRegistrationNickname: String?

    // MARK: Protocol methods

    func signIn(email: String, password: String) async throws -> AuthResponse {
        signInCallCount += 1
        lastSignInEmail = email
        lastSignInPassword = password
        if shouldThrowError { throw errorToThrow }
        guard let response = authResponseToReturn else {
            throw MockError.custom("authResponseToReturn not set")
        }
        return response
    }

    func signUp(email: String) async throws -> MessageResponse {
        signUpCallCount += 1
        lastSignUpEmail = email
        if shouldThrowError { throw errorToThrow }
        return messageResponseToReturn
    }

    func verifyEmail(email: String, code: String) async throws -> VerificationResponse {
        verifyEmailCallCount += 1
        lastVerifyEmailEmail = email
        lastVerifyEmailCode = code
        if shouldThrowError { throw errorToThrow }
        return verificationResponseToReturn
    }

    func completeRegistration(token: String, nickname: String, password: String) async throws -> AuthResponse {
        completeRegistrationCallCount += 1
        lastCompleteRegistrationToken = token
        lastCompleteRegistrationNickname = nickname
        if shouldThrowError { throw errorToThrow }
        guard let response = authResponseToReturn else {
            throw MockError.custom("authResponseToReturn not set")
        }
        return response
    }

    func requestPasswordReset(email: String) async throws -> MessageResponse {
        requestPasswordResetCallCount += 1
        if shouldThrowError { throw errorToThrow }
        return messageResponseToReturn
    }

    func confirmPasswordReset(token: String, password: String) async throws -> MessageResponse {
        confirmPasswordResetCallCount += 1
        if shouldThrowError { throw errorToThrow }
        return messageResponseToReturn
    }

    func logout() async throws {
        logoutCallCount += 1
        if shouldThrowError { throw errorToThrow }
    }
}

// MARK: - MockUserRepository

final class MockUserRepository: UserRepositoryProtocol {

    // MARK: Configurable return values

    var profileToReturn: UserProfile?
    var uploadResponseToReturn = UploadResponse(url: "https://example.com/avatar.jpg", fileName: "avatar.jpg")
    var broadcasterToReturn: Broadcaster?
    var broadcasterProgramsToReturn: PaginatedResponse<Program> = PaginatedResponse(
        data: [],
        meta: PaginationMeta(page: 1, perPage: 30, total: 0, hasNext: false)
    )
    var followsToReturn: PaginatedResponse<Broadcaster> = PaginatedResponse(
        data: [],
        meta: PaginationMeta(page: 1, perPage: 30, total: 0, hasNext: false)
    )

    // MARK: Error control

    var shouldThrowError: Bool = false
    var errorToThrow: Error = MockError.mock

    // MARK: Call tracking

    var fetchMyProfileCallCount: Int = 0
    var updateProfileCallCount: Int = 0
    var uploadAvatarCallCount: Int = 0
    var fetchBroadcasterCallCount: Int = 0
    var fetchBroadcasterProgramsCallCount: Int = 0
    var fetchFollowsCallCount: Int = 0
    var followCallCount: Int = 0
    var unfollowCallCount: Int = 0

    // MARK: Captured arguments

    var lastUpdateNickname: String?
    var lastUpdateMessage: String?
    var lastUploadImageData: Data?
    var lastFetchBroadcasterId: String?
    var lastFollowBroadcasterId: String?
    var lastUnfollowBroadcasterId: String?

    // MARK: Protocol methods

    func fetchMyProfile() async throws -> UserProfile {
        fetchMyProfileCallCount += 1
        if shouldThrowError { throw errorToThrow }
        guard let profile = profileToReturn else {
            throw MockError.custom("profileToReturn not set")
        }
        return profile
    }

    func updateProfile(nickname: String?, message: String?) async throws -> UserProfile {
        updateProfileCallCount += 1
        lastUpdateNickname = nickname
        lastUpdateMessage = message
        if shouldThrowError { throw errorToThrow }
        guard let profile = profileToReturn else {
            throw MockError.custom("profileToReturn not set")
        }
        return profile
    }

    func uploadAvatar(imageData: Data) async throws -> UploadResponse {
        uploadAvatarCallCount += 1
        lastUploadImageData = imageData
        if shouldThrowError { throw errorToThrow }
        return uploadResponseToReturn
    }

    func fetchBroadcaster(id: String) async throws -> Broadcaster {
        fetchBroadcasterCallCount += 1
        lastFetchBroadcasterId = id
        if shouldThrowError { throw errorToThrow }
        guard let broadcaster = broadcasterToReturn else {
            throw MockError.custom("broadcasterToReturn not set")
        }
        return broadcaster
    }

    func fetchBroadcasterPrograms(id: String, page: Int) async throws -> PaginatedResponse<Program> {
        fetchBroadcasterProgramsCallCount += 1
        lastFetchBroadcasterId = id
        if shouldThrowError { throw errorToThrow }
        return broadcasterProgramsToReturn
    }

    func fetchFollows(page: Int) async throws -> PaginatedResponse<Broadcaster> {
        fetchFollowsCallCount += 1
        if shouldThrowError { throw errorToThrow }
        return followsToReturn
    }

    func follow(broadcasterId: String) async throws {
        followCallCount += 1
        lastFollowBroadcasterId = broadcasterId
        if shouldThrowError { throw errorToThrow }
    }

    func unfollow(broadcasterId: String) async throws {
        unfollowCallCount += 1
        lastUnfollowBroadcasterId = broadcasterId
        if shouldThrowError { throw errorToThrow }
    }
}
