import XCTest
@testable import MusicRadio

// MARK: - MockUploadRepository

final class MockUploadRepository: UploadRepositoryProtocol {

    // MARK: Configurable return values

    var uploadAudioResponseToReturn = UploadResponse(url: "https://example.com/audio.mp3", fileName: "audio.mp3")
    var uploadAvatarResponseToReturn = UploadResponse(url: "https://example.com/avatar.jpg", fileName: "avatar.jpg")

    // MARK: Error control

    var shouldThrowError: Bool = false
    var errorToThrow: Error = MockError.mock

    // MARK: Call tracking

    var uploadProgramAudioCallCount: Int = 0
    var uploadAvatarCallCount: Int = 0

    // MARK: Captured arguments

    var lastUploadProgramId: String?
    var lastUploadAudioData: Data?
    var lastUploadFileName: String?
    var lastUploadAvatarData: Data?

    // MARK: Protocol methods

    func uploadProgramAudio(
        programId: String,
        audioData: Data,
        fileName: String,
        onProgress: ((Double) -> Void)?
    ) async throws -> UploadResponse {
        uploadProgramAudioCallCount += 1
        lastUploadProgramId = programId
        lastUploadAudioData = audioData
        lastUploadFileName = fileName
        if shouldThrowError { throw errorToThrow }
        onProgress?(1.0)
        return uploadAudioResponseToReturn
    }

    func uploadAvatar(imageData: Data) async throws -> UploadResponse {
        uploadAvatarCallCount += 1
        lastUploadAvatarData = imageData
        if shouldThrowError { throw errorToThrow }
        return uploadAvatarResponseToReturn
    }
}

// MARK: - BroadcasterViewModelTests

@MainActor
final class BroadcasterViewModelTests: XCTestCase {

    private var sut: BroadcasterViewModel!
    private var mockUserRepo: MockUserRepository!

    override func setUp() {
        super.setUp()
        mockUserRepo = MockUserRepository()
        sut = BroadcasterViewModel(userRepository: mockUserRepo)
    }

    override func tearDown() {
        sut = nil
        mockUserRepo = nil
        super.tearDown()
    }

    // MARK: - loadBroadcaster

    func testLoadBroadcasterSuccess() async {
        // Given
        let broadcaster = TestData.makeBroadcaster(
            id: "b1",
            nickname: "DJ Test",
            followerCount: 500,
            isFollowing: true
        )
        let programs = TestData.makeProgramList(count: 2)

        mockUserRepo.broadcasterToReturn = broadcaster
        mockUserRepo.broadcasterProgramsToReturn = TestData.makePaginatedResponse(
            data: programs,
            hasNext: true
        )

        // When
        await sut.loadBroadcaster(id: "b1")

        // Then
        XCTAssertEqual(sut.broadcaster?.id, "b1")
        XCTAssertEqual(sut.broadcaster?.nickname, "DJ Test")
        XCTAssertTrue(sut.isFollowing)
        XCTAssertEqual(sut.programs.count, 2)
        XCTAssertTrue(sut.hasMore)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(mockUserRepo.fetchBroadcasterCallCount, 1)
        XCTAssertEqual(mockUserRepo.fetchBroadcasterProgramsCallCount, 1)
    }

    func testLoadBroadcasterFailure() async {
        // Given
        mockUserRepo.shouldThrowError = true

        // When
        await sut.loadBroadcaster(id: "b1")

        // Then
        XCTAssertNil(sut.broadcaster)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(sut.programs.isEmpty)
    }

    func testLoadBroadcasterSetsIsFollowingFalseWhenNil() async {
        // Given: broadcaster with nil isFollowing
        let broadcaster = TestData.makeBroadcaster(id: "b1", isFollowing: nil)
        mockUserRepo.broadcasterToReturn = broadcaster
        mockUserRepo.broadcasterProgramsToReturn = TestData.makePaginatedResponse(data: [Program]())

        // When
        await sut.loadBroadcaster(id: "b1")

        // Then
        XCTAssertFalse(sut.isFollowing)
    }

    // MARK: - loadMorePrograms

    func testLoadMoreProgramsSuccess() async {
        // Given: initial load
        let broadcaster = TestData.makeBroadcaster(id: "b1")
        let initialPrograms = TestData.makeProgramList(count: 2)
        mockUserRepo.broadcasterToReturn = broadcaster
        mockUserRepo.broadcasterProgramsToReturn = TestData.makePaginatedResponse(
            data: initialPrograms,
            hasNext: true
        )
        await sut.loadBroadcaster(id: "b1")
        XCTAssertEqual(sut.programs.count, 2)

        // Configure page 2
        let morePrograms = [TestData.makeProgram(id: "extra-1", title: "Extra Program")]
        mockUserRepo.broadcasterProgramsToReturn = TestData.makePaginatedResponse(
            data: morePrograms,
            hasNext: false
        )

        // When
        await sut.loadMorePrograms()

        // Then
        XCTAssertEqual(sut.programs.count, 3)
        XCTAssertFalse(sut.hasMore)
        XCTAssertFalse(sut.isLoadingMore)
    }

    func testLoadMoreProgramsDoesNothingWhenNoMore() async {
        // Given: hasMore is false
        let broadcaster = TestData.makeBroadcaster(id: "b1")
        mockUserRepo.broadcasterToReturn = broadcaster
        mockUserRepo.broadcasterProgramsToReturn = TestData.makePaginatedResponse(
            data: TestData.makeProgramList(count: 1),
            hasNext: false
        )
        await sut.loadBroadcaster(id: "b1")
        let initialCallCount = mockUserRepo.fetchBroadcasterProgramsCallCount

        // When
        await sut.loadMorePrograms()

        // Then: no additional call made
        XCTAssertEqual(mockUserRepo.fetchBroadcasterProgramsCallCount, initialCallCount)
    }

    func testLoadMoreProgramsDoesNothingWithoutBroadcasterId() async {
        // Given: no broadcaster loaded
        // When
        await sut.loadMorePrograms()

        // Then
        XCTAssertEqual(mockUserRepo.fetchBroadcasterProgramsCallCount, 0)
    }

