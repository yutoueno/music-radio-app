import Foundation

@MainActor
final class FollowsViewModel: ObservableObject {
    @Published var broadcasters: [Broadcaster] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMore: Bool = true
    @Published var errorMessage: String?

    private let userRepository: UserRepositoryProtocol
    private var currentPage: Int = 1

    init(userRepository: UserRepositoryProtocol = UserRepository()) {
        self.userRepository = userRepository
    }

    func loadFollows() async {
        isLoading = true
        errorMessage = nil
        currentPage = 1

        do {
            let response = try await userRepository.fetchFollows(page: 1)
            broadcasters = response.data
            hasMore = response.meta.hasNext
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadMore() async {
        guard hasMore, !isLoadingMore else { return }

        isLoadingMore = true
        let nextPage = currentPage + 1

        do {
            let response = try await userRepository.fetchFollows(page: nextPage)
            broadcasters.append(contentsOf: response.data)
            hasMore = response.meta.hasNext
            currentPage = nextPage
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingMore = false
    }

    func unfollow(broadcasterId: String) async {
        do {
            try await userRepository.unfollow(broadcasterId: broadcasterId)
            broadcasters.removeAll { $0.id == broadcasterId }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refresh() async {
        await loadFollows()
    }
}
