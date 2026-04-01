import Foundation

struct Program: Codable, Identifiable, Equatable {
    let id: String
    let userId: String?
    let title: String
    let description: String?
    let thumbnailUrl: String?
    let audioUrl: String?
    let durationSeconds: Int?
    let programType: ProgramType?
    let genre: String?
    let status: ProgramStatus?
    let scheduledAt: Date?
    let playCount: Int?
    let favoriteCount: Int?
    let isFavorited: Bool?
    let broadcaster: ProgramBroadcaster?
    let tracks: [ProgramTrack]?
    let createdAt: Date?
    let updatedAt: Date?
    let publishedAt: Date?
    let shareUrl: String?

    var durationFormatted: String {
        guard let seconds = durationSeconds else { return "--:--" }
        return TimeInterval(seconds).formattedDuration
    }

    static func == (lhs: Program, rhs: Program) -> Bool {
        lhs.id == rhs.id
    }
}

struct ProgramBroadcaster: Codable, Equatable {
    let id: String
    let nickname: String
    let avatarUrl: String?
}

enum ProgramType: String, Codable, CaseIterable {
    case music = "music"
    case talk = "talk"
    case mixed = "mixed"

    var displayName: String {
        switch self {
        case .music: return "Music"
        case .talk: return "Talk"
        case .mixed: return "Mixed"
        }
    }

    var iconName: String {
        switch self {
        case .music: return "music.note"
        case .talk: return "mic"
        case .mixed: return "music.mic"
        }
    }
}

enum ProgramStatus: String, Codable {
    case draft = "draft"
    case published = "published"
    case archived = "archived"

    var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .published: return "Published"
        case .archived: return "Archived"
        }
    }
}