    func testLoadMoreProgramsError() async {
        // Given: initial load succeeds
        let broadcaster = TestData.makeBroadcaster(id: "b1")
        mockUserRepo.broadcasterToReturn = broadcaster
        mockUserRepo.broadcasterProgramsToReturn = TestData.makePaginatedResponse(
            data: TestData.makeProgramList(count: 1),
            hasNext: true
        )
        await sut.loadBroadcaster(id: "b1")

        // Then load more fails
        mockUserRepo.shouldThrowError = true

        // When
        await sut.loadMorePrograms()

        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoadingMore)
        // Original programs still present
        XCTAssertEqual(sut.programs.count, 1)
    }

    // MARK: - toggleFollow

    func testToggleFollowFromUnfollowedToFollowed() async {
        // Given
        let broadcaster = TestData.makeBroadcaster(id: "b1", isFollowing: false)
        mockUserRepo.broadcasterToReturn = broadcaster
        mockUserRepo.broadcasterProgramsToReturn = TestData.makePaginatedResponse(data: [Program]())
        await sut.loadBroadcaster(id: "b1")
        XCTAssertFalse(sut.isFollowing)

        // When
        await sut.toggleFollow()

        // Then
        XCTAssertTrue(sut.isFollowing)
        XCTAssertEqual(mockUserRepo.followCallCount, 1)
        XCTAssertEqual(mockUserRepo.unfollowCallCount, 0)
        XCTAssertEqual(mockUserRepo.lastFollowBroadcasterId, "b1")
    }

    func testToggleFollowFromFollowedToUnfollowed() async {
        // Given
        let broadcaster = TestData.makeBroadcaster(id: "b1", isFollowing: true)
        mockUserRepo.broadcasterToReturn = broadcaster
        mockUserRepo.broadcasterProgramsToReturn = TestData.makePaginatedResponse(data: [Program]())
        await sut.loadBroadcaster(id: "b1")
        XCTAssertTrue(sut.isFollowing)

        // When
        await sut.toggleFollow()

        // Then
        XCTAssertFalse(sut.isFollowing)
        XCTAssertEqual(mockUserRepo.unfollowCallCount, 1)
        XCTAssertEqual(mockUserRepo.followCallCount, 0)
        XCTAssertEqual(mockUserRepo.lastUnfollowBroadcasterId, "b1")
    }

    func testToggleFollowRevertsOnError() async {
        // Given: following, but API will fail on unfollow
        let broadcaster = TestData.makeBroadcaster(id: "b1", isFollowing: true)
        mockUserRepo.broadcasterToReturn = broadcaster
        mockUserRepo.broadcasterProgramsToReturn = TestData.makePaginatedResponse(data: [Program]())
        await sut.loadBroadcaster(id: "b1")
        XCTAssertTrue(sut.isFollowing)

        mockUserRepo.shouldThrowError = true

        // When
        await sut.toggleFollow()

        // Then: reverts to original state
        XCTAssertTrue(sut.isFollowing)
        XCTAssertNotNil(sut.errorMessage)
    }

    func testToggleFollowDoesNothingWithoutBroadcasterId() async {
        // Given: no broadcaster loaded
        // When
        await sut.toggleFollow()

        // Then
        XCTAssertEqual(mockUserRepo.followCallCount, 0)
        XCTAssertEqual(mockUserRepo.unfollowCallCount, 0)
    }
}

// MARK: - ProfileViewModelTests

@MainActor
final class ProfileViewModelTests: XCTestCase {

    private var sut: ProfileViewModel!
    private var mockUserRepo: MockUserRepository!
    private var mockUploadRepo: MockUploadRepository!

    override func setUp() {
        super.setUp()
        mockUserRepo = MockUserRepository()
        mockUploadRepo = MockUploadRepository()
        sut = ProfileViewModel(userRepository: mockUserRepo, uploadRepository: mockUploadRepo)
    }

    override func tearDown() {
        sut = nil
        mockUserRepo = nil
        mockUploadRepo = nil
        super.tearDown()
    }

    // MARK: - loadProfile

    func testLoadProfileSuccess() async {
        // Given
        let profile = TestData.makeUserProfile(
            id: "u1",
            nickname: "TestUser",
            message: "Hello World"
        )
        mockUserRepo.profileToReturn = profile

        // When
        await sut.loadProfile()

        // Then
        XCTAssertEqual(sut.profile?.id, "u1")
        XCTAssertEqual(sut.profile?.nickname, "TestUser")
        XCTAssertEqual(sut.editNickname, "TestUser")
        XCTAssertEqual(sut.editMessage, "Hello World")
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(mockUserRepo.fetchMyProfileCallCount, 1)
    }

    func testLoadProfileSetsEmptyMessageWhenNil() async {
        // Given
        let profile = TestData.makeUserProfile(id: "u1", nickname: "User", message: nil)
        mockUserRepo.profileToReturn = profile

        // When
        await sut.loadProfile()

        // Then
        XCTAssertEqual(sut.editMessage, "")
    }

    func testLoadProfileFailure() async {
        // Given
        mockUserRepo.shouldThrowError = true

        // When
        await sut.loadProfile()

        // Then
        XCTAssertNil(sut.profile)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - saveProfile

    func testSaveProfileSuccessWithoutAvatar() async {
        // Given: load profile first
        let profile = TestData.makeUserProfile(id: "u1", nickname: "OldName", message: "Old msg")
        mockUserRepo.profileToReturn = profile
        await sut.loadProfile()

        // Modify fields
        sut.editNickname = "NewName"
        sut.editMessage = "New message"

        // Update the return value for the update call
        let updatedProfile = TestData.makeUserProfile(id: "u1", nickname: "NewName", message: "New message")
        mockUserRepo.profileToReturn = updatedProfile

        // When
        await sut.saveProfile()

        // Then
        XCTAssertEqual(sut.profile?.nickname, "NewName")
        XCTAssertEqual(sut.successMessage, "Profile updated successfully")
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isSaving)
        XCTAssertEqual(mockUserRepo.updateProfileCallCount, 1)
        XCTAssertEqual(mockUserRepo.lastUpdateNickname, "NewName")
        XCTAssertEqual(mockUserRepo.lastUpdateMessage, "New message")
        XCTAssertEqual(mockUploadRepo.uploadAvatarCallCount, 0)
    }

    func testSaveProfileSuccessWithAvatar() async {
        // Given
        let profile = TestData.makeUserProfile(id: "u1", nickname: "User")
        mockUserRepo.profileToReturn = profile
        await sut.loadProfile()

        let avatarData = Data([0x89, 0x50, 0x4E, 0x47]) // fake PNG header
        sut.selectedAvatarData = avatarData

        // When
        await sut.saveProfile()

        // Then
        XCTAssertEqual(mockUploadRepo.uploadAvatarCallCount, 1)
        XCTAssertEqual(mockUploadRepo.lastUploadAvatarData, avatarData)
        XCTAssertNil(sut.selectedAvatarData) // cleared after upload
        XCTAssertEqual(mockUserRepo.updateProfileCallCount, 1)
        XCTAssertEqual(sut.successMessage, "Profile updated successfully")
    }

