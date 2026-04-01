import SwiftUI

// NOTE: This file has been repurposed from FavoritesSection to FollowingSection.
// The FollowingSection is now embedded directly in TopView.swift as a private struct.
// This file is kept for backward compatibility but is no longer used directly
// from the TopView. The horizontal avatar scroll "Following" section
// is defined in TopView.swift.

// If you need a standalone favorites section elsewhere, use this:

struct FavoritesSection: View {
    let programs: [Program]
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("FAVORITES")
                    .crateText(.sectionLabel, color: CrateColors.textTertiary)

                Spacer()

                if !programs.isEmpty {
                    NavigationLink("See All") {
                        FavoriteProgramsView()
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(CrateColors.accent)
                }
            }
            .crateScreenPadding()

            if isLoading && programs.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                        .tint(CrateColors.accent)
                    Spacer()
                }
                .frame(height: 160)
            } else if programs.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "heart")
                        .font(.system(size: 28))
                        .foregroundColor(CrateColors.textMuted)

                    Text("No favorites yet")
                        .crateText(.caption, color: CrateColors.textTertiary)

                    Text("Tap the heart on programs you love")
                        .crateText(.meta, color: CrateColors.textMuted)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 160)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: CrateTheme.Spacing.cardGap) {
                        ForEach(programs) { program in
                            NavigationLink(destination: ProgramView(programId: program.id)) {
                                ProgramCard(
                                    program: program,
                                    onTap: nil,
                                    onPlay: nil,
                                    isPlaying: false
                                )
                                .frame(width: 260)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .crateScreenPadding()
                }
            }
        }
    }
}
