import Foundation

protocol AuthRepositoryProtocol {
    func signIn(email: String, password: String) async throws -> AuthResponse
    func signUp(email: String) async throws -> MessageResponse
    func verifyEmail(email: String, code: String) async throws -> VerificationResponse
    func completeRegistration(token: String, nickname: String, password: String) async throws -> AuthResponse
    func requestPasswordReset(email: String) async throws -> MessageResponse
    func confirmPasswordReset(token: String, password: String) async throws -> MessageResponse
    func logout() async throws
}

final class AuthRepository: AuthRepositoryProtocol {
    private let apiClient = APIClient.shared

    func signIn(email: String, password: String) async throws -> AuthResponse {
        let response: APIResponse<AuthResponse> = try await apiClient.request(
            endpoint: .signIn(email: email, password: password),
            responseType: APIResponse<AuthResponse>.self
        )
        return response.data
    }

    func signUp(email: String) async throws -> MessageResponse {
        let response: APIResponse<MessageResponse> = try await apiClient.request(
            endpoint: .signUp(email: email),
            responseType: APIResponse<MessageResponse>.self
        )
        return response.data
    }

    func verifyEmail(email: String, code: String) async throws -> VerificationResponse {
        let response: APIResponse<VerificationResponse> = try await apiClient.request(
            endpoint: .verifyEmail(email: email, code: code),
            responseType: APIResponse<VerificationResponse>.self
        )
        return response.data
    }

    func completeRegistration(token: String, nickname: String, password: String) async throws -> AuthResponse {
        let response: APIResponse<AuthResponse> = try await apiClient.request(
            endpoint: .completeRegistration(token: token, nickname: nickname, password: password),
            responseType: APIResponse<AuthResponse>.self
        )
        return response.data
    }

    func requestPasswordReset(email: String) async throws -> MessageResponse {
        let response: APIResponse<MessageResponse> = try await apiClient.request(
            endpoint: .requestPasswordReset(email: email),
            responseType: APIResponse<MessageResponse>.self
        )
        return response.data
    }

    func confirmPasswordReset(token: String, password: String) async throws -> MessageResponse {
        let response: APIResponse<MessageResponse> = try await apiClient.request(
            endpoint: .confirmPasswordReset(token: token, password: password),
            responseType: APIResponse<MessageResponse>.self
        )
        return response.data
    }

    func logout() async throws {
        try await apiClient.requestVoid(endpoint: .logout)
    }
}
