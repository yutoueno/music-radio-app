import Foundation

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published var programs: [Program] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMore: Bool = true
    @Published var errorMessage: String?

    private let programRepository: ProgramRepositoryProtocol
    private var currentPage: Int = 1

    init(programRepository: ProgramRepositoryProtocol = ProgramRepository()) {
        self.programRepository = programRepository
    }

    func loadFavorites() async {
        isLoading = true
        errorMessage = nil
        currentPage = 1

        do {
            let response = try await programRepository.fetchFavoritePrograms(page: 1)
            programs = response.data
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
            let response = try await programRepository.fetchFavoritePrograms(page: nextPage)
            programs.append(contentsOf: response.data)
            hasMore = response.meta.hasNext
            currentPage = nextPage
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingMore = false
    }

    func removeFavorite(programId: String) async {
        do {
            try await programRepository.removeFavorite(programId: programId)
            programs.removeAll { $0.id == programId }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refresh() async {
        await loadFavorites()
    }
}
