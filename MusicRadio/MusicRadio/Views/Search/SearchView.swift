import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            searchHeader

            // Search bar
            searchBar

            // Genre filter chips
            genreChips

            // Sort options
            sortBar

            // Separator
            Rectangle()
                .fill(CrateColors.border)
                .frame(height: 0.5)

            // Results
            resultsContent
        }
        .background(CrateColors.void)
        .navigationBarHidden(true)
        .onFirstAppear {
            await viewModel.search()
        }
        .errorAlert(error: $viewModel.errorMessage)
    }

    // MARK: - Header

    private var searchHeader: some View {
        HStack {
            Text("SEARCH")
                .crateText(.sectionLabel, color: CrateColors.textSecondary)
            Spacer()
        }
        .padding(.horizontal, CrateTheme.Spacing.screenMargin)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: CrateTheme.Spacing.inline) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(CrateColors.textTertiary)

            TextField("", text: $viewModel.searchText)
                .font(CrateTypography.body)
                .foregroundColor(CrateColors.textPrimary)
                .placeholder(when: viewModel.searchText.isEmpty) {
                    Text("Search programs...")
                        .font(CrateTypography.body)
                        .foregroundColor(CrateColors.textMuted)
                }
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(CrateColors.textTertiary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(CrateColors.elevated)
        .cornerRadius(CrateTheme.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.medium)
                .stroke(CrateColors.border, lineWidth: 0.5)
        )
        .padding(.horizontal, CrateTheme.Spacing.screenMargin)
    }

    // MARK: - Genre Chips

    private var genreChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: CrateTheme.Spacing.inline) {
                ForEach(viewModel.genres) { genre in
                    genreChip(genre)
                }
            }
            .padding(.horizontal, CrateTheme.Spacing.screenMargin)
        }
        .padding(.vertical, 12)
    }

    private func genreChip(_ genre: SearchViewModel.Genre) -> some View {
        let isSelected = viewModel.selectedGenre == genre.id

        return Button {
            viewModel.selectGenre(genre.id)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: genre.iconName)
                    .font(.system(size: 10, weight: .medium))
                Text(genre.name)
                    .font(CrateTypography.caption)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? CrateColors.accent : Color.clear)
            .foregroundColor(isSelected ? CrateColors.void : CrateColors.textSecondary)
            .cornerRadius(CrateTheme.CornerRadius.pill)
            .overlay(
                RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.pill)
                    .stroke(
                        isSelected ? Color.clear : CrateColors.border,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Sort Bar

    private var sortBar: some View {
        HStack(spacing: 0) {
            ForEach(SearchViewModel.SortOption.allCases, id: \.self) { option in
                Button {
                    viewModel.selectSort(option)
                } label: {
                    Text(option.displayName)
                        .font(CrateTypography.meta)
                        .tracking(CrateTypography.captionTracking)
                        .foregroundColor(
                            viewModel.sortBy == option
                                ? CrateColors.accent
                                : CrateColors.textTertiary
                        )
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }

            Spacer()

            Text("\(viewModel.programs.count) results")
                .font(CrateTypography.timestamp)
                .foregroundColor(CrateColors.textMuted)
        }
        .padding(.horizontal, CrateTheme.Spacing.screenMargin)
        .padding(.vertical, 4)
    }

    // MARK: - Results

    @ViewBuilder
    private var resultsContent: some View {
        if viewModel.isLoading && viewModel.programs.isEmpty {
            // Skeleton loading
            ScrollView {
                LazyVStack(spacing: CrateTheme.Spacing.cardGap) {
                    ForEach(0..<6, id: \.self) { _ in
                        SkeletonProgramCard()
                    }
                }
                .padding(.horizontal, CrateTheme.Spacing.screenMargin)
                .padding(.top, CrateTheme.Spacing.screenMargin)
            }
        } else if viewModel.programs.isEmpty {
            EmptyStateView(
                icon: "magnifyingglass",
                title: "No Programs Found",
                subtitle: "Try different keywords or filters"
            )
        } else {
            ScrollView {
                LazyVStack(spacing: CrateTheme.Spacing.cardGap) {
                    ForEach(viewModel.programs) { program in
                        NavigationLink(destination: ProgramView(programId: program.id)) {
                            ProgramCard(program: program)
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            if program.id == viewModel.programs.last?.id && viewModel.hasMore {
                                Task { await viewModel.loadMore() }
                            }
                        }
                    }

                    if viewModel.isLoadingMore {
                        HStack(spacing: CrateTheme.Spacing.inline) {
                            SkeletonProgramCard()
                        }
                    }
                }
                .padding(.horizontal, CrateTheme.Spacing.screenMargin)
                .padding(.top, CrateTheme.Spacing.screenMargin)
                .padding(.bottom, 100)
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
}

// MARK: - Placeholder Modifier

extension View {
    @ViewBuilder
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
