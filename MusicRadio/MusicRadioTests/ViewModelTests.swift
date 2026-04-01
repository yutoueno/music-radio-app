import XCTest
@testable import MusicRadio

// MARK: - ProgramViewModelTests

@MainActor
final class ProgramViewModelTests: XCTestCase {

    private var sut: ProgramViewModel!
    private var mockRepo: MockProgramRepository!

    override func setUp() {
        super.setUp()
        mockRepo = MockProgramRepository()
        sut = ProgramViewModel(programRepository: mockRepo)
    }

    override func tearDown() {
        sut = nil
        mockRepo = nil
        super.tearDown()
    }

    // MARK: - loadProgram

    func testLoadProgramSuccess() async {
        // Given
        let tracks = [
            TestData.makeProgramTrack(id: "t1", title: "Track 1"),
            TestData.makeProgramTrack(id: "t2", title: "Track 2")
        ]
        let program = TestData.makeProgram(
            id: "p1",
            title: "Test Program",
            isFavorited: false,
            tracks: tracks
        )
        mockRepo.programToReturn = program

        // When
        await sut.loadProgram(id: "p1")

        // Then
        XCTAssertEqual(sut.currentProgram?.id, "p1")
        XCTAssertEqual(sut.currentProgram?.title, "Test Program")
        XCTAssertEqual(sut.tracks.count, 2)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(mockRepo.fetchProgramCallCount, 1)
    }

    func testLoadProgramFailure() async {
        // Given
        mockRepo.shouldThrowError = true

        // When
        await sut.loadProgram(id: "nonexistent")

        // Then
        XCTAssertNil(sut.currentProgram)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(sut.tracks.isEmpty)
    }

    func testLoadProgramFetchesTracksSeparatelyWhenNotIncluded() async {
        // Given: program with nil tracks
        let program = TestData.makeProgram(id: "p1", title: "No Tracks", tracks: nil)
        let separateTracks = [
            TestData.makeProgramTrack(id: "t1", title: "Fetched Track")
        ]
        mockRepo.programToReturn = program
        mockRepo.tracksToReturn = separateTracks

        // When
        await sut.loadProgram(id: "p1")

        // Then
        XCTAssertEqual(sut.tracks.count, 1)
        XCTAssertEqual(sut.tracks.first?.title, "Fetched Track")
        XCTAssertEqual(mockRepo.fetchProgramTracksCallCount, 1)
    }

    func testLoadProgramSetsIsFavorited() async {
        // Given
        let program = TestData.makeProgram(id: "p1", title: "Favorited", isFavorited: true)
        mockRepo.programToReturn = program

        // When
        await sut.loadProgram(id: "p1")

        // Then
        XCTAssertTrue(sut.isFavorited)
    }

