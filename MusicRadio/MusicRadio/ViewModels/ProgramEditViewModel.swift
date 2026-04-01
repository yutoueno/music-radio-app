import Foundation
import MusicKit
import UniformTypeIdentifiers

@MainActor
final class ProgramEditViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var programType: ProgramType = .music
    @Published var tracks: [EditableTrack] = []
    @Published var audioFileName: String?
    @Published var audioFileData: Data?
    @Published var isLoading: Bool = false
    @Published var isSaving: Bool = false
    @Published var isUploading: Bool = false
    @Published var uploadProgress: Double = 0
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var savedProgram: Program?

    // Track search
    @Published var trackSearchQuery: String = ""
    @Published var trackSearchResults: [MusicKit.Song] = []
    @Published var isSearchingTracks: Bool = false

    private let programRepository: ProgramRepositoryProtocol
    private let uploadRepository: UploadRepositoryProtocol
    private let musicKitManager = MusicKitManager()
    private var editingProgramId: String?

    init(
        programRepository: ProgramRepositoryProtocol = ProgramRepository(),
        uploadRepository: UploadRepositoryProtocol = UploadRepository()
    ) {
        self.programRepository = programRepository
        self.uploadRepository = uploadRepository
    }

    // MARK: - Load existing program for editing

    func loadProgram(id: String) async {
        editingProgramId = id
        isLoading = true

        do {
            let program = try await programRepository.fetchProgram(id: id)
            title = program.title
            description = program.description ?? ""
            programType = program.programType ?? .music
            if let programTracks = program.tracks {
                tracks = programTracks.map { EditableTrack(from: $0) }
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Save Program

    func saveProgram() async {
        guard validateInput() else { return }

        isSaving = true
        errorMessage = nil

        do {
            let trackInputs = tracks.isEmpty ? nil : tracks.enumerated().map { index, track in
                var mutableTrack = track
                mutableTrack.sortOrder = index
                return mutableTrack.toTrackInput()
            }

            let program: Program
            if let existingId = editingProgramId {
                program = try await programRepository.updateProgram(
                    id: existingId,
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
                    tracks: trackInputs
                )
            } else {
                program = try await programRepository.createProgram(
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
                    programType: programType,
                    tracks: trackInputs
                )
                editingProgramId = program.id
            }

            savedProgram = program

            // Upload audio if selected
            if let audioData = audioFileData, let fileName = audioFileName {
                await uploadAudio(programId: program.id, data: audioData, fileName: fileName)
            }

            successMessage = "Program saved successfully"
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }

    // MARK: - Publish

    func publishProgram() async {
        guard let id = editingProgramId else {
            errorMessage = "Please save the program first"
            return
        }

        isSaving = true
        do {
            let program = try await programRepository.publishProgram(id: id)
            savedProgram = program
            successMessage = "Program published successfully"
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }

    // MARK: - Audio Upload

    func setAudioFile(data: Data, fileName: String) {
        audioFileData = data
        audioFileName = fileName
    }

    private func uploadAudio(programId: String, data: Data, fileName: String) async {
        isUploading = true
        uploadProgress = 0

        do {
            _ = try await uploadRepository.uploadProgramAudio(
                programId: programId,
                audioData: data,
                fileName: fileName
            ) { [weak self] progress in
                DispatchQueue.main.async {
                    self?.uploadProgress = progress
                }
            }
            uploadProgress = 1.0
        } catch {
            errorMessage = "Audio upload failed: \(error.localizedDescription)"
        }

        isUploading = false
    }

    // MARK: - Track Management

    func searchTracks() async {
        let query = trackSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }

        isSearchingTracks = true
        trackSearchResults = await musicKitManager.searchTracks(query: query)
        isSearchingTracks = false
    }

    func addTrack(from song: MusicKit.Song) {
        let artworkURL = song.artwork?.url(width: 300, height: 300)?.absoluteString
        let newTrack = EditableTrack(
            appleMusicTrackId: song.id.rawValue,
            trackName: song.title,
            artistName: song.artistName,
            artworkUrl: artworkURL,
            playTimingSeconds: 0,
            sortOrder: tracks.count
        )
        tracks.append(newTrack)
        trackSearchResults = []
        trackSearchQuery = ""
    }

    func removeTrack(at index: Int) {
        guard index >= 0, index < tracks.count else { return }
        tracks.remove(at: index)
        // Update sort orders
        for i in 0..<tracks.count {
            tracks[i].sortOrder = i
        }
    }

    func moveTrack(from source: IndexSet, to destination: Int) {
        tracks.move(fromOffsets: source, toOffset: destination)
        for i in 0..<tracks.count {
            tracks[i].sortOrder = i
        }
    }

    func updateTrackTiming(at index: Int, seconds: Int) {
        guard index >= 0, index < tracks.count else { return }
        tracks[index].playTimingSeconds = seconds
    }

    // MARK: - Delete

    func deleteProgram() async -> Bool {
        guard let id = editingProgramId else { return false }

        isLoading = true
        do {
            try await programRepository.deleteProgram(id: id)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    // MARK: - Validation

    private func validateInput() -> Bool {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please enter a title"
            return false
        }
        return true
    }
}
