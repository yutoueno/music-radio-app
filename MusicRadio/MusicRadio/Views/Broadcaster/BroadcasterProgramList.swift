import SwiftUI

struct BroadcasterProgramList: View {
    let programs: [Program]
    let isLoadingMore: Bool
    let hasMore: Bool
    let onLoadMore: () -> Void

    var body: some View {
        if programs.isEmpty {
            // Empty state
            VStack(spacing: CrateTheme.Spacing.inline) {
                Image(systemName: "radio")
                    .font(.system(size: 32))
                    .foregroundColor(CrateColors.textTertiary)

                Text("No shows yet")
                    .crateText(.caption, color: CrateColors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
        } else {
            LazyVStack(spacing: CrateTheme.Spacing.cardGap) {
                ForEach(programs) { program in
                    NavigationLink(destination: ProgramView(programId: program.id)) {
                        ProgramCard(
                            program: program,
                            onTap: nil,
                            onPlay: nil,
                            isPlaying: false
                        )
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        if program.id == programs.last?.id && hasMore {
                            onLoadMore()
                        }
                    }
                }

                if isLoadingMore {
                    ProgressView()
                        .tint(CrateColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, CrateTheme.Spacing.cardPadding)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        BroadcasterProgramList(
            programs: [.preview],
            isLoadingMore: false,
            hasMore: false,
            onLoadMore: {}
        )
        .crateScreenPadding()
    }
    .background(CrateColors.void)
}
