import SwiftUI

struct FavoriteButton: View {
    @Binding var isFavorited: Bool
    var size: CGFloat = 22
    var onToggle: ((Bool) -> Void)? = nil

    @State private var animationScale: CGFloat = 1.0

    var body: some View {
        Button {
            let newState = !isFavorited
            isFavorited = newState

            // Scale bounce animation
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                animationScale = 1.3
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                    animationScale = 1.0
                }
            }

            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()

            onToggle?(newState)
        } label: {
            Image(systemName: isFavorited ? "heart.fill" : "heart")
                .font(.system(size: size, weight: .medium))
                .foregroundColor(
                    isFavorited ? CrateColors.accent : CrateColors.textTertiary
                )
                .scaleEffect(animationScale)
                .contentShape(Rectangle().size(width: 44, height: 44))
        }
        .buttonStyle(.plain)
        .frame(width: 44, height: 44)
    }
}

// MARK: - Non-binding variant

struct FavoriteButtonAction: View {
    let isFavorited: Bool
    var size: CGFloat = 22
    let action: () -> Void

    @State private var animationScale: CGFloat = 1.0

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                animationScale = 1.3
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                    animationScale = 1.0
                }
            }

            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()

            action()
        } label: {
            Image(systemName: isFavorited ? "heart.fill" : "heart")
                .font(.system(size: size, weight: .medium))
                .foregroundColor(
                    isFavorited ? CrateColors.accent : CrateColors.textTertiary
                )
                .scaleEffect(animationScale)
        }
        .buttonStyle(.plain)
        .frame(width: 44, height: 44)
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State var fav1 = false
        @State var fav2 = true

        var body: some View {
            HStack(spacing: 20) {
                FavoriteButton(isFavorited: $fav1)
                FavoriteButton(isFavorited: $fav2)
            }
            .padding()
            .background(CrateColors.void)
        }
    }
    return PreviewWrapper()
}
