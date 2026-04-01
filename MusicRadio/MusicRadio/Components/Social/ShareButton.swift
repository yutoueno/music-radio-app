import SwiftUI

struct ShareButton: View {
    let shareURL: String?
    let shareText: String?
    var size: CGFloat = 18

    init(
        url: String? = nil,
        text: String? = nil,
        size: CGFloat = 18
    ) {
        self.shareURL = url
        self.shareText = text
        self.size = size
    }

    var body: some View {
        Button {
            presentShareSheet()
        } label: {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: size, weight: .medium))
                .foregroundColor(CrateColors.textTertiary)
        }
        .buttonStyle(.plain)
        .frame(width: 44, height: 44)
    }

    private func presentShareSheet() {
        var items: [Any] = []

        if let text = shareText {
            items.append(text)
        }
        if let urlString = shareURL, let url = URL(string: urlString) {
            items.append(url)
        }

        guard !items.isEmpty else { return }

        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )

        // Find the topmost view controller to present from
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController
        else { return }

        var presenter = rootVC
        while let presented = presenter.presentedViewController {
            presenter = presented
        }

        // iPad popover support
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = presenter.view
            popover.sourceRect = CGRect(
                x: presenter.view.bounds.midX,
                y: presenter.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        presenter.present(activityVC, animated: true)
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 16) {
        ShareButton(url: "https://example.com/program/1", text: "Check out this radio show!")
        ShareButton(url: nil, text: "Share this program")
    }
    .padding()
    .background(CrateColors.void)
}
