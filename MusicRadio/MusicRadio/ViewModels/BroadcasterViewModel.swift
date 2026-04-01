import Foundation

@MainActor
final class BroadcasterViewModel: ObservableObject {
    @Published var broadcaster: Broadcaster?
    @Published var programs: [Program] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMore: Bool = true
    @Published var errorMessage: String?
    @Published var isFollowing: Bool = false

    private let userRepository: UserRepositoryProtocol
    private var currentPage: Int = 1
    private var broadcasterId: String?

    init(userRepository: UserRepositoryProtocol = UserRepository()) {
        self.userRepository = userRepository
    }

    func loadBroadcaster(id: String) async {
        broadcasterId = id
        isLoading = true
        errorMessage = nil

        do {
            async let broadcasterResult = userRepository.fetchBroadcaster(id: id)
            async let programsResult = userRepository.fetchBroadcasterPrograms(id: id, page: 1)

            let (fetchedBroadcaster, fetchedPrograms) = try await (broadcasterResult, programsResult)

            broadcaster = fetchedBroadcaster
            isFollowing = fetchedBroadcaster.isFollowing ?? false
            programs = fetchedPrograms.data
            hasMore = fetchedPrograms.meta.hasNext
            currentPage = 1
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadMorePrograms() async {
        guard let id = broadcasterId, hasMore, !isLoadingMore else { return }

        isLoadingMore = true
        let nextPage = currentPage + 1

        do {
            let response = try await userRepository.fetchBroadcasterPrograms(id: id, page: nextPage)
            programs.append(contentsOf: response.data)
            hasMore = response.meta.hasNext
            currentPage = nextPage
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingMore = false
    }

    func toggleFollow() async {
        guard let id = broadcasterId else { return }

        let wasFollowing = isFollowing
        isFollowing.toggle()

        do {
            if wasFollowing {
                try await userRepository.unfollow(broadcasterId: id)
            } else {
                try await userRepository.follow(broadcasterId: id)
            }
        } catch {
            isFollowing = wasFollowing
            errorMessage = error.localizedDescription
        }
    }
}
