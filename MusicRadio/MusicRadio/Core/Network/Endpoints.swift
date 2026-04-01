import Foundation

// MARK: - Type-erasing Encodable wrapper

struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init<T: Encodable>(_ wrapped: T) {
        _encode = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

struct Endpoint {
    let path: String
    let method: HTTPMethod
    let body: AnyEncodable?
    let queryItems: [URLQueryItem]?

    init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem]? = nil
    ) {
        self.path = path
        self.method = method
        self.body = nil
        self.queryItems = queryItems
    }

    init<T: Encodable>(
        path: String,
        method: HTTPMethod = .get,
        body: T,
        queryItems: [URLQueryItem]? = nil
    ) {
        self.path = path
        self.method = method
        self.body = AnyEncodable(body)
        self.queryItems = queryItems
    }
}

// MARK: - Auth Endpoints

extension Endpoint {
    static func signIn(email: String, password: String) -> Endpoint {
        Endpoint(
            path: "/auth/login",
            method: .post,
            body: SignInRequest(email: email, password: password)
        )
    }

    static func signUp(email: String) -> Endpoint {
        Endpoint(
            path: "/auth/register",
            method: .post,
            body: SignUpRequest(email: email)
        )
    }

    static func verifyEmail(email: String, code: String) -> Endpoint {
        Endpoint(
            path: "/auth/verify-email",
            method: .post,
            body: VerifyEmailRequest(email: email, code: code)
        )
    }

    static func completeRegistration(token: String, nickname: String, password: String) -> Endpoint {
        Endpoint(
            path: "/auth/complete-registration",
            method: .post,
            body: CompleteRegistrationRequest(token: token, nickname: nickname, password: password)
        )
    }

    static func refreshToken(refreshToken: String) -> Endpoint {
        Endpoint(
            path: "/auth/refresh",
            method: .post,
            body: RefreshTokenRequest(refreshToken: refreshToken)
        )
    }

    static func requestPasswordReset(email: String) -> Endpoint {
        Endpoint(
            path: "/auth/password-reset",
            method: .post,
            body: PasswordResetRequest(email: email)
        )
    }

    static func confirmPasswordReset(token: String, password: String) -> Endpoint {
        Endpoint(
            path: "/auth/password-reset/confirm",
            method: .post,
            body: PasswordResetConfirmRequest(token: token, newPassword: password)
        )
    }

    static var logout: Endpoint {
        Endpoint(path: "/auth/logout", method: .post)
    }
}

// MARK: - Program Endpoints

extension Endpoint {
    static func programs(page: Int = 1, perPage: Int = 30) -> Endpoint {
        Endpoint(
            path: "/programs",
            queryItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
        )
    }

    static func searchPrograms(
        query: String? = nil,
        genre: String? = nil,
        sortBy: String = "play_count",
        sortOrder: String = "desc",
        page: Int = 1,
        perPage: Int = 30
    ) -> Endpoint {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "sort_by", value: sortBy),
            URLQueryItem(name: "sort_order", value: sortOrder),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        if let query = query, !query.isEmpty {
            queryItems.append(URLQueryItem(name: "q", value: query))
        }
        if let genre = genre, !genre.isEmpty {
            queryItems.append(URLQueryItem(name: "genre", value: genre))
        }
        return Endpoint(path: "/programs", queryItems: queryItems)
    }

    static var programGenres: Endpoint {
        Endpoint(path: "/programs/genres")
    }

    static func recommendedPrograms(page: Int = 1, perPage: Int = 30) -> Endpoint {
        Endpoint(
            path: "/programs/recommended",
            queryItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
        )
    }

    static func program(id: String) -> Endpoint {
        Endpoint(path: "/programs/\(id)")
    }

    static func programTracks(programId: String) -> Endpoint {
        Endpoint(path: "/programs/\(programId)/tracks")
    }

    static func createProgram(body: CreateProgramRequest) -> Endpoint {
        Endpoint(path: "/programs", method: .post, body: body)
    }

    static func updateProgram(id: String, body: UpdateProgramRequest) -> Endpoint {
        Endpoint(path: "/programs/\(id)", method: .put, body: body)
    }

    static func deleteProgram(id: String) -> Endpoint {
        Endpoint(path: "/programs/\(id)", method: .delete)
    }

    static func publishProgram(id: String) -> Endpoint {
        Endpoint(path: "/programs/\(id)/publish", method: .post)
    }

    static func uploadProgramAudio(programId: String) -> Endpoint {
        Endpoint(path: "/programs/\(programId)/audio", method: .post)
    }

    static func myPrograms(page: Int = 1, perPage: Int = 30) -> Endpoint {
        Endpoint(
            path: "/me/programs",
            queryItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
        )
    }
}

