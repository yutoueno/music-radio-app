import SwiftUI

struct CrateLogo: View {

    enum Size {
        /// Navigation bar / compact contexts — 18pt
        case small
        /// Splash screen / hero — 28pt
        case medium

        var fontSize: CGFloat {
            switch self {
            case .small: return 18
            case .medium: return 28
            }
        }

        var tracking: CGFloat {
            switch self {
            case .small: return 3.0
            case .medium: return 4.0
            }
        }
    }

    let size: Size

    init(size: Size = .medium) {
        self.size = size
    }

    var body: some View {
        Text("CRATE")
            .font(.custom("SpaceGrotesk-Bold", size: size.fontSize))
            .tracking(size.tracking)
            .foregroundColor(CrateColors.textPrimary)
    }
}

// MARK: - Previews

#Preview("Medium") {
    CrateLogo(size: .medium)
        .padding()
        .background(CrateColors.void)
}

#Preview("Small") {
    CrateLogo(size: .small)
        .padding()
        .background(CrateColors.void)
}
