import SwiftUI

struct BroadcasterView: View {
    let broadcasterId: String

    @StateObject private var viewModel = BroadcasterViewModel()

    var body: some View {
        ScrollView {
            if viewModel.isLoading && viewModel.broadcaster == nil {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 300)
            } else if let broadcaster = viewModel.broadcaster {
                VStack(spacing: 24) {
                    broadcasterHeader(broadcaster)

                    BroadcasterProgramList(
                        programs: viewModel.programs,
                        isLoadingMore: viewModel.isLoadingMore,
                        hasMore: viewModel.hasMore,
                        onLoadMore: {
                            Task { await viewModel.loadMorePrograms() }
                        }
                    )
                }
                .padding(.bottom, 80)
            }
        }
        .navigationTitle(viewModel.broadcaster?.nickname ?? "Broadcaster")
        .navigationBarTitleDisplayMode(.inline)
        .onFirstAppear {
            await viewModel.loadBroadcaster(id: broadcasterId)
        }
        .errorAlert(error: $viewModel.errorMessage)
    }

    @ViewBuilder
    private func broadcasterHeader(_ broadcaster: Broadcaster) -> some View {
        VStack(spacing: 16) {
            // Avatar
            AsyncImage(url: URL(string: broadcaster.avatarUrl ?? "")) { image in
                image.avatarStyle(size: 80)
            } placeholder: {
                Circle()
                    .fill(Color(.systemGray4))
                    .frame(width: 80, height: 80)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
            }

            // Name
            Text(broadcaster.nickname)
                .font(.title2)
                .fontWeight(.bold)

            if let message = broadcaster.message, !message.isEmpty {
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }

            // Stats
            HStack(spacing: 32) {
                VStack {
                    Text("\(broadcaster.programCount ?? 0)")
                        .font(.headline)
                    Text("Programs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                VStack {
                    Text("\(broadcaster.followerCount)")
                        .font(.headline)
                    Text("Followers")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Follow button
            FollowButton(isFollowing: viewModel.isFollowing) {
                Task { await viewModel.toggleFollow() }
            }
        }
        .padding()
    }
}