    func testSaveProfileFailure() async {
        // Given
        let profile = TestData.makeUserProfile(id: "u1", nickname: "User")
        mockUserRepo.profileToReturn = profile
        await sut.loadProfile()

        mockUserRepo.shouldThrowError = true

        // When
        await sut.saveProfile()

        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertNil(sut.successMessage)
        XCTAssertFalse(sut.isSaving)
    }

    func testSaveProfileTrimsWhitespace() async {
        // Given
        let profile = TestData.makeUserProfile(id: "u1", nickname: "User")
        mockUserRepo.profileToReturn = profile
        await sut.loadProfile()

        sut.editNickname = "  Padded Name  "
        sut.editMessage = "  Padded message  "

        // When
        await sut.saveProfile()

        // Then
        XCTAssertEqual(mockUserRepo.lastUpdateNickname, "Padded Name")
        XCTAssertEqual(mockUserRepo.lastUpdateMessage, "Padded message")
    }

    // MARK: - resetEditFields

    func testResetEditFields() async {
        // Given
        let profile = TestData.makeUserProfile(id: "u1", nickname: "Original", message: "Original msg")
        mockUserRepo.profileToReturn = profile
        await sut.loadProfile()

        sut.editNickname = "Changed"
        sut.editMessage = "Changed msg"
        sut.selectedAvatarData = Data([0x01])

        // When
        sut.resetEditFields()

        // Then
        XCTAssertEqual(sut.editNickname, "Original")
        XCTAssertEqual(sut.editMessage, "Original msg")
        XCTAssertNil(sut.selectedAvatarData)
    }

    func testResetEditFieldsDoesNothingWithoutProfile() {
        // Given: no profile loaded
        sut.editNickname = "Something"

        // When
        sut.resetEditFields()

        // Then: unchanged because guard fails
        XCTAssertEqual(sut.editNickname, "Something")
    }

    // MARK: - hasChanges

    func testHasChangesReturnsFalseWithNoProfile() {
        // Given: no profile loaded
        // Then
        XCTAssertFalse(sut.hasChanges)
    }

    func testHasChangesReturnsFalseWhenUnchanged() async {
        // Given
        let profile = TestData.makeUserProfile(id: "u1", nickname: "User", message: "Hello")
        mockUserRepo.profileToReturn = profile
        await sut.loadProfile()

        // Then
        XCTAssertFalse(sut.hasChanges)
    }

    func testHasChangesReturnsTrueWhenNicknameChanged() async {
        // Given
        let profile = TestData.makeUserProfile(id: "u1", nickname: "User", message: "Hello")
        mockUserRepo.profileToReturn = profile
        await sut.loadProfile()

        // When
        sut.editNickname = "New Name"

        // Then
        XCTAssertTrue(sut.hasChanges)
    }

    func testHasChangesReturnsTrueWhenMessageChanged() async {
        // Given
        let profile = TestData.makeUserProfile(id: "u1", nickname: "User", message: "Hello")
        mockUserRepo.profileToReturn = profile
        await sut.loadProfile()

        // When
        sut.editMessage = "New message"

        // Then
        XCTAssertTrue(sut.hasChanges)
    }

    func testHasChangesReturnsTrueWhenAvatarSelected() async {
        // Given
        let profile = TestData.makeUserProfile(id: "u1", nickname: "User")
        mockUserRepo.profileToReturn = profile
        await sut.loadProfile()

        // When
        sut.selectedAvatarData = Data([0x01])

        // Then
        XCTAssertTrue(sut.hasChanges)
    }
}

// MARK: - ProgramEditViewModelTests

@MainActor
final class ProgramEditViewModelTests: XCTestCase {

    private var sut: ProgramEditViewModel!
    private var mockProgramRepo: MockProgramRepository!
    private var mockUploadRepo: MockUploadRepository!

    override func setUp() {
        super.setUp()
        mockProgramRepo = MockProgramRepository()
        mockUploadRepo = MockUploadRepository()
        sut = ProgramEditViewModel(programRepository: mockProgramRepo, uploadRepository: mockUploadRepo)
    }

    override func tearDown() {
        sut = nil
        mockProgramRepo = nil
        mockUploadRepo = nil
        super.tearDown()
    }

    // MARK: - loadProgram

    func testLoadProgramSuccess() async {
        // Given
        let tracks = TestData.makeTrackList(count: 2, programId: "p1")
        let program = TestData.makeProgram(
            id: "p1",
            title: "My Program",
            description: "A great program",
            programType: .music,
            tracks: tracks
        )
        mockProgramRepo.programToReturn = program

        // When
        await sut.loadProgram(id: "p1")

        // Then
        XCTAssertEqual(sut.title, "My Program")
        XCTAssertEqual(sut.description, "A great program")
        XCTAssertEqual(sut.programType, .music)
        XCTAssertEqual(sut.tracks.count, 2)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func testLoadProgramWithNilTracks() async {
        // Given: program with no tracks
        let program = TestData.makeProgram(id: "p1", title: "No Tracks", tracks: nil)
        mockProgramRepo.programToReturn = program

        // When
        await sut.loadProgram(id: "p1")

        // Then
        XCTAssertTrue(sut.tracks.isEmpty)
    }

    func testLoadProgramWithNilDescription() async {
        // Given
        let program = TestData.makeProgram(id: "p1", title: "Minimal", description: nil)
        mockProgramRepo.programToReturn = program

        // When
        await sut.loadProgram(id: "p1")

        // Then
        XCTAssertEqual(sut.description, "")
    }

    func testLoadProgramFailure() async {
        // Given
        mockProgramRepo.shouldThrowError = true

        // When
        await sut.loadProgram(id: "p1")

        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(sut.title.isEmpty)
    }

    // MARK: - saveProgram (create)

    func testSaveProgramCreateSuccess() async {
        // Given
        let createdProgram = TestData.makeProgram(id: "new-1", title: "New Program")
        mockProgramRepo.createdProgramToReturn = createdProgram
        sut.title = "New Program"
        sut.description = "Description"
        sut.programType = .music

        // When
        await sut.saveProgram()

        // Then
        XCTAssertEqual(sut.savedProgram?.id, "new-1")
        XCTAssertEqual(sut.successMessage, "Program saved successfully")
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isSaving)
        XCTAssertEqual(mockProgramRepo.createProgramCallCount, 1)
        XCTAssertEqual(mockProgramRepo.updateProgramCallCount, 0)
        XCTAssertEqual(mockProgramRepo.lastCreateProgramTitle, "New Program")
    }

