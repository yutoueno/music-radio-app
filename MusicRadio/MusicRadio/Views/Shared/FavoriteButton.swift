import SwiftUI

struct FavoriteButton: View {
    let isFavorited: Bool
    let action: () -> Void

    @State private var animationScale: CGFloat = 1.0

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                animationScale = 1.3
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    animationScale = 1.0
                }
            }
            action()
        }) {
            Image(systemName: isFavorited ? "heart.fill" : "heart")
                .font(.title3)
                .foregroundColor(isFavorited ? .red : .secondary)
                .scaleEffect(animationScale)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isFavorited ? "Remove from favorites" : "Add to favorites")
    }
}
