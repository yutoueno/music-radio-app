import SwiftUI

struct TopView: View {
    @StateObject private var viewModel = TopViewModel()
    @EnvironmentObject var programViewModel: ProgramViewModel
    @EnvironmentObject var coordinator: DualPlaybackCoordinator

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                RecommendedSection(
                    programs: viewModel.recommendedPrograms,
                    isLoading: viewModel.isLoadingRecommended
                )

                FavoritesSection(
                    programs: viewModel.favoritePrograms,
                    isLoading: viewModel.isLoadingFavorites
                )

                followsSection
            }
            .padding(.vertical)
            .padding(.bottom, programViewModel.currentProgram != nil ? 80 : 0)
        }
        .navigationTitle("Music Radio")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SearchView()) {
                    Image(systemName: "magnifyingglass")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: NotificationsView()) {
                    Image(systemName: "bell")
                }
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .onFirstAppear {
            await viewModel.loadAll()
        }
        .errorAlert(error: $viewModel.errorMessage)
    }

    @ViewBuilder
    private var followsSection: some View {
        if !viewModel.followingBroadcasters.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Following")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    NavigationLink("See All") {
                        FollowListView()
                    }
                    .font(.subheadline)
                }
                .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(viewModel.followingBroadcasters) { broadcaster in
                            NavigationLink(destination: BroadcasterView(broadcasterId: broadcaster.id)) {
                                BroadcasterCard(broadcaster: broadcaster)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
