import SwiftUI

struct MyProgramsView: View {
    @State private var programs: [Program] = []
    @State private var isLoading = false
    @State private var isLoadingMore = false
    @State private var hasMore = true
    @State private var currentPage = 1
    @State private var errorMessage: String?
    @State private var showCreateProgram = false

    private let programRepository: ProgramRepositoryProtocol = ProgramRepository()

    var body: some View {
        Group {
            if isLoading && programs.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if programs.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
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
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .padding()
                    .padding(.bottom, 80)
                }
            }
        }
        .navigationTitle("My Programs")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showCreateProgram = true
                } label: {
                    Image(systemName: "plus")
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

    private func myProgramRow(_ program: Program) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: program.thumbnailUrl ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .overlay {
                        Image(systemName: "radio")
                            .foregroundColor(.secondary)
                    }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(program.title)
                    .font(.headline)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    if let status = program.status {
                        statusBadge(status)
                    }
                    Text(program.durationFormatted)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(program.playCount ?? 0) plays")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func statusBadge(_ status: ProgramStatus) -> some View {
        Text(status.displayName)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(statusColor(status).opacity(0.15))
            .foregroundColor(statusColor(status))
            .cornerRadius(4)
    }

    private func statusColor(_ status: ProgramStatus) -> Color {
        switch status {
        case .draft: return .orange
        case .published: return .green
        case .archived: return .gray
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "radio")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No programs yet")
                .font(.title3)
                .foregroundColor(.secondary)
            Button {
                showCreateProgram = true
            } label: {
                Label("Create Your First Program", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

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
