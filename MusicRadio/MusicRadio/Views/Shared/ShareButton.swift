import SwiftUI

struct ShareButton: View {
    static let shareBaseURL = "https://musicradio.app"

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "square.and.arrow.up")
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Share")
    }

    /// Convenience initializer that presents a share sheet for a program.
    init(program: Program) {
        self.action = {
            let broadcasterName = program.broadcaster?.nickname ?? "someone"
            let shareText = "\"\(program.title)\" by \(broadcasterName) on Music Radio"
            let shareURL = program.shareUrl.flatMap { URL(string: $0) }
                ?? URL(string: "\(ShareButton.shareBaseURL)/programs/\(program.id)")!

            let items: [Any] = [shareText, shareURL]
            ShareButton.presentShareSheet(items: items)
        }
    }

    /// Convenience initializer for sharing a broadcaster profile.
    init(broadcaster: Broadcaster) {
        self.action = {
            let shareText = "\(broadcaster.nickname) on Music Radio"
            let shareURL = URL(string: "\(ShareButton.shareBaseURL)/broadcasters/\(broadcaster.id)")!

            let items: [Any] = [shareText, shareURL]
            ShareButton.presentShareSheet(items: items)
        }
    }

    /// Generic action initializer for backward compatibility.
    init(action: @escaping () -> Void) {
        self.action = action
    }

    // MARK: - Share Sheet Presentation

    private static func presentShareSheet(items: [Any]) {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return
        }

        // Find the topmost presented view controller
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        // iPad popover
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topVC.view
            popover.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        topVC.present(activityVC, animated: true)
    }
}
