import Foundation

@MainActor
final class TopViewModel: ObservableObject {
    @Published var recommendedPrograms: [Program] = []
    @Published var favoritePrograms: [Program] = []
    @Published var followingBroadcasters: [Broadcaster] = []
    @Published var isLoadingRecommended: Bool = false
    @Published var isLoadingFavorites: Bool = false
    @Published var isLoadingFollows: Bool = false
    @Published var errorMessage: String?

    private let programRepository: ProgramRepositoryProtocol
    private let userRepository: UserRepositoryProtocol

    init(
        programRepository: ProgramRepositoryProtocol = ProgramRepository(),
        userRepository: UserRepositoryProtocol = UserRepository()
    ) {
        self.programRepository = programRepository
        self.userRepository = userRepository
    }

    func loadAll() async {
        async let recommended: Void = loadRecommended()
        async let favorites: Void = loadFavorites()
        async let follows: Void = loadFollows()
        _ = await (recommended, favorites, follows)
    }

    func loadRecommended() async {
        isLoadingRecommended = true
        do {
            let response = try await programRepository.fetchRecommendedPrograms(page: 1)
            recommendedPrograms = response.data
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoadingRecommended = false
    }

    func loadFavorites() async {
        isLoadingFavorites = true
        do {
            let response = try await programRepository.fetchFavoritePrograms(page: 1)
            favoritePrograms = response.data
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoadingFavorites = false
    }

    func loadFollows() async {
        isLoadingFollows = true
        do {
            let response = try await userRepository.fetchFollows(page: 1)
            followingBroadcasters = response.data
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoadingFollows = false
    }

    func refresh() async {
        await loadAll()
    }
}
