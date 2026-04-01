import SwiftUI

struct MiniPlayerView: View {
    @EnvironmentObject var coordinator: DualPlaybackCoordinator
    @EnvironmentObject var programViewModel: ProgramViewModel
    @State private var showFullPlayer = false

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: geometry.size.width * CGFloat(coordinator.progress), height: 2)
            }
            .frame(height: 2)

            HStack(spacing: 12) {
                // Thumbnail
                if let program = programViewModel.currentProgram {
                    AsyncImage(url: URL(string: program.thumbnailUrl ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.systemGray5))
                            .overlay {
                                Image(systemName: "radio")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }

                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(programViewModel.currentProgram?.title ?? "Not Playing")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)

                    if let track = coordinator.trackForCurrentTime() {
                        HStack(spacing: 4) {
                            Image(systemName: "music.note")
                                .font(.caption2)
                            Text(track.trackName)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    } else {
                        Text(programViewModel.currentProgram?.broadcaster?.nickname ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Controls
                HStack(spacing: 20) {
                    PlayButton(
                        isPlaying: coordinator.playbackState == .playing,
                        size: 36
                    ) {
                        coordinator.togglePlayPause()
                    }

                    Button {
                        coordinator.stopAll()
                        programViewModel.clearCurrentProgram()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: -2)
        )
        .onTapGesture {
            if let program = programViewModel.currentProgram {
                showFullPlayer = true
            }
        }
        .sheet(isPresented: $showFullPlayer) {
            if let program = programViewModel.currentProgram {
                NavigationStack {
                    ProgramView(programId: program.id)
                        .environmentObject(coordinator)
                        .environmentObject(programViewModel)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    showFullPlayer = false
                                } label: {
                                    Image(systemName: "chevron.down")
                                }
                            }
                        }
                }
            }
        }
    }
}
