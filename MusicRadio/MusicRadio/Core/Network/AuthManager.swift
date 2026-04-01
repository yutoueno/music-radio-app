import Foundation
import Combine

@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published private(set) var isAuthenticated: Bool = false
    @Published private(set) var currentUser: User?

    private(set) var accessToken: String? {
        didSet {
            if let token = accessToken {
                KeychainManager.shared.save(token, forKey: .accessToken)
            } else {
                KeychainManager.shared.delete(forKey: .accessToken)
            }
        }
    }

    private(set) var refreshTokenValue: String? {
        didSet {
            if let token = refreshTokenValue {
                KeychainManager.shared.save(token, forKey: .refreshToken)
            } else {
                KeychainManager.shared.delete(forKey: .refreshToken)
            }
        }
    }

    private var isRefreshing = false

    private init() {
        accessToken = KeychainManager.shared.load(forKey: .accessToken)
        refreshTokenValue = KeychainManager.shared.load(forKey: .refreshToken)
        isAuthenticated = accessToken != nil
    }

    // MARK: - Token Management

    func setTokens(access: String, refresh: String) {
        accessToken = access
        refreshTokenValue = refresh
        isAuthenticated = true
    }

    func setUser(_ user: User) {
        currentUser = user
    }

    func refreshTokenIfNeeded() async -> Bool {
        guard !isRefreshing else { return false }
        guard let refresh = refreshTokenValue else { return false }

        isRefreshing = true
        defer { isRefreshing = false }

        do {
            let endpoint = Endpoint.refreshToken(refreshToken: refresh)
            guard let url = URL(string: APIClient.shared.baseURL + endpoint.path) else {
                return false
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            request.httpBody = try encoder.encode(RefreshTokenRequest(refreshToken: refresh))

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return false
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let tokenResponse = try decoder.decode(APIResponse<TokenResponse>.self, from: data)

            accessToken = tokenResponse.data.accessToken
            refreshTokenValue = tokenResponse.data.refreshToken
            return true
        } catch {
            print("[AuthManager] Token refresh failed: \(error.localizedDescription)")
            return false
        }
    }

    func logout() {
        accessToken = nil
        refreshTokenValue = nil
        currentUser = nil
        isAuthenticated = false
    }
}

struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let user: User?
}
