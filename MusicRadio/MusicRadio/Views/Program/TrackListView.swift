import SwiftUI

struct TrackListView: View {
    let tracks: [ProgramTrack]
    let activeTrackIndex: Int?
    let currentRadioTime: TimeInterval
    let onPlayTrack: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tracks")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(tracks.count) tracks")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            LazyVStack(spacing: 8) {
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
            .padding(.horizontal)
        }
        .padding(.top, 16)
    }
}