    func testIsLoadingDuringFetch() async {
        // Given
        let program = TestData.makeProgram(id: "p1", title: "Loading Test")
        mockRepo.programToReturn = program

        // Verify initial state
        XCTAssertFalse(sut.isLoading)

        // When
        await sut.loadProgram(id: "p1")

        // Then: after completion, loading should be false
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - toggleFavorite

    func testToggleFavoriteAdds() async {
        // Given: program is not favorited
        let program = TestData.makeProgram(id: "p1", title: "Test", isFavorited: false)
        mockRepo.programToReturn = program
        await sut.loadProgram(id: "p1")
        XCTAssertFalse(sut.isFavorited)

        // When
        await sut.toggleFavorite()

        // Then
        XCTAssertTrue(sut.isFavorited)
        XCTAssertEqual(mockRepo.addFavoriteCallCount, 1)
        XCTAssertEqual(mockRepo.removeFavoriteCallCount, 0)
    }

    func testToggleFavoriteRemoves() async {
        // Given: program is favorited
        let program = TestData.makeProgram(id: "p1", title: "Test", isFavorited: true)
        mockRepo.programToReturn = program
        await sut.loadProgram(id: "p1")
        XCTAssertTrue(sut.isFavorited)

        // When
        await sut.toggleFavorite()

        // Then
        XCTAssertFalse(sut.isFavorited)
        XCTAssertEqual(mockRepo.removeFavoriteCallCount, 1)
        XCTAssertEqual(mockRepo.addFavoriteCallCount, 0)
    }

    func testToggleFavoriteRevertsOnError() async {
        // Given: program is not favorited, but API will fail
        let program = TestData.makeProgram(id: "p1", title: "Test", isFavorited: false)
        mockRepo.programToReturn = program
        await sut.loadProgram(id: "p1")
        XCTAssertFalse(sut.isFavorited)

        mockRepo.shouldThrowError = true

        // When
        await sut.toggleFavorite()

        // Then: should revert back to original state
        XCTAssertFalse(sut.isFavorited)
        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - clearCurrentProgram

    func testClearCurrentProgram() async {
        // Given: loaded program
        let program = TestData.makeProgram(
            id: "p1",
            title: "Test",
            isFavorited: true,
            tracks: [TestData.makeProgramTrack(id: "t1", title: "Track")]
        )
        mockRepo.programToReturn = program
        await sut.loadProgram(id: "p1")
        XCTAssertNotNil(sut.currentProgram)
        XCTAssertFalse(sut.tracks.isEmpty)
        XCTAssertTrue(sut.isFavorited)

        // When
        sut.clearCurrentProgram()

        // Then
        XCTAssertNil(sut.currentProgram)
        XCTAssertTrue(sut.tracks.isEmpty)
        XCTAssertFalse(sut.isFavorited)
    }
}

// MARK: - TopViewModelTests

@MainActor
final class TopViewModelTests: XCTestCase {

    private var sut: TopViewModel!
    private var mockProgramRepo: MockProgramRepository!
    private var mockUserRepo: MockUserRepository!

    override func setUp() {
        super.setUp()
        mockProgramRepo = MockProgramRepository()
        mockUserRepo = MockUserRepository()
        sut = TopViewModel(programRepository: mockProgramRepo, userRepository: mockUserRepo)
    }

    override func tearDown() {
        sut = nil
        mockProgramRepo = nil
        mockUserRepo = nil
        super.tearDown()
    }

    // MARK: - loadAll

    func testLoadAllSuccess() async {
        // Given
        let recommendedPrograms = [
            TestData.makeProgram(id: "r1", title: "Recommended 1"),
            TestData.makeProgram(id: "r2", title: "Recommended 2")
        ]
        let favoritePrograms = [
            TestData.makeProgram(id: "f1", title: "Favorite 1")
        ]
        let follows = [
            TestData.makeBroadcaster(id: "b1", nickname: "Broadcaster 1")
        ]

        mockProgramRepo.recommendedProgramsToReturn = TestData.makePaginatedResponse(data: recommendedPrograms)
        mockProgramRepo.favoriteProgramsToReturn = TestData.makePaginatedResponse(data: favoritePrograms)
        mockUserRepo.followsToReturn = TestData.makePaginatedResponse(data: follows)

        // When
        await sut.loadAll()

        // Then
        XCTAssertEqual(sut.recommendedPrograms.count, 2)
        XCTAssertEqual(sut.favoritePrograms.count, 1)
        XCTAssertEqual(sut.followingBroadcasters.count, 1)
        XCTAssertFalse(sut.isLoadingRecommended)
        XCTAssertFalse(sut.isLoadingFavorites)
        XCTAssertFalse(sut.isLoadingFollows)
    }

    func testLoadAllWithPartialFailure() async {
        // Given: recommended succeeds, favorites fails, follows succeeds
        let recommendedPrograms = [
            TestData.makeProgram(id: "r1", title: "Recommended 1")
        ]
        let follows = [
            TestData.makeBroadcaster(id: "b1", nickname: "Broadcaster 1")
        ]

        mockProgramRepo.recommendedProgramsToReturn = TestData.makePaginatedResponse(data: recommendedPrograms)
        mockProgramRepo.shouldThrowErrorForFavorites = true
        mockUserRepo.followsToReturn = TestData.makePaginatedResponse(data: follows)

        // When
        await sut.loadAll()

        // Then: successful sections still loaded
        XCTAssertEqual(sut.recommendedPrograms.count, 1)
        XCTAssertTrue(sut.favoritePrograms.isEmpty)
        XCTAssertEqual(sut.followingBroadcasters.count, 1)
        XCTAssertNotNil(sut.errorMessage)
    }

    func testRefresh() async {
        // Given
        let programs = [TestData.makeProgram(id: "r1", title: "Program 1")]
        mockProgramRepo.recommendedProgramsToReturn = TestData.makePaginatedResponse(data: programs)
        mockProgramRepo.favoriteProgramsToReturn = TestData.makePaginatedResponse(data: [Program]())
        mockUserRepo.followsToReturn = TestData.makePaginatedResponse(data: [Broadcaster]())

        // When
        await sut.refresh()

        // Then
        XCTAssertEqual(sut.recommendedPrograms.count, 1)
        XCTAssertFalse(sut.isLoadingRecommended)
        XCTAssertFalse(sut.isLoadingFavorites)
        XCTAssertFalse(sut.isLoadingFollows)
    }

    func testLoadRecommendedOnly() async {
        // Given
        let programs = [
            TestData.makeProgram(id: "r1", title: "Rec 1"),
            TestData.makeProgram(id: "r2", title: "Rec 2"),
            TestData.makeProgram(id: "r3", title: "Rec 3")
        ]
        mockProgramRepo.recommendedProgramsToReturn = TestData.makePaginatedResponse(data: programs)

        // When
        await sut.loadRecommended()

        // Then
        XCTAssertEqual(sut.recommendedPrograms.count, 3)
        XCTAssertFalse(sut.isLoadingRecommended)
        XCTAssertNil(sut.errorMessage)
        // Other sections remain empty
        XCTAssertTrue(sut.favoritePrograms.isEmpty)
        XCTAssertTrue(sut.followingBroadcasters.isEmpty)
    }

    func testLoadFavoritesOnly() async {
        // Given
        let favorites = [
            TestData.makeProgram(id: "f1", title: "Fav 1")
        ]
        mockProgramRepo.favoriteProgramsToReturn = TestData.makePaginatedResponse(data: favorites)

        // When
        await sut.loadFavorites()

        // Then
        XCTAssertEqual(sut.favoritePrograms.count, 1)
        XCTAssertFalse(sut.isLoadingFavorites)
        XCTAssertNil(sut.errorMessage)
    }

    func testEmptyStateHandling() async {
        // Given: all sections return empty
        mockProgramRepo.recommendedProgramsToReturn = TestData.makePaginatedResponse(data: [Program]())
        mockProgramRepo.favoriteProgramsToReturn = TestData.makePaginatedResponse(data: [Program]())
        mockUserRepo.followsToReturn = TestData.makePaginatedResponse(data: [Broadcaster]())

        // When
        await sut.loadAll()

        // Then
        XCTAssertTrue(sut.recommendedPrograms.isEmpty)
        XCTAssertTrue(sut.favoritePrograms.isEmpty)
        XCTAssertTrue(sut.followingBroadcasters.isEmpty)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoadingRecommended)
        XCTAssertFalse(sut.isLoadingFavorites)
        XCTAssertFalse(sut.isLoadingFollows)
    }
}

// MARK: - AuthViewModelTests

@MainActor
final class AuthViewModelTests: XCTestCase {