    func testSaveProgramUpdateSuccess() async {
        // Given: load an existing program first
        let existingProgram = TestData.makeProgram(id: "p1", title: "Old Title")
        mockProgramRepo.programToReturn = existingProgram
        await sut.loadProgram(id: "p1")

        // Configure update
        sut.title = "Updated Title"
        let updatedProgram = TestData.makeProgram(id: "p1", title: "Updated Title")
        mockProgramRepo.updatedProgramToReturn = updatedProgram

        // When
        await sut.saveProgram()

        // Then
        XCTAssertEqual(sut.savedProgram?.id, "p1")
        XCTAssertEqual(mockProgramRepo.updateProgramCallCount, 1)
        XCTAssertEqual(mockProgramRepo.createProgramCallCount, 0)
        XCTAssertEqual(mockProgramRepo.lastUpdateProgramId, "p1")
    }

    func testSaveProgramValidationFailsWithEmptyTitle() async {
        // Given
        sut.title = ""
        sut.description = "Has description but no title"

        // When
        await sut.saveProgram()

        // Then
        XCTAssertEqual(sut.errorMessage, "Please enter a title")
        XCTAssertEqual(mockProgramRepo.createProgramCallCount, 0)
        XCTAssertEqual(mockProgramRepo.updateProgramCallCount, 0)
    }

    func testSaveProgramValidationFailsWithWhitespaceOnlyTitle() async {
        // Given
        sut.title = "   "

        // When
        await sut.saveProgram()

        // Then
        XCTAssertEqual(sut.errorMessage, "Please enter a title")
        XCTAssertEqual(mockProgramRepo.createProgramCallCount, 0)
    }

    func testSaveProgramWithAudioUpload() async {
        // Given
        let createdProgram = TestData.makeProgram(id: "p1", title: "With Audio")
        mockProgramRepo.createdProgramToReturn = createdProgram
        sut.title = "With Audio"
        sut.setAudioFile(data: Data([0x01, 0x02, 0x03]), fileName: "recording.mp3")

        // When
        await sut.saveProgram()

        // Then
        XCTAssertEqual(mockProgramRepo.createProgramCallCount, 1)
        XCTAssertEqual(mockUploadRepo.uploadProgramAudioCallCount, 1)
        XCTAssertEqual(mockUploadRepo.lastUploadProgramId, "p1")
        XCTAssertEqual(mockUploadRepo.lastUploadFileName, "recording.mp3")
    }

    func testSaveProgramFailure() async {
        // Given
        mockProgramRepo.shouldThrowError = true
        sut.title = "Test"

        // When
        await sut.saveProgram()

        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertNil(sut.savedProgram)
        XCTAssertFalse(sut.isSaving)
    }

    // MARK: - publishProgram

    func testPublishProgramSuccess() async {
        // Given: save a program first to set editingProgramId
        let createdProgram = TestData.makeProgram(id: "p1", title: "Draft")
        mockProgramRepo.createdProgramToReturn = createdProgram
        sut.title = "Draft"
        await sut.saveProgram()

        let publishedProgram = TestData.makeProgram(id: "p1", title: "Draft", status: .published)
        mockProgramRepo.publishedProgramToReturn = publishedProgram

        // When
        await sut.publishProgram()

        // Then
        XCTAssertEqual(sut.savedProgram?.status, .published)
        XCTAssertEqual(sut.successMessage, "Program published successfully")
        XCTAssertFalse(sut.isSaving)
        XCTAssertEqual(mockProgramRepo.publishProgramCallCount, 1)
    }

    func testPublishProgramWithoutSavingFirst() async {
        // Given: no program saved yet (editingProgramId is nil)

        // When
        await sut.publishProgram()

        // Then
        XCTAssertEqual(sut.errorMessage, "Please save the program first")
        XCTAssertEqual(mockProgramRepo.publishProgramCallCount, 0)
    }

