import SwiftUI

struct FollowButton: View {
    let isFollowing: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: isFollowing ? "checkmark" : "plus")
                    .font(.caption)
                Text(isFollowing ? "Following" : "Follow")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(isFollowing ? Color(.systemGray5) : Color.accentColor)
            .foregroundColor(isFollowing ? .primary : .white)
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isFollowing)
    }
}