    private var sut: AuthViewModel!
    private var mockRepo: MockAuthRepository!

    override func setUp() {
        super.setUp()
        mockRepo = MockAuthRepository()
        sut = AuthViewModel(authRepository: mockRepo)
    }

    override func tearDown() {
        sut = nil
        mockRepo = nil
        super.tearDown()
    }

    // MARK: - Sign In

    func testSignInSuccess() async {
        // Given
        let user = TestData.makeUser(id: "u1", email: "test@example.com")
        mockRepo.authResponseToReturn = AuthResponse(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            user: user
        )
        sut.signInEmail = "test@example.com"
        sut.signInPassword = "password123"

        // When
        await sut.signIn()

        // Then
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(mockRepo.signInCallCount, 1)
        // Fields should be cleared after successful sign in
        XCTAssertEqual(sut.signInEmail, "")
        XCTAssertEqual(sut.signInPassword, "")
    }

    func testSignInFailure() async {
        // Given
        mockRepo.shouldThrowError = true
        sut.signInEmail = "test@example.com"
        sut.signInPassword = "wrongpassword"

        // When
        await sut.signIn()

        // Then
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func testSignInValidationEmptyEmail() async {
        // Given
        sut.signInEmail = ""
        sut.signInPassword = "password123"

        // When
        await sut.signIn()

        // Then
        XCTAssertEqual(sut.errorMessage, "Please enter your email address")
        XCTAssertEqual(mockRepo.signInCallCount, 0)
    }

    func testSignInValidationEmptyPassword() async {
        // Given
        sut.signInEmail = "test@example.com"
        sut.signInPassword = ""

        // When
        await sut.signIn()

        // Then
        XCTAssertEqual(sut.errorMessage, "Please enter your password")
        XCTAssertEqual(mockRepo.signInCallCount, 0)
    }

    // MARK: - Sign Up

    func testSignUpSuccess() async {
        // Given
        mockRepo.messageResponseToReturn = MessageResponse(message: "Verification email sent")
        sut.signUpEmail = "new@example.com"

        // When
        await sut.signUp()

        // Then
        XCTAssertEqual(sut.signUpSuccessMessage, "Verification email sent")
        XCTAssertTrue(sut.showVerification)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(mockRepo.signUpCallCount, 1)
    }

    func testSignUpInvalidEmail() async {
        // Given: email without @ and .
        sut.signUpEmail = "notanemail"

        // When
        await sut.signUp()

        // Then
        XCTAssertEqual(sut.errorMessage, "Please enter a valid email address")
        XCTAssertEqual(mockRepo.signUpCallCount, 0)
    }

    func testSignUpEmptyEmail() async {
        // Given
        sut.signUpEmail = ""

        // When
        await sut.signUp()

        // Then
        XCTAssertEqual(sut.errorMessage, "Please enter your email address")
        XCTAssertEqual(mockRepo.signUpCallCount, 0)
    }

    // MARK: - Email Verification

    func testVerifyEmailSuccess() async {
        // Given
        mockRepo.verificationResponseToReturn = VerificationResponse(
            token: "verification-token-123",
            message: "Email verified"
        )
        sut.signUpEmail = "test@example.com"
        sut.verificationCode = "123456"

        // When
        await sut.verifyEmail()

        // Then
        XCTAssertEqual(sut.verificationToken, "verification-token-123")
        XCTAssertTrue(sut.showInitialRegistration)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(mockRepo.verifyEmailCallCount, 1)
    }

    func testVerifyEmailEmptyCode() async {
        // Given
        sut.verificationCode = ""

        // When
        await sut.verifyEmail()

        // Then
        XCTAssertEqual(sut.errorMessage, "Please enter the verification code")
        XCTAssertEqual(mockRepo.verifyEmailCallCount, 0)
    }

    // MARK: - Complete Registration

    func testCompleteRegistrationSuccess() async {
        // Given
        let user = TestData.makeUser(id: "u1", email: "test@example.com")
        mockRepo.authResponseToReturn = AuthResponse(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            user: user
        )
        sut.verificationToken = "valid-token"
        sut.registrationNickname = "TestUser"
        sut.registrationPassword = "password123"
        sut.registrationPasswordConfirm = "password123"

        // When
        await sut.completeRegistration()

        // Then
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(mockRepo.completeRegistrationCallCount, 1)
    }

    func testCompleteRegistrationPasswordTooShort() async {
        // Given
        sut.verificationToken = "valid-token"
        sut.registrationNickname = "TestUser"
        sut.registrationPassword = "short"
        sut.registrationPasswordConfirm = "short"

        // When
        await sut.completeRegistration()

        // Then
        XCTAssertEqual(sut.errorMessage, "Password must be at least 8 characters")
        XCTAssertEqual(mockRepo.completeRegistrationCallCount, 0)
    }

    func testCompleteRegistrationPasswordMismatch() async {
        // Given
        sut.verificationToken = "valid-token"
        sut.registrationNickname = "TestUser"
        sut.registrationPassword = "password123"
        sut.registrationPasswordConfirm = "different123"

        // When
        await sut.completeRegistration()

        // Then
        XCTAssertEqual(sut.errorMessage, "Passwords do not match")
        XCTAssertEqual(mockRepo.completeRegistrationCallCount, 0)
    }

    func testCompleteRegistrationMissingToken() async {
        // Given
        sut.verificationToken = nil
        sut.registrationNickname = "TestUser"
        sut.registrationPassword = "password123"
        sut.registrationPasswordConfirm = "password123"

        // When
        await sut.completeRegistration()

        // Then
        XCTAssertEqual(sut.errorMessage, "Verification token not found. Please restart the registration.")
        XCTAssertEqual(mockRepo.completeRegistrationCallCount, 0)
    }

    // MARK: - Logout

    func testLogout() async {
        // Given: simulate authenticated state
        let user = TestData.makeUser(id: "u1", email: "test@example.com")
        mockRepo.authResponseToReturn = AuthResponse(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            user: user
        )
        sut.signInEmail = "test@example.com"
        sut.signInPassword = "password123"
        await sut.signIn()
        XCTAssertTrue(sut.isAuthenticated)

        // When
        await sut.logout()

        // Then
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertEqual(sut.signInEmail, "")
        XCTAssertEqual(sut.signInPassword, "")
        XCTAssertEqual(sut.signUpEmail, "")
        XCTAssertNil(sut.verificationToken)
    }
}