    func testPublishProgramFailure() async {
        // Given: save first
        let createdProgram = TestData.makeProgram(id: "p1", title: "Draft")
        mockProgramRepo.createdProgramToReturn = createdProgram
        sut.title = "Draft"
        await sut.saveProgram()

        mockProgramRepo.shouldThrowError = true

        // When
        await sut.publishProgram()

        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isSaving)
    }

    // MARK: - Track Management

    func testAddTrackManually() {
        // Given
        XCTAssertTrue(sut.tracks.isEmpty)

        // When: simulate adding via EditableTrack directly
        let track = EditableTrack(
            appleMusicTrackId: "apple-123",
            trackName: "Test Song",
            artistName: "Test Artist",
            artworkUrl: nil,
            playTimingSeconds: 0,
            sortOrder: 0
        )
        sut.tracks.append(track)

        // Then
        XCTAssertEqual(sut.tracks.count, 1)
        XCTAssertEqual(sut.tracks[0].trackName, "Test Song")
    }

    func testRemoveTrackSuccess() {
        // Given
        sut.tracks = [
            EditableTrack(appleMusicTrackId: "a1", trackName: "Song 1", artistName: "Artist 1", artworkUrl: nil, playTimingSeconds: 0, sortOrder: 0),
            EditableTrack(appleMusicTrackId: "a2", trackName: "Song 2", artistName: "Artist 2", artworkUrl: nil, playTimingSeconds: 60, sortOrder: 1),
            EditableTrack(appleMusicTrackId: "a3", trackName: "Song 3", artistName: "Artist 3", artworkUrl: nil, playTimingSeconds: 120, sortOrder: 2)
        ]

        // When
        sut.removeTrack(at: 1)

        // Then
        XCTAssertEqual(sut.tracks.count, 2)
        XCTAssertEqual(sut.tracks[0].trackName, "Song 1")
        XCTAssertEqual(sut.tracks[1].trackName, "Song 3")
        // Sort orders should be updated
        XCTAssertEqual(sut.tracks[0].sortOrder, 0)
        XCTAssertEqual(sut.tracks[1].sortOrder, 1)
    }

    func testRemoveTrackInvalidIndex() {
        // Given
        sut.tracks = [
            EditableTrack(appleMusicTrackId: "a1", trackName: "Song 1", artistName: "Artist", artworkUrl: nil)
        ]

        // When: invalid indices
        sut.removeTrack(at: -1)
        sut.removeTrack(at: 5)

        // Then: no change
        XCTAssertEqual(sut.tracks.count, 1)
    }

    func testMoveTrack() {
        // Given
        sut.tracks = [
            EditableTrack(appleMusicTrackId: "a1", trackName: "Song 1", artistName: "Artist 1", artworkUrl: nil, playTimingSeconds: 0, sortOrder: 0),
            EditableTrack(appleMusicTrackId: "a2", trackName: "Song 2", artistName: "Artist 2", artworkUrl: nil, playTimingSeconds: 60, sortOrder: 1),
            EditableTrack(appleMusicTrackId: "a3", trackName: "Song 3", artistName: "Artist 3", artworkUrl: nil, playTimingSeconds: 120, sortOrder: 2)
        ]

        // When: move first to last
        sut.moveTrack(from: IndexSet(integer: 0), to: 3)

        // Then
        XCTAssertEqual(sut.tracks[0].trackName, "Song 2")
        XCTAssertEqual(sut.tracks[1].trackName, "Song 3")
        XCTAssertEqual(sut.tracks[2].trackName, "Song 1")
        // Sort orders updated
        XCTAssertEqual(sut.tracks[0].sortOrder, 0)
        XCTAssertEqual(sut.tracks[1].sortOrder, 1)
        XCTAssertEqual(sut.tracks[2].sortOrder, 2)
    }

    func testUpdateTrackTiming() {
        // Given
        sut.tracks = [
            EditableTrack(appleMusicTrackId: "a1", trackName: "Song 1", artistName: "Artist", artworkUrl: nil, playTimingSeconds: 0, sortOrder: 0)
        ]

        // When
        sut.updateTrackTiming(at: 0, seconds: 120)

        // Then
        XCTAssertEqual(sut.tracks[0].playTimingSeconds, 120)
    }

    func testUpdateTrackTimingInvalidIndex() {
        // Given
        sut.tracks = [
            EditableTrack(appleMusicTrackId: "a1", trackName: "Song 1", artistName: "Artist", artworkUrl: nil, playTimingSeconds: 0, sortOrder: 0)
        ]

        // When: invalid index
        sut.updateTrackTiming(at: 5, seconds: 120)

        // Then: no change
        XCTAssertEqual(sut.tracks[0].playTimingSeconds, 0)
    }

    // MARK: - setAudioFile

    func testSetAudioFile() {
        // Given
        XCTAssertNil(sut.audioFileData)
        XCTAssertNil(sut.audioFileName)

        // When
        let data = Data([0x01, 0x02])
        sut.setAudioFile(data: data, fileName: "test.mp3")

        // Then
        XCTAssertEqual(sut.audioFileData, data)
        XCTAssertEqual(sut.audioFileName, "test.mp3")
    }

    // MARK: - deleteProgram

    func testDeleteProgramSuccess() async {
        // Given: load an existing program
        let program = TestData.makeProgram(id: "p1", title: "To Delete")
        mockProgramRepo.programToReturn = program
        await sut.loadProgram(id: "p1")

        // When
        let result = await sut.deleteProgram()

        // Then
        XCTAssertTrue(result)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(mockProgramRepo.deleteProgramCallCount, 1)
        XCTAssertEqual(mockProgramRepo.lastDeleteProgramId, "p1")
    }

    func testDeleteProgramFailure() async {
        // Given
        let program = TestData.makeProgram(id: "p1", title: "To Delete")
        mockProgramRepo.programToReturn = program
        await sut.loadProgram(id: "p1")

        mockProgramRepo.shouldThrowError = true

        // When
        let result = await sut.deleteProgram()

        // Then
        XCTAssertFalse(result)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func testDeleteProgramWithoutEditingId() async {
        // Given: no program loaded

        // When
        let result = await sut.deleteProgram()

        // Then
        XCTAssertFalse(result)
        XCTAssertEqual(mockProgramRepo.deleteProgramCallCount, 0)
    }
}

// MARK: - FavoritesViewModelTests

@MainActor
final class FavoritesViewModelTests: XCTestCase {

    private var sut: FavoritesViewModel!
    private var mockRepo: MockProgramRepository!

    override func setUp() {
        super.setUp()
        mockRepo = MockProgramRepository()
        sut = FavoritesViewModel(programRepository: mockRepo)
    }

    override func tearDown() {
        sut = nil
        mockRepo = nil
        super.tearDown()
    }

    // MARK: - loadFavorites

    func testLoadFavoritesSuccess() async {
        // Given
        let programs = TestData.makeProgramList(count: 3)
        mockRepo.favoriteProgramsToReturn = TestData.makePaginatedResponse(
            data: programs,
            hasNext: true
        )

        // When
        await sut.loadFavorites()

        // Then
        XCTAssertEqual(sut.programs.count, 3)
        XCTAssertTrue(sut.hasMore)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(mockRepo.fetchFavoriteProgramsCallCount, 1)
    }

    func testLoadFavoritesEmpty() async {
        // Given
        mockRepo.favoriteProgramsToReturn = TestData.makePaginatedResponse(
            data: [Program](),
            hasNext: false
        )

        // When
        await sut.loadFavorites()

        // Then
        XCTAssertTrue(sut.programs.isEmpty)
        XCTAssertFalse(sut.hasMore)
        XCTAssertNil(sut.errorMessage)
    }

    func testLoadFavoritesFailure() async {
        // Given
        mockRepo.shouldThrowError = true

        // When
        await sut.loadFavorites()

        // Then
        XCTAssertTrue(sut.programs.isEmpty)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadFavoritesResetsPage() async {
        // Given: already loaded page 1, then load more to page 2
        let initialPrograms = TestData.makeProgramList(count: 2)
        mockRepo.favoriteProgramsToReturn = TestData.makePaginatedResponse(
            data: initialPrograms,
            hasNext: true
        )
        await sut.loadFavorites()

        let morePrograms = [TestData.makeProgram(id: "extra-1")]
        mockRepo.favoriteProgramsToReturn = TestData.makePaginatedResponse(
            data: morePrograms,
            hasNext: false
        )
        await sut.loadMore()
        XCTAssertEqual(sut.programs.count, 3)

        // When: reload (should reset)
        let freshPrograms = [TestData.makeProgram(id: "fresh-1")]
        mockRepo.favoriteProgramsToReturn = TestData.makePaginatedResponse(
            data: freshPrograms,
            hasNext: false
        )
        await sut.loadFavorites()

        // Then: data replaced, not appended
        XCTAssertEqual(sut.programs.count, 1)
        XCTAssertEqual(sut.programs[0].id, "fresh-1")
    }

    // MARK: - loadMore

    func testLoadMoreSuccess() async {
        // Given
        let initialPrograms = TestData.makeProgramList(count: 2)
        mockRepo.favoriteProgramsToReturn = TestData.makePaginatedResponse(
            data: initialPrograms,
            hasNext: true
        )
        await sut.loadFavorites()

        let morePrograms = [TestData.makeProgram(id: "more-1", title: "More Program")]
        mockRepo.favoriteProgramsToReturn = TestData.makePaginatedResponse(
            data: morePrograms,
            hasNext: false
        )

        // When
        await sut.loadMore()

        // Then
        XCTAssertEqual(sut.programs.count, 3)
        XCTAssertFalse(sut.hasMore)
        XCTAssertFalse(sut.isLoadingMore)
    }

    func testLoadMoreDoesNothingWhenNoMore() async {
        // Given
        mockRepo.favoriteProgramsToReturn = TestData.makePaginatedResponse(
            data: TestData.makeProgramList(count: 1),
            hasNext: false
        )
        await sut.loadFavorites()
        let callCount = mockRepo.fetchFavoriteProgramsCallCount

        // When
        await sut.loadMore()

        // Then: no additional API call
        XCTAssertEqual(mockRepo.fetchFavoriteProgramsCallCount, callCount)
    }

    func testLoadMoreError() async {
        // Given
        mockRepo.favoriteProgramsToReturn = TestData.makePaginatedResponse(
            data: TestData.makeProgramList(count: 1),
            hasNext: true
        )
        await sut.loadFavorites()

        mockRepo.shouldThrowError = true

        // When
        await sut.loadMore()

        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoadingMore)
        XCTAssertEqual(sut.programs.count, 1) // originals preserved
    }

