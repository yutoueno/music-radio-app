import SwiftUI

struct AvatarView: View {

    enum Size {
        case small   // 28pt
        case medium  // 44pt

        var dimension: CGFloat {
            switch self {
            case .small:  return 28
            case .medium: return 44
            }
        }

        var initialFontSize: CGFloat {
            switch self {
            case .small:  return 11
            case .medium: return 17
            }
        }
    }

    enum BorderState {
        case none
        case followingNewShow  // 1.5px accent border
        case followingNoNew    // 1px #333 border
    }

    let url: String?
    let name: String
    var size: Size = .medium
    var borderState: BorderState = .none

    var body: some View {
        Group {
            if let urlString = url, let imageURL = URL(string: urlString) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        initialsPlaceholder
                    case .empty:
                        SkeletonView(cornerRadius: size.dimension / 2)
                    @unknown default:
                        initialsPlaceholder
                    }
                }
            } else {
                initialsPlaceholder
            }
        }
        .frame(width: size.dimension, height: size.dimension)
        .clipShape(Circle())
        .overlay(borderOverlay)
    }

    @ViewBuilder
    private var borderOverlay: some View {
        switch borderState {
        case .none:
            EmptyView()
        case .followingNewShow:
            Circle()
                .stroke(CrateColors.accent, lineWidth: 1.5)
        case .followingNoNew:
            Circle()
                .stroke(CrateColors.textDisabled, lineWidth: 1)
        }
    }

    private var initialsPlaceholder: some View {
        ZStack {
            CrateColors.elevated
            Text(initialLetter)
                .font(.system(size: size.initialFontSize, weight: .medium))
                .foregroundColor(CrateColors.textTertiary)
        }
    }

    private var initialLetter: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else { return "?" }
        return String(first).uppercased()
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 16) {
        // Small, no border
        AvatarView(url: nil, name: "Alice", size: .small)

        // Medium, no border
        AvatarView(url: nil, name: "Bob", size: .medium)

        // Following + new show
        AvatarView(
            url: nil,
            name: "Charlie",
            size: .medium,
            borderState: .followingNewShow
        )

        // Following, no new
        AvatarView(
            url: nil,
            name: "Diana",
            size: .medium,
            borderState: .followingNoNew
        )
    }
    .padding()
    .background(CrateColors.void)
}
