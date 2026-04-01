import SwiftUI

struct TopView: View {
    @StateObject private var viewModel = TopViewModel()
    @EnvironmentObject var programViewModel: ProgramViewModel
    @EnvironmentObject var coordinator: DualPlaybackCoordinator

    // MARK: - Pagination State

    @State private var currentPage: Int = 1
    @State private var isLoadingMore: Bool = false
    @State private var hasMorePages: Bool = true

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: CrateTheme.Spacing.sectionGap) {
                // Custom Header
                crateHeader
                    .padding(.top, 8)

                // Following Section (horizontal avatar scroll)
                FollowingSection(
                    broadcasters: viewModel.followingBroadcasters,
                    isLoading: viewModel.isLoadingFollows
                )

                // Recommended Section (vertical infinite scroll)
                RecommendedSection(
                    programs: viewModel.recommendedPrograms,
                    isLoading: viewModel.isLoadingRecommended,
                    isLoadingMore: isLoadingMore,
                    hasMorePages: hasMorePages,
                    onLoadMore: {
                        Task { await loadMoreRecommended() }
                    }
                )
            }
            .padding(.bottom, programViewModel.currentProgram != nil ? 100 : 40)
        }
        .background(CrateColors.void.ignoresSafeArea())
        .navigationBarHidden(true)
        .refreshable {
            currentPage = 1
            hasMorePages = true
            await viewModel.refresh()
        }
        .onFirstAppear {
            await viewModel.loadAll()
        }
        .errorAlert(error: $viewModel.errorMessage)
    }

    // MARK: - Custom Header

    private var crateHeader: some View {
        HStack {
            CrateLogo(size: .small)

            Spacer()

            NavigationLink(destination: ProfileView()) {
                AvatarView(
                    url: nil,
                    name: "U",
                    size: .small,
                    borderState: .none
                )
            }
            .buttonStyle(.plain)
        }
        .crateScreenPadding()
    }

    // MARK: - Load More

    private func loadMoreRecommended() async {
        guard !isLoadingMore, hasMorePages else { return }
        isLoadingMore = true

        let nextPage = currentPage + 1
        do {
            let response = try await ProgramRepository().fetchRecommendedPrograms(page: nextPage)
            await MainActor.run {
                viewModel.recommendedPrograms.append(contentsOf: response.data)
                hasMorePages = response.meta.hasNext
                currentPage = nextPage
                isLoadingMore = false
            }
        } catch {
            await MainActor.run {
                isLoadingMore = false
            }
        }
    }
}

// MARK: - Following Section (Horizontal Avatar Scroll)

private struct FollowingSection: View {
    let broadcasters: [Broadcaster]
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FOLLOWING")
                .crateText(.sectionLabel, color: CrateColors.textTertiary)
                .crateScreenPadding()

            if isLoading && broadcasters.isEmpty {
                // Skeleton loading
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(0..<6, id: \.self) { _ in
                            SkeletonView(cornerRadius: 22)
                                .frame(width: 44, height: 44)
                        }
                    }
                    .crateScreenPadding()
                }
            } else if broadcasters.isEmpty {
                Text("Follow broadcasters to see them here")
                    .crateText(.caption, color: CrateColors.textMuted)
                    .crateScreenPadding()
                    .padding(.vertical, 8)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(broadcasters) { broadcaster in
                            NavigationLink(destination: BroadcasterView(broadcasterId: broadcaster.id)) {
                                VStack(spacing: 6) {
                                    AvatarView(
                                        url: broadcaster.avatarUrl,
                                        name: broadcaster.nickname,
                                        size: .medium,
                                        borderState: .followingNewShow
                                    )

                                    Text(broadcaster.nickname)
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(CrateColors.textSecondary)
                                        .lineLimit(1)
                                        .frame(width: 52)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .crateScreenPadding()
                }
            }
        }
    }
}
