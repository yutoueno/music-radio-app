import SwiftUI

struct MyProgramsView: View {
    @State private var programs: [Program] = []
    @State private var isLoading = false
    @State private var isLoadingMore = false
    @State private var hasMore = true
    @State private var currentPage = 1
    @State private var errorMessage: String?
    @State private var showCreateProgram = false
    @Environment(\.dismiss) private var dismiss

    private let programRepository: ProgramRepositoryProtocol = ProgramRepository()

    var body: some View {
        ZStack {
            CrateColors.void.ignoresSafeArea()

            if isLoading && programs.isEmpty {
                loadingState
            } else if programs.isEmpty {
                EmptyStateView(
                    icon: "radio",
                    title: "No Shows Yet",
                    subtitle: "Create your first radio show and share your music taste",
                    actionTitle: "Create Show",
                    onAction: { showCreateProgram = true }
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
                Text("MY SHOWS")
                    .font(.custom("SpaceGrotesk-Medium", size: 11))
                    .tracking(2)
                    .foregroundColor(CrateColors.textSecondary)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showCreateProgram = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(CrateColors.accent)
                }
            }
        }
        .sheet(isPresented: $showCreateProgram) {
            NavigationStack {
                ProgramEditView()
            }
        }
        .refreshable {
            await loadPrograms()
        }
        .onFirstAppear {
            await loadPrograms()
        }
        .errorAlert(error: $errorMessage)
    }

    // MARK: - Program List

    private var programList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: CrateTheme.Spacing.cardGap) {
                ForEach(programs) { program in
                    NavigationLink(destination: ProgramEditView(editingProgramId: program.id)) {
                        myProgramRow(program)
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        if program.id == programs.last?.id && hasMore {
                            Task { await loadMore() }
                        }
                    }
                }

                if isLoadingMore {
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

    // MARK: - Program Row

    private func myProgramRow(_ program: Program) -> some View {
        HStack(spacing: 12) {
            // Thumbnail
            ProgramThumbnail(
                url: program.thumbnailUrl,
                size: 56,
                cornerRadius: 8
            )

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(program.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(CrateColors.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    if let status = program.status {
                        statusBadge(status)
                    }

                    Text(program.durationFormatted)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(CrateColors.textTertiary)

                    HStack(spacing: 3) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 8))
                        Text("\(program.playCount ?? 0)")
                            .font(.system(size: 11, weight: .regular))
                    }
                    .foregroundColor(CrateColors.textTertiary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(CrateColors.textDisabled)
        }
        .padding(CrateTheme.Spacing.cardPadding)
        .background(CrateColors.surface)
        .cornerRadius(CrateTheme.CornerRadius.large)
    }

    // MARK: - Status Badge

    private func statusBadge(_ status: ProgramStatus) -> some View {
        Text(status.displayName.uppercased())
            .font(.system(size: 9, weight: .bold))
            .tracking(0.5)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(statusColor(status).opacity(0.15))
            .foregroundColor(statusColor(status))
            .cornerRadius(4)
    }

    private func statusColor(_ status: ProgramStatus) -> Color {
        switch status {
        case .draft:     return Color(red: 255/255, green: 180/255, blue: 50/255)
        case .published: return CrateColors.success
        case .archived:  return CrateColors.textTertiary
        }
    }

    // MARK: - Loading

    private var loadingState: some View {
        VStack(spacing: CrateTheme.Spacing.cardGap) {
            ForEach(0..<5, id: \.self) { _ in
                SkeletonView(cornerRadius: CrateTheme.CornerRadius.large)
                    .frame(height: 80)
            }
        }
        .padding(.horizontal, CrateTheme.Spacing.screenMargin)
        .padding(.top, 8)
    }

    // MARK: - Data Loading

    private func loadPrograms() async {
        isLoading = true
        currentPage = 1
        do {
            let response = try await programRepository.fetchMyPrograms(page: 1)
            programs = response.data
            hasMore = response.meta.hasNext
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func loadMore() async {
        guard hasMore, !isLoadingMore else { return }
        isLoadingMore = true
        let nextPage = currentPage + 1
        do {
            let response = try await programRepository.fetchMyPrograms(page: nextPage)
            programs.append(contentsOf: response.data)
            hasMore = response.meta.hasNext
            currentPage = nextPage
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoadingMore = false
    }
}
