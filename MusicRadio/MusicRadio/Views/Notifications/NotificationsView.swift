import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            notificationsHeader

            // Content
            Group {
                if viewModel.isLoading && viewModel.notifications.isEmpty {
                    loadingState
                } else if viewModel.notifications.isEmpty {
                    EmptyStateView(
                        icon: "bell.slash",
                        title: "No Notifications",
                        subtitle: "You'll be notified about new followers, favorites, and more"
                    )
                } else {
                    notificationList
                }
            }
        }
        .background(CrateColors.void)
        .navigationBarHidden(true)
        .refreshable {
            await viewModel.refresh()
        }
        .onFirstAppear {
            await viewModel.loadNotifications()
        }
        .errorAlert(error: $viewModel.errorMessage)
    }

    // MARK: - Header

    private var notificationsHeader: some View {
        HStack(alignment: .center) {
            Text("NOTIFICATIONS")
                .crateText(.sectionLabel, color: CrateColors.textSecondary)

            Spacer()

            if viewModel.unreadCount > 0 {
                Button {
                    Task { await viewModel.markAllAsRead() }
                } label: {
                    Text("Mark All Read")
                        .font(CrateTypography.meta)
                        .tracking(CrateTypography.captionTracking)
                        .foregroundColor(CrateColors.accent)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, CrateTheme.Spacing.screenMargin)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Loading

    private var loadingState: some View {
        ScrollView {
            LazyVStack(spacing: CrateTheme.Spacing.cardGap) {
                ForEach(0..<5, id: \.self) { _ in
                    skeletonNotificationCard
                }
            }
            .padding(.horizontal, CrateTheme.Spacing.screenMargin)
            .padding(.top, 4)
        }
    }

    private var skeletonNotificationCard: some View {
        HStack(alignment: .top, spacing: 12) {
            SkeletonCircle(size: 40)

            VStack(alignment: .leading, spacing: 8) {
                SkeletonLine(width: 160, height: 12)
                SkeletonLine(width: 220, height: 10)
                SkeletonLine(width: 60, height: 9)
            }

            Spacer()
        }
        .padding(CrateTheme.Spacing.cardPadding)
        .background(CrateColors.surface)
        .cornerRadius(CrateTheme.CornerRadius.medium)
    }

    // MARK: - Notification List

    private var notificationList: some View {
        ScrollView {
            LazyVStack(spacing: CrateTheme.Spacing.cardGap) {
                ForEach(viewModel.notifications) { notification in
                    notificationCard(notification)
                        .onAppear {
                            if notification.id == viewModel.notifications.last?.id && viewModel.hasMore {
                                Task { await viewModel.loadMore() }
                            }
                        }
                }

                if viewModel.isLoadingMore {
                    skeletonNotificationCard
                }
            }
            .padding(.horizontal, CrateTheme.Spacing.screenMargin)
            .padding(.top, 4)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Notification Card

    private func notificationCard(_ notification: AppNotification) -> some View {
        Button {
            Task { await viewModel.markAsRead(id: notification.id) }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                // Type icon
                ZStack {
                    Circle()
                        .fill(CrateColors.accentGlow)
                        .frame(width: 40, height: 40)

                    Image(systemName: notification.type?.iconName ?? "bell.fill")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(CrateColors.accent)
                }

                // Content
                VStack(alignment: .leading, spacing: CrateTheme.Spacing.textGapSmall) {
                    Text(notification.title)
                        .font(CrateTypography.body)
                        .fontWeight(notification.isRead ? .regular : .semibold)
                        .foregroundColor(CrateColors.textPrimary)
                        .lineLimit(1)

                    Text(notification.body)
                        .font(CrateTypography.caption)
                        .foregroundColor(CrateColors.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(notification.timeAgo)
                        .font(CrateTypography.timestamp)
                        .foregroundColor(CrateColors.textMuted)
                }

                Spacer(minLength: 0)

                // Unread dot
                if !notification.isRead {
                    Circle()
                        .fill(CrateColors.accent)
                        .frame(width: 8, height: 8)
                        .padding(.top, 6)
                }
            }
            .padding(CrateTheme.Spacing.cardPadding)
            .background(
                notification.isRead
                    ? CrateColors.surface
                    : CrateColors.surface.overlay(CrateColors.accentGlow.opacity(0.3))
            )
            .cornerRadius(CrateTheme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.medium)
                    .stroke(
                        notification.isRead ? CrateColors.border : CrateColors.accent.opacity(0.2),
                        lineWidth: 0.5
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