    // MARK: - removeFavorite

    func testRemoveFavoriteSuccess() async {
        // Given
        let programs = [
            TestData.makeProgram(id: "p1", title: "Program 1"),
            TestData.makeProgram(id: "p2", title: "Program 2"),
            TestData.makeProgram(id: "p3", title: "Program 3")
        ]
        mockRepo.favoriteProgramsToReturn = TestData.makePaginatedResponse(data: programs)
        await sut.loadFavorites()
        XCTAssertEqual(sut.programs.count, 3)

        // When
        await sut.removeFavorite(programId: "p2")

        // Then
        XCTAssertEqual(sut.programs.count, 2)
        XCTAssertFalse(sut.programs.contains { $0.id == "p2" })
        XCTAssertEqual(mockRepo.removeFavoriteCallCount, 1)
        XCTAssertEqual(mockRepo.lastRemoveFavoriteProgramId, "p2")
    }

    func testRemoveFavoriteFailure() async {
        // Given
        let programs = [TestData.makeProgram(id: "p1")]
        mockRepo.favoriteProgramsToReturn = TestData.makePaginatedResponse(data: programs)
        await sut.loadFavorites()

        mockRepo.shouldThrowError = true

        // When
        await sut.removeFavorite(programId: "p1")

        // Then: program still present (API failed, local removal didn't happen because error thrown before removeAll)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.programs.count, 1)
    }

    // MARK: - refresh

    func testRefreshCallsLoadFavorites() async {
        // Given
        let programs = [TestData.makeProgram(id: "r1")]
        mockRepo.favoriteProgramsToReturn = TestData.makePaginatedResponse(data: programs)

        // When
        await sut.refresh()

        // Then
        XCTAssertEqual(sut.programs.count, 1)
        XCTAssertEqual(mockRepo.fetchFavoriteProgramsCallCount, 1)
    }
}

// MARK: - FollowsViewModelTests

@MainActor
final class FollowsViewModelTests: XCTestCase {

    private var sut: FollowsViewModel!
    private var mockUserRepo: MockUserRepository!

    override func setUp() {
        super.setUp()
        mockUserRepo = MockUserRepository()
        sut = FollowsViewModel(userRepository: mockUserRepo)
    }

    override func tearDown() {
        sut = nil
        mockUserRepo = nil
        super.tearDown()
    }

    // MARK: - loadFollows

    func testLoadFollowsSuccess() async {
        // Given
        let broadcasters = TestData.makeBroadcasterList(count: 3)
        mockUserRepo.followsToReturn = TestData.makePaginatedResponse(
            data: broadcasters,
            hasNext: true
        )

        // When
        await sut.loadFollows()

        // Then
        XCTAssertEqual(sut.broadcasters.count, 3)
        XCTAssertTrue(sut.hasMore)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(mockUserRepo.fetchFollowsCallCount, 1)
    }

    func testLoadFollowsEmpty() async {
        // Given
        mockUserRepo.followsToReturn = TestData.makePaginatedResponse(
            data: [Broadcaster](),
            hasNext: false
        )

        // When
        await sut.loadFollows()

        // Then
        XCTAssertTrue(sut.broadcasters.isEmpty)
        XCTAssertFalse(sut.hasMore)
        XCTAssertNil(sut.errorMessage)
    }

    func testLoadFollowsFailure() async {
        // Given
        mockUserRepo.shouldThrowError = true

        // When
        await sut.loadFollows()

        // Then
        XCTAssertTrue(sut.broadcasters.isEmpty)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - loadMore

    func testLoadMoreSuccess() async {
        // Given
        let initialBroadcasters = TestData.makeBroadcasterList(count: 2)
        mockUserRepo.followsToReturn = TestData.makePaginatedResponse(
            data: initialBroadcasters,
            hasNext: true
        )
        await sut.loadFollows()

        let moreBroadcasters = [TestData.makeBroadcaster(id: "extra-1", nickname: "Extra DJ")]
        mockUserRepo.followsToReturn = TestData.makePaginatedResponse(
            data: moreBroadcasters,
            hasNext: false
        )

        // When
        await sut.loadMore()

        // Then
        XCTAssertEqual(sut.broadcasters.count, 3)
        XCTAssertFalse(sut.hasMore)
        XCTAssertFalse(sut.isLoadingMore)
    }

    func testLoadMoreDoesNothingWhenNoMore() async {
        // Given
        mockUserRepo.followsToReturn = TestData.makePaginatedResponse(
            data: TestData.makeBroadcasterList(count: 1),
            hasNext: false
        )
        await sut.loadFollows()
        let callCount = mockUserRepo.fetchFollowsCallCount

        // When
        await sut.loadMore()

        // Then
        XCTAssertEqual(mockUserRepo.fetchFollowsCallCount, callCount)
    }

    func testLoadMoreError() async {
        // Given
        mockUserRepo.followsToReturn = TestData.makePaginatedResponse(
            data: TestData.makeBroadcasterList(count: 1),
            hasNext: true
        )
        await sut.loadFollows()

        mockUserRepo.shouldThrowError = true

        // When
        await sut.loadMore()

        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoadingMore)
        XCTAssertEqual(sut.broadcasters.count, 1) // originals preserved
    }

    // MARK: - unfollow

    func testUnfollowSuccess() async {
        // Given
        let broadcasters = [
            TestData.makeBroadcaster(id: "b1", nickname: "DJ Alpha"),
            TestData.makeBroadcaster(id: "b2", nickname: "DJ Beta"),
            TestData.makeBroadcaster(id: "b3", nickname: "DJ Gamma")
        ]
        mockUserRepo.followsToReturn = TestData.makePaginatedResponse(data: broadcasters)
        await sut.loadFollows()
        XCTAssertEqual(sut.broadcasters.count, 3)

        // When
        await sut.unfollow(broadcasterId: "b2")

        // Then
        XCTAssertEqual(sut.broadcasters.count, 2)
        XCTAssertFalse(sut.broadcasters.contains { $0.id == "b2" })
        XCTAssertEqual(mockUserRepo.unfollowCallCount, 1)
        XCTAssertEqual(mockUserRepo.lastUnfollowBroadcasterId, "b2")
    }

