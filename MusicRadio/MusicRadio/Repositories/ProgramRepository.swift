import Foundation

protocol ProgramRepositoryProtocol {
    func fetchRecommendedPrograms(page: Int) async throws -> PaginatedResponse<Program>
    func fetchPrograms(page: Int) async throws -> PaginatedResponse<Program>
    func searchPrograms(query: String?, genre: String?, sortBy: String, sortOrder: String, page: Int) async throws -> PaginatedResponse<Program>
    func fetchProgram(id: String) async throws -> Program
    func fetchProgramTracks(programId: String) async throws -> [ProgramTrack]
    func createProgram(title: String, description: String?, programType: ProgramType, tracks: [TrackInput]?) async throws -> Program
    func updateProgram(id: String, title: String?, description: String?, tracks: [TrackInput]?) async throws -> Program
    func deleteProgram(id: String) async throws
    func publishProgram(id: String) async throws -> Program
    func fetchMyPrograms(page: Int) async throws -> PaginatedResponse<Program>
    func addFavorite(programId: String) async throws
    func removeFavorite(programId: String) async throws
    func fetchFavoritePrograms(page: Int) async throws -> PaginatedResponse<Program>
}

final class ProgramRepository: ProgramRepositoryProtocol {
    private let apiClient = APIClient.shared

    func fetchRecommendedPrograms(page: Int) async throws -> PaginatedResponse<Program> {
        try await apiClient.requestWithPagination(
            endpoint: .recommendedPrograms(page: page),
            itemType: Program.self
        )
    }

    func fetchPrograms(page: Int) async throws -> PaginatedResponse<Program> {
        try await apiClient.requestWithPagination(
            endpoint: .programs(page: page),
            itemType: Program.self
        )
    }

    func searchPrograms(query: String?, genre: String?, sortBy: String, sortOrder: String, page: Int) async throws -> PaginatedResponse<Program> {
        try await apiClient.requestWithPagination(
            endpoint: .searchPrograms(query: query, genre: genre, sortBy: sortBy, sortOrder: sortOrder, page: page),
            itemType: Program.self
        )
    }

    func fetchProgram(id: String) async throws -> Program {
        let response: APIResponse<Program> = try await apiClient.request(
            endpoint: .program(id: id),
            responseType: APIResponse<Program>.self
        )
        return response.data
    }

    func fetchProgramTracks(programId: String) async throws -> [ProgramTrack] {
        let response: APIResponse<[ProgramTrack]> = try await apiClient.request(
            endpoint: .programTracks(programId: programId),
            responseType: APIResponse<[ProgramTrack]>.self
        )
        return response.data
    }

    func createProgram(title: String, description: String?, programType: ProgramType, tracks: [TrackInput]?) async throws -> Program {
        let body = CreateProgramRequest(
            title: title,
            description: description,
            programType: programType.rawValue,
            tracks: tracks
        )
        let response: APIResponse<Program> = try await apiClient.request(
            endpoint: .createProgram(body: body),
            responseType: APIResponse<Program>.self
        )
        return response.data
    }

    func updateProgram(id: String, title: String?, description: String?, tracks: [TrackInput]?) async throws -> Program {
        let body = UpdateProgramRequest(
            title: title,
            description: description,
            tracks: tracks
        )
        let response: APIResponse<Program> = try await apiClient.request(
            endpoint: .updateProgram(id: id, body: body),
            responseType: APIResponse<Program>.self
        )
        return response.data
    }

    func deleteProgram(id: String) async throws {
        try await apiClient.requestVoid(endpoint: .deleteProgram(id: id))
    }

    func publishProgram(id: String) async throws -> Program {
        let response: APIResponse<Program> = try await apiClient.request(
            endpoint: .publishProgram(id: id),
            responseType: APIResponse<Program>.self
        )
        return response.data
    }

    func fetchMyPrograms(page: Int) async throws -> PaginatedResponse<Program> {
        try await apiClient.requestWithPagination(
            endpoint: .myPrograms(page: page),
            itemType: Program.self
        )
    }

    func addFavorite(programId: String) async throws {
        try await apiClient.requestVoid(endpoint: .addFavorite(programId: programId))
    }

    func removeFavorite(programId: String) async throws {
        try await apiClient.requestVoid(endpoint: .removeFavorite(programId: programId))
    }

    func fetchFavoritePrograms(page: Int) async throws -> PaginatedResponse<Program> {
        try await apiClient.requestWithPagination(
            endpoint: .favoritePrograms(page: page),
            itemType: Program.self
        )
    }
}
