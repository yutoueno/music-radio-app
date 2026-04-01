import SwiftUI

struct FollowListView: View {
    @StateObject private var viewModel = FollowsViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.broadcasters.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.broadcasters.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.broadcasters) { broadcaster in
                            NavigationLink(destination: BroadcasterView(broadcasterId: broadcaster.id)) {
                                broadcasterRow(broadcaster)
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
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .padding()
                    .padding(.bottom, 80)
                }
            }
        }
        .navigationTitle("Following")
        .refreshable {
            await viewModel.refresh()
        }
        .onFirstAppear {
            await viewModel.loadFollows()
        }
        .errorAlert(error: $viewModel.errorMessage)
    }

    private func broadcasterRow(_ broadcaster: Broadcaster) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: broadcaster.avatarUrl ?? "")) { image in
                image.avatarStyle(size: 50)
            } placeholder: {
                Circle()
                    .fill(Color(.systemGray4))
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                    }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(broadcaster.nickname)
                    .font(.headline)

                Text("\(broadcaster.programCount ?? 0) programs")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button {
                Task { await viewModel.unfollow(broadcasterId: broadcaster.id) }
            } label: {
                Text("Following")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray5))
                    .cornerRadius(16)
            }
        }
        .padding(.vertical, 4)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("Not following anyone yet")
                .font(.title3)
                .foregroundColor(.secondary)
            Text("Follow broadcasters to see their updates")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
