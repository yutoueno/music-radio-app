import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.notifications.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.notifications.isEmpty {
                emptyState
            } else {
                notificationList
            }
        }
        .navigationTitle("Notifications")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.unreadCount > 0 {
                    Button {
                        Task { await viewModel.markAllAsRead() }
                    } label: {
                        Text("Read All")
                            .font(.subheadline)
                    }
                }
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .onFirstAppear {
            await viewModel.loadNotifications()
        }
        .errorAlert(error: $viewModel.errorMessage)
    }

    // MARK: - List

    private var notificationList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.notifications) { notification in
                    notificationRow(notification)
                        .onAppear {
                            if notification.id == viewModel.notifications.last?.id && viewModel.hasMore {
                                Task { await viewModel.loadMore() }
                            }
                        }
                }

                if viewModel.isLoadingMore {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .padding(.bottom, 80)
        }
    }

    private func notificationRow(_ notification: AppNotification) -> some View {
        Button {
            Task { await viewModel.markAsRead(id: notification.id) }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill((notification.type?.iconColor ?? .gray).opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: notification.type?.iconName ?? "bell.fill")
                        .font(.subheadline)
                        .foregroundColor(notification.type?.iconColor ?? .gray)
                }

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.subheadline)
                        .fontWeight(notification.isRead ? .regular : .semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(notification.body)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    Text(notification.timeAgo)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Unread indicator
                if !notification.isRead {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(notification.isRead ? Color.clear : Color.accentColor.opacity(0.04))
        }
        .buttonStyle(.plain)

        Divider()
            .padding(.leading, 68)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No notifications")
                .font(.title3)
                .foregroundColor(.secondary)
            Text("You'll be notified about new followers, favorites, and more")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
