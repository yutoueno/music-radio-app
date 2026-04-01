import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedGenre: String?
    @Published var sortBy: SortOption = .popular
    @Published var programs: [Program] = []
    @Published var genres: [Genre] = Genre.defaultGenres
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMore: Bool = true
    @Published var errorMessage: String?

    private let programRepository: ProgramRepositoryProtocol
    private var currentPage: Int = 1
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?

    enum SortOption: String, CaseIterable {
        case popular = "play_count"
        case newest = "created_at"
        case favorites = "favorite_count"

        var displayName: String {
            switch self {
            case .popular: return "Popular"
            case .newest: return "Newest"
            case .favorites: return "Favorites"
            }
        }

        var sortOrder: String {
            return "desc"
        }
    }

    struct Genre: Identifiable, Equatable {
        let id: String
        let name: String
        let iconName: String

        static let defaultGenres: [Genre] = [
            Genre(id: "J-POP", name: "J-POP", iconName: "music.note"),
            Genre(id: "ロック", name: "ロック", iconName: "guitars"),
            Genre(id: "ジャズ", name: "ジャズ", iconName: "music.quarternote.3"),
            Genre(id: "アニソン", name: "アニソン", iconName: "sparkles"),
            Genre(id: "インディーズ", name: "インディーズ", iconName: "headphones"),
            Genre(id: "クラシック", name: "クラシック", iconName: "music.note.list"),
            Genre(id: "EDM", name: "EDM", iconName: "waveform"),
            Genre(id: "Hip-Hop", name: "Hip-Hop", iconName: "beats.headphones"),
        ]
    }

    init(programRepository: ProgramRepositoryProtocol = ProgramRepository()) {
        self.programRepository = programRepository
        setupDebounce()
    }

    // MARK: - Setup

    private func setupDebounce() {
        $searchText
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.searchTask?.cancel()
                self.searchTask = Task { await self.search() }
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API

    func search() async {
        isLoading = true
        errorMessage = nil
        currentPage = 1

        do {
            let response = try await programRepository.searchPrograms(
                query: searchText.isEmpty ? nil : searchText,
                genre: selectedGenre,
                sortBy: sortBy.rawValue,
                sortOrder: sortBy.sortOrder,
                page: 1
            )
            programs = response.data
            hasMore = response.meta.hasNext
        } catch {
            if !Task.isCancelled {
                errorMessage = error.localizedDescription
            }
        }

        isLoading = false
    }

    func loadMore() async {
        guard hasMore, !isLoadingMore else { return }

        isLoadingMore = true
        let nextPage = currentPage + 1

        do {
            let response = try await programRepository.searchPrograms(
                query: searchText.isEmpty ? nil : searchText,
                genre: selectedGenre,
                sortBy: sortBy.rawValue,
                sortOrder: sortBy.sortOrder,
                page: nextPage
            )
            programs.append(contentsOf: response.data)
            hasMore = response.meta.hasNext
            currentPage = nextPage
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingMore = false
    }

    func selectGenre(_ genre: String?) {
        if selectedGenre == genre {
            selectedGenre = nil
        } else {
            selectedGenre = genre
        }
        searchTask?.cancel()
        searchTask = Task { await search() }
    }

    func selectSort(_ sort: SortOption) {
        guard sortBy != sort else { return }
        sortBy = sort
        searchTask?.cancel()
        searchTask = Task { await search() }
    }

    func refresh() async {
        await search()
    }
}
