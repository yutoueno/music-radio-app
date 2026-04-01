import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            searchBar

            // Genre filter chips
            genreChips

            // Sort options
            sortBar

            Divider()

            // Results
            resultsContent
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.large)
        .onFirstAppear {
            await viewModel.search()
        }
        .errorAlert(error: $viewModel.errorMessage)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search programs...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Genre Chips

    private var genreChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(viewModel.genres) { genre in
                    genreChip(genre)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
    }

    private func genreChip(_ genre: SearchViewModel.Genre) -> some View {
        let isSelected = viewModel.selectedGenre == genre.id

        return Button {
            viewModel.selectGenre(genre.id)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: genre.iconName)
                    .font(.caption2)
                Text(genre.name)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Sort Bar

    private var sortBar: some View {
        HStack(spacing: 12) {
            ForEach(SearchViewModel.SortOption.allCases, id: \.self) { option in
                Button {
                    viewModel.selectSort(option)
                } label: {
                    Text(option.displayName)
                        .font(.subheadline)
                        .fontWeight(viewModel.sortBy == option ? .semibold : .regular)
                        .foregroundColor(viewModel.sortBy == option ? .accentColor : .secondary)
                }
                .buttonStyle(.plain)
            }

            Spacer()

            Text("\(viewModel.programs.count) results")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    // MARK: - Results

    @ViewBuilder
    private var resultsContent: some View {
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
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No programs found")
                .font(.title3)
                .foregroundColor(.secondary)
            Text("Try different keywords or filters")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
