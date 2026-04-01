import SwiftUI

struct CreatorRow: View {
    let broadcaster: Broadcaster
    var isFollowing: Bool = false
    var onTap: (() -> Void)? = nil
    var onFollow: ((Bool) -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 12) {
                AvatarView(
                    url: broadcaster.avatarUrl,
                    name: broadcaster.nickname,
                    size: .medium,
                    borderState: isFollowing ? .followingNoNew : .none
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(broadcaster.nickname)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(CrateColors.textPrimary)
                        .lineLimit(1)

                    Text(followerText)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(CrateColors.textTertiary)
                }

                Spacer()

                if let onFollow {
                    FollowButton(isFollowing: isFollowing) { newState in
                        onFollow(newState)
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var followerText: String {
        let count = broadcaster.followerCount
        if count >= 10000 {
            return String(format: "%.1fK followers", Double(count) / 1000)
        } else if count == 1 {
            return "1 follower"
        } else {
            return "\(count) followers"
        }
    }
}

// MARK: - Simple variant from ProgramBroadcaster

struct CreatorRowSimple: View {
    let broadcaster: ProgramBroadcaster
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 10) {
                AvatarView(
                    url: broadcaster.avatarUrl,
                    name: broadcaster.nickname,
                    size: .small
                )

                Text(broadcaster.nickname)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(CrateColors.textPrimary)
                    .lineLimit(1)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(CrateColors.textDisabled)
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        CreatorRow(
            broadcaster: .preview,
            isFollowing: false,
            onTap: {},
            onFollow: { _ in }
        )

        Divider().overlay(CrateColors.border)

        CreatorRow(
            broadcaster: .previewFollowing,
            isFollowing: true,
            onTap: {},
            onFollow: { _ in }
        )
    }
    .padding()
    .background(CrateColors.void)
}

extension Broadcaster {
    static let preview = Broadcaster(
        id: "b-1",
        nickname: "DJ Midnight",
        avatarUrl: nil,
        message: "Playing smooth jazz every night",
        programCount: 12,
        followerCount: 342,
        isFollowing: false
    )

    static let previewFollowing = Broadcaster(
        id: "b-2",
        nickname: "Lofi Girl",
        avatarUrl: nil,
        message: nil,
        programCount: 45,
        followerCount: 12800,
        isFollowing: true
    )
}
