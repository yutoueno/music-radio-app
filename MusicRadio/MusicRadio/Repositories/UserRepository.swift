import Foundation

protocol UserRepositoryProtocol {
    func fetchMyProfile() async throws -> UserProfile
    func updateProfile(nickname: String?, message: String?) async throws -> UserProfile
    func uploadAvatar(imageData: Data) async throws -> UploadResponse
    func fetchBroadcaster(id: String) async throws -> Broadcaster
    func fetchBroadcasterPrograms(id: String, page: Int) async throws -> PaginatedResponse<Program>
    func fetchFollows(page: Int) async throws -> PaginatedResponse<Broadcaster>
    func follow(broadcasterId: String) async throws
    func unfollow(broadcasterId: String) async throws
}

final class UserRepository: UserRepositoryProtocol {
    private let apiClient = APIClient.shared

    func fetchMyProfile() async throws -> UserProfile {
        let response: APIResponse<UserProfile> = try await apiClient.request(
            endpoint: .myProfile,
            responseType: APIResponse<UserProfile>.self
        )
        return response.data
    }

    func updateProfile(nickname: String?, message: String?) async throws -> UserProfile {
        let body = UpdateProfileRequest(nickname: nickname, message: message)
        let response: APIResponse<UserProfile> = try await apiClient.request(
            endpoint: .updateProfile(body: body),
            responseType: APIResponse<UserProfile>.self
        )
        return response.data
    }

    func uploadAvatar(imageData: Data) async throws -> UploadResponse {
        try await apiClient.upload(
            endpoint: .uploadAvatar(),
            fileData: imageData,
            fileName: "avatar.jpg",
            mimeType: "image/jpeg",
            fieldName: "avatar",
            responseType: APIResponse<UploadResponse>.self
        ).data
    }

    func fetchBroadcaster(id: String) async throws -> Broadcaster {
        let response: APIResponse<Broadcaster> = try await apiClient.request(
            endpoint: .broadcaster(id: id),
            responseType: APIResponse<Broadcaster>.self
        )
        return response.data
    }

    func fetchBroadcasterPrograms(id: String, page: Int) async throws -> PaginatedResponse<Program> {
        try await apiClient.requestWithPagination(
            endpoint: .broadcasterPrograms(id: id, page: page),
            itemType: Program.self
        )
    }

    func fetchFollows(page: Int) async throws -> PaginatedResponse<Broadcaster> {
        try await apiClient.requestWithPagination(
            endpoint: .follows(page: page),
            itemType: Broadcaster.self
        )
    }

    func follow(broadcasterId: String) async throws {
        try await apiClient.requestVoid(endpoint: .follow(broadcasterId: broadcasterId))
    }

    func unfollow(broadcasterId: String) async throws {
        try await apiClient.requestVoid(endpoint: .unfollow(broadcasterId: broadcasterId))
    }
}
