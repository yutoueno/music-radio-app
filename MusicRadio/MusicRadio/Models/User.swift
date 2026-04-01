import Foundation

struct User: Codable, Identifiable, Equatable {
    let id: String
    let email: String
    let isActive: Bool?
    let isAdmin: Bool?
    let emailVerified: Bool?
    // Additional fields that may come from enriched API responses
    let nickname: String?
    let avatarUrl: String?
    let message: String?

    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

struct UserProfile: Codable, Identifiable, Equatable {
    let id: String
    let nickname: String
    let avatarUrl: String?
    let wallpaperUrl: String?
    let message: String?
    let followerCount: Int
    // Additional fields that may come from enriched API responses
    let programCount: Int?
    let followingCount: Int?
    let favoriteCount: Int?

    static func == (lhs: UserProfile, rhs: UserProfile) -> Bool {
        lhs.id == rhs.id
    }
}

struct Broadcaster: Codable, Identifiable, Equatable {
    let id: String
    let nickname: String
    let avatarUrl: String?
    let message: String?
    let programCount: Int?
    let followerCount: Int
    let isFollowing: Bool?

    static func == (lhs: Broadcaster, rhs: Broadcaster) -> Bool {
        lhs.id == rhs.id
    }
}