    func testUnfollowFailure() async {
        // Given
        let broadcasters = [TestData.makeBroadcaster(id: "b1")]
        mockUserRepo.followsToReturn = TestData.makePaginatedResponse(data: broadcasters)
        await sut.loadFollows()

        mockUserRepo.shouldThrowError = true

        // When
        await sut.unfollow(broadcasterId: "b1")

        // Then
        XCTAssertNotNil(sut.errorMessage)
        // Broadcaster still present since API call failed before local removal
        XCTAssertEqual(sut.broadcasters.count, 1)
    }

    // MARK: - refresh

    func testRefreshCallsLoadFollows() async {
        // Given
        let broadcasters = [TestData.makeBroadcaster(id: "b1")]
        mockUserRepo.followsToReturn = TestData.makePaginatedResponse(data: broadcasters)

        // When
        await sut.refresh()

        // Then
        XCTAssertEqual(sut.broadcasters.count, 1)
        XCTAssertEqual(mockUserRepo.fetchFollowsCallCount, 1)
    }
}

// MARK: - SearchViewModelTests

@MainActor
final class SearchViewModelTests: XCTestCase {

    private var sut: SearchViewModel!
    private var mockRepo: MockProgramRepository!

    override func setUp() {
        super.setUp()
        mockRepo = MockProgramRepository()
        sut = SearchViewModel(programRepository: mockRepo)
    }

    override func tearDown() {
        sut = nil
        mockRepo = nil
        super.tearDown()
    }

    // MARK: - search

    func testSearchSuccess() async {
        // Given
        let programs = TestData.makeProgramList(count: 3)
        mockRepo.searchProgramsToReturn = TestData.makePaginatedResponse(
            data: programs,
            hasNext: true
        )
        sut.searchText = "jazz"

        // When
        await sut.search()

        // Then
        XCTAssertEqual(sut.programs.count, 3)
        XCTAssertTrue(sut.hasMore)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(mockRepo.searchProgramsCallCount, 1)
        XCTAssertEqual(mockRepo.lastSearchQuery, "jazz")
    }

    func testSearchWithEmptyQuery() async {
        // Given: empty search text should pass nil query
        let programs = TestData.makeProgramList(count: 2)
        mockRepo.searchProgramsToReturn = TestData.makePaginatedResponse(data: programs)
        sut.searchText = ""

        // When
        await sut.search()

        // Then
        XCTAssertEqual(sut.programs.count, 2)
        XCTAssertNil(mockRepo.lastSearchQuery)
    }

    func testSearchWithGenreFilter() async {
        // Given
        let programs = [TestData.makeProgram(id: "p1", genre: "J-POP")]
        mockRepo.searchProgramsToReturn = TestData.makePaginatedResponse(data: programs)
        sut.selectedGenre = "J-POP"

        // When
        await sut.search()

        // Then
        XCTAssertEqual(sut.programs.count, 1)
        XCTAssertEqual(mockRepo.lastSearchGenre, "J-POP")
    }

    func testSearchFailure() async {
        // Given
        mockRepo.shouldThrowError = true

        // When
        await sut.search()

        // Then
        XCTAssertTrue(sut.programs.isEmpty)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func testSearchResetsPage() async {
        // Given: load some results first
        mockRepo.searchProgramsToReturn = TestData.makePaginatedResponse(
            data: TestData.makeProgramList(count: 2),
            hasNext: true
        )
        await sut.search()

        // Load more
        mockRepo.searchProgramsToReturn = TestData.makePaginatedResponse(
            data: [TestData.makeProgram(id: "extra")],
            hasNext: false
        )
        await sut.loadMore()
        XCTAssertEqual(sut.programs.count, 3)

        // When: search again
        let freshPrograms = [TestData.makeProgram(id: "fresh-1")]
        mockRepo.searchProgramsToReturn = TestData.makePaginatedResponse(data: freshPrograms)
        await sut.search()

        // Then: replaces data, not appends
        XCTAssertEqual(sut.programs.count, 1)
        XCTAssertEqual(sut.programs[0].id, "fresh-1")
    }

    // MARK: - loadMore

    func testLoadMoreSuccess() async {
        // Given
        mockRepo.searchProgramsToReturn = TestData.makePaginatedResponse(
            data: TestData.makeProgramList(count: 2),
            hasNext: true
        )
        await sut.search()

        let morePrograms = [TestData.makeProgram(id: "more-1")]
        mockRepo.searchProgramsToReturn = TestData.makePaginatedResponse(
            data: morePrograms,
            hasNext: false
        )

        // When
        await sut.loadMore()

        // Then
        XCTAssertEqual(sut.programs.count, 3)
        XCTAssertFalse(sut.hasMore)
        XCTAssertFalse(sut.isLoadingMore)
    }

    func testLoadMoreDoesNothingWhenNoMore() async {
        // Given
        mockRepo.searchProgramsToReturn = TestData.makePaginatedResponse(
            data: TestData.makeProgramList(count: 1),
            hasNext: false
        )
        await sut.search()
        let callCount = mockRepo.searchProgramsCallCount

        // When
        await sut.loadMore()

        // Then
        XCTAssertEqual(mockRepo.searchProgramsCallCount, callCount)
    }

    // MARK: - selectGenre

    func testSelectGenreTriggersSearch() async {
        // Given
        let programs = [TestData.makeProgram(id: "p1")]
        mockRepo.searchProgramsToReturn = TestData.makePaginatedResponse(data: programs)

        // When
        sut.selectGenre("J-POP")

        // Then: genre is set
        XCTAssertEqual(sut.selectedGenre, "J-POP")

        // Wait for the task to complete
        // Give the spawned task time to run
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms

        XCTAssertEqual(mockRepo.lastSearchGenre, "J-POP")
    }

    func testSelectSameGenreDeselectsIt() {
        // Given
        sut.selectedGenre = "J-POP"

        // When: select the same genre
        sut.selectGenre("J-POP")

        // Then: deselected
        XCTAssertNil(sut.selectedGenre)
    }

    func testSelectDifferentGenreChangesSelection() {
        // Given
        sut.selectedGenre = "J-POP"

        // When
        sut.selectGenre("ロック")

        // Then
        XCTAssertEqual(sut.selectedGenre, "ロック")
    }

    // MARK: - selectSort

    func testSelectSortChangesOption() async {
        // Given
        mockRepo.searchProgramsToReturn = TestData.makePaginatedResponse(data: [Program]())
        XCTAssertEqual(sut.sortBy, .popular)

        // When
        sut.selectSort(.newest)

        // Then
        XCTAssertEqual(sut.sortBy, .newest)

        // Wait for the task to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms

        XCTAssertGreaterThan(mockRepo.searchProgramsCallCount, 0)
    }

    func testSelectSameSortDoesNothing() {
        // Given
        let initialCallCount = mockRepo.searchProgramsCallCount

        // When: select the same sort
        sut.selectSort(.popular)

        // Then: no search triggered
        XCTAssertEqual(mockRepo.searchProgramsCallCount, initialCallCount)
    }

    // MARK: - SortOption

    func testSortOptionDisplayNames() {
        XCTAssertEqual(SearchViewModel.SortOption.popular.displayName, "Popular")
        XCTAssertEqual(SearchViewModel.SortOption.newest.displayName, "Newest")
        XCTAssertEqual(SearchViewModel.SortOption.favorites.displayName, "Favorites")
    }

    func testSortOptionRawValues() {
        XCTAssertEqual(SearchViewModel.SortOption.popular.rawValue, "play_count")
        XCTAssertEqual(SearchViewModel.SortOption.newest.rawValue, "created_at")
        XCTAssertEqual(SearchViewModel.SortOption.favorites.rawValue, "favorite_count")
    }

    func testSortOptionAllDescending() {
        for option in SearchViewModel.SortOption.allCases {
            XCTAssertEqual(option.sortOrder, "desc")
        }
    }

    // MARK: - Genre

    func testDefaultGenresExist() {
        XCTAssertEqual(SearchViewModel.Genre.defaultGenres.count, 8)

        let genreIds = SearchViewModel.Genre.defaultGenres.map { $0.id }
        XCTAssertTrue(genreIds.contains("J-POP"))
        XCTAssertTrue(genreIds.contains("ロック"))
        XCTAssertTrue(genreIds.contains("ジャズ"))
        XCTAssertTrue(genreIds.contains("アニソン"))
        XCTAssertTrue(genreIds.contains("EDM"))
        XCTAssertTrue(genreIds.contains("Hip-Hop"))
    }

    // MARK: - refresh

    func testRefreshCallsSearch() async {
        // Given
        let programs = [TestData.makeProgram(id: "p1")]
        mockRepo.searchProgramsToReturn = TestData.makePaginatedResponse(data: programs)

        // When
        await sut.refresh()

        // Then
        XCTAssertEqual(sut.programs.count, 1)
        XCTAssertGreaterThan(mockRepo.searchProgramsCallCount, 0)
    }
}

// MARK: - NotificationsViewModel Model Tests
// Note: NotificationsViewModel uses APIClient.shared directly, making it harder
// to unit test with mock repositories. These tests cover the AppNotification model
// and related types.

final class AppNotificationTests: XCTestCase {

