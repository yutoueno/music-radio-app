import SwiftUI

struct TrackRow: View {
    let track: ProgramTrack
    let index: Int
    let isActive: Bool
    let currentRadioTime: TimeInterval
    let onPlay: () -> Void

    var body: some View {
        TrackCard(
            track: track,
            isActive: isActive,
            onTap: onPlay
        )
    }
}
