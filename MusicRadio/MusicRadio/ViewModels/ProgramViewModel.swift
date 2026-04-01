import Foundation
import Combine

@MainActor
final class ProgramViewModel: ObservableObject {
    @Published var currentProgram: Program?
    @Published var tracks: [ProgramTrack] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isFavorited: Bool = false

    private let programRepository: ProgramRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    init(programRepository: ProgramRepositoryProtocol = ProgramRepository()) {
        self.programRepository = programRepository
    }

    // MARK: - Load Program

    func loadProgram(id: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let program = try await programRepository.fetchProgram(id: id)
            currentProgram = program
            tracks = program.tracks ?? []
            isFavorited = program.isFavorited ?? false

            // Load tracks separately if not included
            if program.tracks == nil || program.tracks?.isEmpty == true {
                let fetchedTracks = try await programRepository.fetchProgramTracks(programId: id)
                tracks = fetchedTracks
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Start Playback with DualPlaybackCoordinator

    func startPlayback(coordinator: DualPlaybackCoordinator) async {
        guard let program = currentProgram, let audioUrlString = program.audioUrl,
              let audioURL = URL(string: audioUrlString) else {
            errorMessage = "No audio available for this program"
            return
        }

        await coordinator.loadProgram(audioURL: audioURL, tracks: tracks)
        coordinator.playAll()
    }

    // MARK: - Favorites

    func toggleFavorite() async {
        guard let program = currentProgram else { return }

        let wasFavorited = isFavorited
        isFavorited.toggle()

        do {
            if wasFavorited {
                try await programRepository.removeFavorite(programId: program.id)
            } else {
                try await programRepository.addFavorite(programId: program.id)
            }
        } catch {
            isFavorited = wasFavorited
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Clear

    func clearCurrentProgram() {
        currentProgram = nil
        tracks = []
        isFavorited = false
    }
}
