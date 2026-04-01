import SwiftUI

struct PlayButton: View {
    let isPlaying: Bool
    var size: CGFloat = 44
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: size, height: size)

                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: size * 0.36))
                    .foregroundColor(.white)
                    .offset(x: isPlaying ? 0 : size * 0.04)
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isPlaying)
    }
}
