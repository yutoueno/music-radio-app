import SwiftUI

struct FollowButton: View {
    var isFollowing: Bool
    var onToggle: ((Bool) -> Void)? = nil

    var body: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            onToggle?(!isFollowing)
        } label: {
            Text(isFollowing ? "Following" : "Follow")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(
                    isFollowing ? CrateColors.void : CrateColors.textPrimary
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(isFollowing ? CrateColors.accent : Color.clear)
                )
                .overlay(
                    Capsule()
                        .stroke(
                            isFollowing ? Color.clear : CrateColors.textTertiary,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isFollowing)
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 16) {
        FollowButton(isFollowing: false, onToggle: { _ in })
        FollowButton(isFollowing: true, onToggle: { _ in })
    }
    .padding()
    .background(CrateColors.void)
}
