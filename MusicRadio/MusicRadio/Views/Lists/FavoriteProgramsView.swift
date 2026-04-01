import SwiftUI

struct FavoriteProgramsView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            CrateColors.void.ignoresSafeArea()

            if viewModel.isLoading && viewModel.programs.isEmpty {
                loadingState
            } else if viewModel.programs.isEmpty {
                EmptyStateView(
                    icon: "heart",
                    title: "No Favorites",
                    subtitle: "Programs you favorite will appear here",
                    actionTitle: "Browse Programs",
                    onAction: { dismiss() }
                )
            } else {
                programList
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                crateBackButton { dismiss() }
            }
            ToolbarItem(placement: .principal) {
                Text("FAVORITES")
                    .font(.custom("SpaceGrotesk-Medium", size: 11))
                    .tracking(2)
                    .foregroundColor(CrateColors.textSecondary)
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .onFirstAppear {
            await viewModel.loadFavorites()
        }
        .errorAlert(error: $viewModel.errorMessage)
    }

    // MARK: - Program List

    private var programList: some View {
        List {
            ForEach(viewModel.programs) { program in
                NavigationLink(destination: ProgramView(programId: program.id)) {
                    ProgramCard(program: program)
                }
                .listRowBackground(CrateColors.void)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(
                    top: CrateTheme.Spacing.cardGap / 2,
                    leading: CrateTheme.Spacing.screenMargin,
                    bottom: CrateTheme.Spacing.cardGap / 2,
                    trailing: CrateTheme.Spacing.screenMargin
                ))
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.removeFavorite(programId: program.id)
                        }
                    } label: {
                        Label("Unfavorite", systemImage: "heart.slash")
                    }
                    .tint(CrateColors.error)
                }
                .onAppear {
                    if program.id == viewModel.programs.last?.id && viewModel.hasMore {
                        Task { await viewModel.loadMore() }
                    }
                }
            }

            if viewModel.isLoadingMore {
                ProgressView()
                    .tint(CrateColors.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .listRowBackground(CrateColors.void)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Loading

    private var loadingState: some View {
        VStack(spacing: 12) {
            ForEach(0..<5, id: \.self) { _ in
                SkeletonView(cornerRadius: CrateTheme.CornerRadius.large)
                    .frame(height: 76)
            }
        }
        .padding(.horizontal, CrateTheme.Spacing.screenMargin)
        .padding(.top, 8)
    }
}
