import SwiftUI

struct TrackListView: View {
    let tracks: [ProgramTrack]
    let activeTrackIndex: Int?
    let currentRadioTime: TimeInterval
    let onPlayTrack: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section label
            Text("TRACKS IN THIS SHOW")
                .crateText(.sectionLabel, color: CrateColors.textTertiary)
                .crateScreenPadding()

            // Track cards
            LazyVStack(spacing: 2) {
                ForEach(Array(tracks.enumerated()), id: \.element.id) { index, track in
                    TrackRow(
                        track: track,
                        index: index,
                        isActive: activeTrackIndex == index,
                        currentRadioTime: currentRadioTime,
                        onPlay: {
                            onPlayTrack(index)
                        }
                    )
                }
            }
            .crateScreenPadding()
        }
    }
}