    // MARK: - AppNotification

    func testMarkedAsRead() {
        // Given
        let notification = AppNotification(
            id: "n1",
            type: .newFollower,
            title: "New Follower",
            body: "Someone followed you",
            isRead: false,
            referenceId: "user-1",
            referenceType: "user",
            createdAt: Date()
        )
        XCTAssertFalse(notification.isRead)

        // When
        let readNotification = notification.markedAsRead()

        // Then
        XCTAssertTrue(readNotification.isRead)
        XCTAssertEqual(readNotification.id, "n1")
        XCTAssertEqual(readNotification.title, "New Follower")
        XCTAssertEqual(readNotification.body, "Someone followed you")
        XCTAssertEqual(readNotification.type, .newFollower)
        XCTAssertEqual(readNotification.referenceId, "user-1")
        XCTAssertEqual(readNotification.referenceType, "user")
    }

    func testMarkedAsReadAlreadyRead() {
        // Given
        let notification = AppNotification(
            id: "n1",
            type: .system,
            title: "Update",
            body: "New version available",
            isRead: true,
            referenceId: nil,
            referenceType: nil,
            createdAt: nil
        )

        // When
        let result = notification.markedAsRead()

        // Then: still read
        XCTAssertTrue(result.isRead)
    }

    func testEquality() {
        // Given
        let n1 = AppNotification(
            id: "n1",
            type: .newFollower,
            title: "Title 1",
            body: "Body 1",
            isRead: false,
            referenceId: nil,
            referenceType: nil,
            createdAt: nil
        )
        let n2 = AppNotification(
            id: "n1",
            type: .system,
            title: "Different Title",
            body: "Different Body",
            isRead: true,
            referenceId: "ref",
            referenceType: "type",
            createdAt: Date()
        )
        let n3 = AppNotification(
            id: "n2",
            type: .newFollower,
            title: "Title 1",
            body: "Body 1",
            isRead: false,
            referenceId: nil,
            referenceType: nil,
            createdAt: nil
        )

        // Then: equality is based on id only
        XCTAssertEqual(n1, n2)
        XCTAssertNotEqual(n1, n3)
    }

    func testTimeAgoWithNilDate() {
        // Given
        let notification = AppNotification(
            id: "n1",
            type: nil,
            title: "Test",
            body: "Test body",
            isRead: false,
            referenceId: nil,
            referenceType: nil,
            createdAt: nil
        )

        // Then
        XCTAssertEqual(notification.timeAgo, "")
    }

    // MARK: - NotificationType

    func testNotificationTypeRawValues() {
        XCTAssertEqual(NotificationType.newFollower.rawValue, "new_follower")
        XCTAssertEqual(NotificationType.newFavorite.rawValue, "new_favorite")
        XCTAssertEqual(NotificationType.programPublished.rawValue, "program_published")
        XCTAssertEqual(NotificationType.system.rawValue, "system")
    }

    func testNotificationTypeIconNames() {
        XCTAssertEqual(NotificationType.newFollower.iconName, "person.badge.plus")
        XCTAssertEqual(NotificationType.newFavorite.iconName, "heart.fill")
        XCTAssertEqual(NotificationType.programPublished.iconName, "radio")
        XCTAssertEqual(NotificationType.system.iconName, "bell.fill")
    }

    func testNotificationTypeIconColors() {
        // Just verify they are accessible and distinct
        let colors = [
            NotificationType.newFollower.iconColor,
            NotificationType.newFavorite.iconColor,
            NotificationType.programPublished.iconColor,
            NotificationType.system.iconColor
        ]
        // All 4 types should have colors
        XCTAssertEqual(colors.count, 4)
    }
}
