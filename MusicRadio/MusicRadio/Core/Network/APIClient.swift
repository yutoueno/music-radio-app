import Foundation

final class APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    #if DEBUG
    var baseURL: String = "http://localhost:8000/api/v1"
    #else
    var baseURL: String = "http://localhost:8000/api/v1"
    #endif

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        session = URLSession(configuration: config)

        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
    }

    // MARK: - Generic Request

    func request<T: Decodable>(
        endpoint: Endpoint,
        responseType: T.Type
    ) async throws -> T {
        var urlRequest = try buildRequest(for: endpoint)
        urlRequest = try await injectAuthToken(into: urlRequest)

        let (data, response) = try await performRequest(urlRequest)
        try validateResponse(response)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error.localizedDescription)
        }
    }

    func requestWithPagination<T: Decodable>(
        endpoint: Endpoint,
        itemType: T.Type
    ) async throws -> PaginatedResponse<T> {
        var urlRequest = try buildRequest(for: endpoint)
        urlRequest = try await injectAuthToken(into: urlRequest)

        let (data, response) = try await performRequest(urlRequest)
        try validateResponse(response)

        do {
            return try decoder.decode(PaginatedResponse<T>.self, from: data)
        } catch {
            throw APIError.decodingFailed(error.localizedDescription)
        }
    }

    func requestVoid(endpoint: Endpoint) async throws {
        var urlRequest = try buildRequest(for: endpoint)
        urlRequest = try await injectAuthToken(into: urlRequest)

        let (_, response) = try await performRequest(urlRequest)
        try validateResponse(response)
    }

    // MARK: - Upload

    func upload<T: Decodable>(
        endpoint: Endpoint,
        fileData: Data,
        fileName: String,
        mimeType: String,
        fieldName: String = "file",
        additionalFields: [String: String] = [:],
        responseType: T.Type,
        onProgress: ((Double) -> Void)? = nil
    ) async throws -> T {
        let boundary = UUID().uuidString
        var urlRequest = try buildRequest(for: endpoint)
        urlRequest = try await injectAuthToken(into: urlRequest)
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Add additional fields
        for (key, value) in additionalFields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // Add file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        urlRequest.httpBody = body

        let (data, response) = try await session.data(for: urlRequest)
        try validateResponse(response)

        return try decoder.decode(T.self, from: data)
    }

    // MARK: - Private Helpers

    private func buildRequest(for endpoint: Endpoint) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)

        if let queryItems = endpoint.queryItems, !queryItems.isEmpty {
            components?.queryItems = queryItems
        }

        guard let finalURL = components?.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body = endpoint.body {
            request.httpBody = try encoder.encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }


        return request
    }

    private func injectAuthToken(into request: URLRequest) async throws -> URLRequest {
        var mutableRequest = request
        let token = await AuthManager.shared.accessToken
        if let token = token {
            mutableRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return mutableRequest
    }

    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            let (data, response) = try await session.data(for: request)

            // Check for 401 and try token refresh
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 401 {
                let refreshed = await AuthManager.shared.refreshTokenIfNeeded()
                if refreshed {
                    var retryRequest = request
                    let newToken = await AuthManager.shared.accessToken
                    if let newToken = newToken {
                        retryRequest.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
                    }
                    return try await session.data(for: retryRequest)
                } else {
                    await AuthManager.shared.logout()
                    throw APIError.unauthorized
                }
            }

            return (data, response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error.localizedDescription)
        }
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw APIError.unauthorized
        case 403:
            throw APIError.forbidden
        case 404:
            throw APIError.notFound
        case 422:
            throw APIError.validationError
        case 500...599:
            throw APIError.serverError(httpResponse.statusCode)
        default:
            throw APIError.unknown(httpResponse.statusCode)
        }
    }
}

// MARK: - API Error

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case validationError
    case serverError(Int)
    case networkError(String)
    case decodingFailed(String)
    case unknown(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .unauthorized:
            return "Authentication required"
        case .forbidden:
            return "Access denied"
        case .notFound:
            return "Resource not found"
        case .validationError:
            return "Validation error"
        case .serverError(let code):
            return "Server error (\(code))"
        case .networkError(let message):
            return "Network error: \(message)"
        case .decodingFailed(let message):
            return "Failed to parse response: \(message)"
        case .unknown(let code):
            return "Unknown error (\(code))"
        }
    }
}

// MARK: - HTTP Method

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
