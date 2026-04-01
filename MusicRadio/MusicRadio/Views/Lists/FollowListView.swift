import SwiftUI

struct FollowListView: View {
    @StateObject private var viewModel = FollowsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            CrateColors.void.ignoresSafeArea()

            if viewModel.isLoading && viewModel.broadcasters.isEmpty {
                loadingState
            } else if viewModel.broadcasters.isEmpty {
                EmptyStateView(
                    icon: "person.2",
                    title: "Not Following Anyone",
                    subtitle: "Follow creators to see their latest shows",
                    actionTitle: "Discover Creators",
                    onAction: { dismiss() }
                )
            } else {
                broadcasterList
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                crateBackButton { dismiss() }
            }
            ToolbarItem(placement: .principal) {
                Text("FOLLOWING")
                    .font(.custom("SpaceGrotesk-Medium", size: 11))
                    .tracking(2)
                    .foregroundColor(CrateColors.textSecondary)
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .onFirstAppear {
            await viewModel.loadFollows()
        }
        .errorAlert(error: $viewModel.errorMessage)
    }

    // MARK: - Broadcaster List

    private var broadcasterList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.broadcasters) { broadcaster in
                    NavigationLink(destination: BroadcasterView(broadcasterId: broadcaster.id)) {
                        creatorRow(broadcaster)
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        if broadcaster.id == viewModel.broadcasters.last?.id && viewModel.hasMore {
                            Task { await viewModel.loadMore() }
                        }
                    }
                }

                if viewModel.isLoadingMore {
                    ProgressView()
                        .tint(CrateColors.textTertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
            }
            .padding(.horizontal, CrateTheme.Spacing.screenMargin)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Creator Row

    private func creatorRow(_ broadcaster: Broadcaster) -> some View {
        HStack(spacing: 12) {
            // Avatar
            AsyncImage(url: URL(string: broadcaster.avatarUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure, .empty:
                    ZStack {
                        CrateColors.elevated
                        Image(systemName: "person.fill")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(CrateColors.textTertiary)
                    }
                @unknown default:
                    CrateColors.elevated
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(CrateColors.border, lineWidth: 0.5)
            )

            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(broadcaster.nickname)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(CrateColors.textPrimary)
                    .lineLimit(1)

                Text("\(broadcaster.programCount ?? 0) shows")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(CrateColors.textTertiary)
            }

            Spacer()

            // Unfollow button
            CrateButton(
                title: "Following",
                variant: .secondary,
                size: .compact
            ) {
                Task { await viewModel.unfollow(broadcasterId: broadcaster.id) }
            }
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(CrateColors.borderSubtle)
                .frame(height: 0.5)
                .padding(.leading, 56)
        }
    }

    // MARK: - Loading

    private var loadingState: some View {
        VStack(spacing: 0) {
            ForEach(0..<8, id: \.self) { _ in
                HStack(spacing: 12) {
                    SkeletonView(cornerRadius: 22)
                        .frame(width: 44, height: 44)

                    VStack(alignment: .leading, spacing: 4) {
                        SkeletonView(cornerRadius: 4)
                            .frame(width: 120, height: 14)
                        SkeletonView(cornerRadius: 4)
                            .frame(width: 60, height: 11)
                    }

                    Spacer()
                }
                .padding(.vertical, 10)
            }
        }
        .padding(.horizontal, CrateTheme.Spacing.screenMargin)
        .padding(.top, 8)
    }
}
