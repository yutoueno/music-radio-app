import SwiftUI

struct FavoriteProgramsView: View {
    @StateObject private var viewModel = FavoritesViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.programs.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.programs.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.programs) { program in
                            NavigationLink(destination: ProgramView(programId: program.id)) {
                                ProgramCard(program: program, style: .list)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    Task { await viewModel.removeFavorite(programId: program.id) }
                                } label: {
                                    Label("Unfavorite", systemImage: "heart.slash")
                                }
                            }
                            .onAppear {
                                if program.id == viewModel.programs.last?.id && viewModel.hasMore {
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
                    .padding()
                    .padding(.bottom, 80)
                }
            }
        }
        .navigationTitle("Favorites")
        .refreshable {
            await viewModel.refresh()
        }
        .onFirstAppear {
            await viewModel.loadFavorites()
        }
        .errorAlert(error: $viewModel.errorMessage)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No favorites yet")
                .font(.title3)
                .foregroundColor(.secondary)
            Text("Programs you favorite will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
