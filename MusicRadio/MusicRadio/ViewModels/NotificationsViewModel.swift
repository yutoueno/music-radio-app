import Foundation
import SwiftUI

@MainActor
final class NotificationsViewModel: ObservableObject {
    @Published var notifications: [AppNotification] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMore: Bool = true
    @Published var errorMessage: String?

    private let apiClient = APIClient.shared
    private var currentPage: Int = 1

    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    func loadNotifications() async {
        isLoading = true
        errorMessage = nil
        currentPage = 1

        do {
            let response = try await apiClient.requestWithPagination(
                endpoint: .notifications(page: 1),
                itemType: AppNotification.self
            )
            notifications = response.data
            hasMore = response.meta.hasNext
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadMore() async {
        guard hasMore, !isLoadingMore else { return }

        isLoadingMore = true
        let nextPage = currentPage + 1

        do {
            let response = try await apiClient.requestWithPagination(
                endpoint: .notifications(page: nextPage),
                itemType: AppNotification.self
            )
            notifications.append(contentsOf: response.data)
            hasMore = response.meta.hasNext
            currentPage = nextPage
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingMore = false
    }

    func markAsRead(id: String) async {
        do {
            try await apiClient.requestVoid(endpoint: .markNotificationRead(id: id))
            if let index = notifications.firstIndex(where: { $0.id == id }) {
                notifications[index] = notifications[index].markedAsRead()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markAllAsRead() async {
        do {
            try await apiClient.requestVoid(endpoint: .markAllNotificationsRead)
            notifications = notifications.map { $0.markedAsRead() }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refresh() async {
        await loadNotifications()
    }
}

// MARK: - Notification Model

struct AppNotification: Codable, Identifiable, Equatable {
    let id: String
    let type: NotificationType?
    let title: String
    let body: String
    let isRead: Bool
    let referenceId: String?
    let referenceType: String?
    let createdAt: Date?

    var timeAgo: String {
        guard let date = createdAt else { return "" }
        return date.relativeDisplay
    }

    func markedAsRead() -> AppNotification {
        AppNotification(
            id: id,
            type: type,
            title: title,
            body: body,
            isRead: true,
            referenceId: referenceId,
            referenceType: referenceType,
            createdAt: createdAt
        )
    }

    static func == (lhs: AppNotification, rhs: AppNotification) -> Bool {
        lhs.id == rhs.id
    }
}

enum NotificationType: String, Codable {
    case newFollower = "new_follower"
    case newFavorite = "new_favorite"
    case programPublished = "program_published"
    case system = "system"

    var iconName: String {
        switch self {
        case .newFollower: return "person.badge.plus"
        case .newFavorite: return "heart.fill"
        case .programPublished: return "radio"
        case .system: return "bell.fill"
        }
    }

    var iconColor: SwiftUI.Color {
        switch self {
        case .newFollower: return .blue
        case .newFavorite: return .pink
        case .programPublished: return .purple
        case .system: return .orange
        }
    }
}