// MARK: - Favorite Endpoints

extension Endpoint {
    static func favoritePrograms(page: Int = 1, perPage: Int = 30) -> Endpoint {
        Endpoint(
            path: "/me/favorites",
            queryItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
        )
    }

    static func addFavorite(programId: String) -> Endpoint {
        Endpoint(path: "/programs/\(programId)/favorite", method: .post)
    }

    static func removeFavorite(programId: String) -> Endpoint {
        Endpoint(path: "/programs/\(programId)/favorite", method: .delete)
    }
}

// MARK: - User / Broadcaster Endpoints

extension Endpoint {
    static func broadcaster(id: String) -> Endpoint {
        Endpoint(path: "/broadcasters/\(id)")
    }

    static func broadcasterPrograms(id: String, page: Int = 1, perPage: Int = 30) -> Endpoint {
        Endpoint(
            path: "/broadcasters/\(id)/programs",
            queryItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
        )
    }

    static var myProfile: Endpoint {
        Endpoint(path: "/me/profile")
    }

    static func updateProfile(body: UpdateProfileRequest) -> Endpoint {
        Endpoint(path: "/me/profile", method: .put, body: body)
    }

    static func uploadAvatar() -> Endpoint {
        Endpoint(path: "/me/avatar", method: .post)
    }
}

// MARK: - Follow Endpoints

extension Endpoint {
    static func follows(page: Int = 1, perPage: Int = 30) -> Endpoint {
        Endpoint(
            path: "/me/follows",
            queryItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
        )
    }

    static func follow(broadcasterId: String) -> Endpoint {
        Endpoint(path: "/broadcasters/\(broadcasterId)/follow", method: .post)
    }

    static func unfollow(broadcasterId: String) -> Endpoint {
        Endpoint(path: "/broadcasters/\(broadcasterId)/follow", method: .delete)
    }
}

// MARK: - Notification Endpoints

extension Endpoint {
    static func notifications(page: Int = 1, perPage: Int = 30) -> Endpoint {
        Endpoint(
            path: "/notifications",
            queryItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
        )
    }

    static func markNotificationRead(id: String) -> Endpoint {
        Endpoint(path: "/notifications/\(id)/read", method: .put)
    }

    static var markAllNotificationsRead: Endpoint {
        Endpoint(path: "/notifications/read-all", method: .post)
    }

    static func registerDeviceToken(token: String) -> Endpoint {
        Endpoint(
            path: "/notifications/device-token",
            method: .post,
            body: DeviceTokenRequest(deviceToken: token)
        )
    }

    static var unreadCount: Endpoint {
        Endpoint(path: "/notifications/unread-count")
    }
}

// MARK: - Analytics Endpoints

extension Endpoint {
    static var analyticsOverview: Endpoint {
        Endpoint(path: "/analytics/overview")
    }

    static var analyticsProgramStats: Endpoint {
        Endpoint(path: "/analytics/programs")
    }

    static func analyticsPlayTrends(days: Int = 30) -> Endpoint {
        Endpoint(
            path: "/analytics/play-trends",
            queryItems: [URLQueryItem(name: "days", value: "\(days)")]
        )
    }

    static var analyticsTopTracks: Endpoint {
        Endpoint(path: "/analytics/top-tracks")
    }
}

// MARK: - Request Bodies

struct SignInRequest: Encodable {
    let email: String
    let password: String
}

struct SignUpRequest: Encodable {
    let email: String
}

struct VerifyEmailRequest: Encodable {
    let email: String
    let code: String
}

struct CompleteRegistrationRequest: Encodable {
    let token: String
    let nickname: String
    let password: String
}

struct RefreshTokenRequest: Encodable {
    let refreshToken: String
}

struct PasswordResetRequest: Encodable {
    let email: String
}

struct PasswordResetConfirmRequest: Encodable {
    let token: String
    let newPassword: String
}

struct CreateProgramRequest: Encodable {
    let title: String
    let description: String?
    let programType: String
    let tracks: [TrackInput]?
}

struct UpdateProgramRequest: Encodable {
    let title: String?
    let description: String?
    let tracks: [TrackInput]?
}

struct TrackInput: Encodable {
    let appleMusicTrackId: String
    let title: String
    let artistName: String
    let artworkUrl: String?
    let playTimingSeconds: Int
    let trackOrder: Int
}

struct UpdateProfileRequest: Encodable {
    let nickname: String?
    let message: String?
}

struct DeviceTokenRequest: Encodable {
    let deviceToken: String
}
