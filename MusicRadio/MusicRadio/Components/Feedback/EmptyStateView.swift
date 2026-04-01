import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var actionTitle: String? = nil
    var onAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 40, weight: .thin))
                .foregroundColor(CrateColors.textDisabled)

            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(CrateColors.textTertiary)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(CrateColors.textDisabled)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
            }
            .padding(.horizontal, 40)

            if let actionTitle, let onAction {
                CrateButton(
                    title: actionTitle,
                    variant: .secondary,
                    size: .compact,
                    action: onAction
                )
                .padding(.top, 4)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preset Empty States

extension EmptyStateView {
    static var noPrograms: EmptyStateView {
        EmptyStateView(
            icon: "radio",
            title: "No Programs Yet",
            subtitle: "Discover new radio programs and start listening"
        )
    }

    static var noFavorites: EmptyStateView {
        EmptyStateView(
            icon: "heart",
            title: "No Favorites",
            subtitle: "Programs you favorite will appear here"
        )
    }

    static var noFollowing: EmptyStateView {
        EmptyStateView(
            icon: "person.2",
            title: "Not Following Anyone",
            subtitle: "Follow creators to see their latest shows"
        )
    }

    static var noSearchResults: EmptyStateView {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No Results",
            subtitle: "Try a different search term"
        )
    }
}

// MARK: - Preview

#Preview {
    VStack {
        EmptyStateView(
            icon: "heart",
            title: "No Favorites",
            subtitle: "Programs you favorite will appear here",
            actionTitle: "Browse Programs",
            onAction: {}
        )
    }
    .background(CrateColors.void)
}
