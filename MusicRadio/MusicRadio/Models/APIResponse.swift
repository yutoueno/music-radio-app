import Foundation

struct APIResponse<T: Codable>: Codable {
    let data: T
}

struct PaginatedResponse<T: Codable>: Codable {
    let data: [T]
    let meta: PaginationMeta
}

struct PaginationMeta: Codable {
    let page: Int
    let perPage: Int
    let total: Int
    let hasNext: Bool
}

struct EmptyResponse: Codable {}

struct MessageResponse: Codable {
    let message: String
}

struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let user: User
}

struct VerificationResponse: Codable {
    let token: String
    let message: String?
}

struct UploadResponse: Codable {
    let url: String
    let fileName: String?
}
