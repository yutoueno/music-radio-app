import SwiftUI

struct RecommendedSection: View {
    let programs: [Program]
    let isLoading: Bool
    var isLoadingMore: Bool = false
    var hasMorePages: Bool = true
    var onLoadMore: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECOMMENDED")
                .crateText(.sectionLabel, color: CrateColors.textTertiary)
                .crateScreenPadding()

            if isLoading && programs.isEmpty {
                // Skeleton loading
                VStack(spacing: CrateTheme.Spacing.cardGap) {
                    ForEach(0..<5, id: \.self) { _ in
                        SkeletonProgramCard()
                    }
                }
                .crateScreenPadding()
            } else if programs.isEmpty {
                emptyState
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
                            // Trigger infinite scroll when near end
                            if program.id == programs.last?.id, hasMorePages {
                                onLoadMore?()
                            }
                        }
                    }

                    // Loading more indicator
                    if isLoadingMore {
                        HStack {
                            Spacer()
                            ProgressView()
                                .tint(CrateColors.accent)
                            Spacer()
                        }
                        .padding(.vertical, 16)
                    }
                }
                .crateScreenPadding()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "radio")
                .font(.system(size: 32))
                .foregroundColor(CrateColors.textMuted)

            Text("No recommendations yet")
                .crateText(.caption, color: CrateColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }
}

// MARK: - Skeleton Program Card

private struct SkeletonProgramCard: View {
    var body: some View {
        HStack(spacing: 12) {
            SkeletonView(cornerRadius: 6)
                .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 6) {
                SkeletonView(cornerRadius: 4)
                    .frame(width: 160, height: 13)

                SkeletonView(cornerRadius: 4)
                    .frame(width: 100, height: 11)
            }

            Spacer()
        }
        .padding(12)
        .background(CrateColors.surface)
        .cornerRadius(CrateTheme.CornerRadius.large)
    }
}
