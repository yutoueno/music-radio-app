import SwiftUI

struct BroadcasterView: View {
    let broadcasterId: String

    @StateObject private var viewModel = BroadcasterViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if viewModel.isLoading && viewModel.broadcaster == nil {
                ProgressView()
                    .tint(CrateColors.textSecondary)
                    .frame(maxWidth: .infinity, minHeight: 400)
            } else if let broadcaster = viewModel.broadcaster {
                VStack(spacing: 0) {
                    // Wallpaper hero area
                    wallpaperHero(broadcaster)

                    // Content below wallpaper
                    VStack(alignment: .leading, spacing: CrateTheme.Spacing.sectionGap) {
                        // Follow button
                        HStack {
                            FollowButton(
                                isFollowing: viewModel.isFollowing,
                                onToggle: { _ in
                                    Task { await viewModel.toggleFollow() }
                                }
                            )
                            Spacer()
                        }
                        .padding(.top, 16)

                        // Message
                        if let message = broadcaster.message, !message.isEmpty {
                            Text(message)
                                .crateText(.body, color: CrateColors.textSecondary)
                                .lineLimit(5)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        // Shows section
                        VStack(alignment: .leading, spacing: CrateTheme.Spacing.cardGap) {
                            Text("SHOWS")
                                .crateText(.sectionLabel, color: CrateColors.textTertiary)

                            BroadcasterProgramList(
                                programs: viewModel.programs,
                                isLoadingMore: viewModel.isLoadingMore,
                                hasMore: viewModel.hasMore,
                                onLoadMore: {
                                    Task { await viewModel.loadMorePrograms() }
                                }
                            )
                        }
                    }
                    .crateScreenPadding()
                }
                .padding(.bottom, 100)
            }
        }
        .background(CrateColors.void.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                // Empty to hide default title; name is in the hero
                Text("")
            }
        }
        .onFirstAppear {
            await viewModel.loadBroadcaster(id: broadcasterId)
        }
        .errorAlert(error: $viewModel.errorMessage)
    }

    // MARK: - Wallpaper Hero

    @ViewBuilder
    private func wallpaperHero(_ broadcaster: Broadcaster) -> some View {
        ZStack(alignment: .bottomLeading) {
            // Wallpaper background
            GeometryReader { geo in
                ZStack {
                    CrateColors.elevated
                    // Placeholder or wallpaper image could go here
                    // For now, use a subtle gradient background
                    LinearGradient(
                        colors: [
                            CrateColors.accent.opacity(0.15),
                            CrateColors.elevated
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                .frame(width: geo.size.width, height: 200)
            }
            .frame(height: 200)

            // Dark gradient overlay fading to void
            LinearGradient(
                colors: [
                    Color.clear,
                    CrateColors.void.opacity(0.6),
                    CrateColors.void
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Avatar + Name + Followers
            HStack(spacing: 14) {
                AvatarView(
                    url: broadcaster.avatarUrl,
                    name: broadcaster.nickname,
                    size: .medium
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(broadcaster.nickname)
                        .crateText(.h2)
                        .lineLimit(1)

                    Text("\(broadcaster.followerCount) followers")
                        .crateText(.caption, color: CrateColors.textSecondary)
                }
            }
            .padding(.horizontal, CrateTheme.Spacing.screenMargin)
            .padding(.bottom, 16)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        BroadcasterView(broadcasterId: "preview-1")
    }
}
