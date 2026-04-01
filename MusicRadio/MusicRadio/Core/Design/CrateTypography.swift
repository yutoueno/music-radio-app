import SwiftUI

// MARK: - Font Definitions

enum CrateTypography {

    // MARK: - Letter Spacing Constants (points)

    /// Logo letter spacing — wide, dramatic
    static let logoTracking: CGFloat = 4.0

    /// Section label tracking
    static let sectionTracking: CGFloat = 2.0

    /// Heading tracking — slightly loose
    static let headingTracking: CGFloat = -0.5

    /// Body tracking — default
    static let bodyTracking: CGFloat = 0.0

    /// Caption tracking
    static let captionTracking: CGFloat = 0.2

    /// Timestamp / mono tracking
    static let monoTracking: CGFloat = 0.5

    // MARK: - Fonts

    /// Logo: Space Grotesk Bold, 28pt
    static let logo: Font = .custom("SpaceGrotesk-Bold", size: 28)

    /// Section label: Space Grotesk Medium, 11pt, uppercased
    static let sectionLabel: Font = .custom("SpaceGrotesk-Medium", size: 11)

    /// H1: Space Grotesk Bold, 22pt
    static let h1: Font = .custom("SpaceGrotesk-Bold", size: 22)

    /// H2: Space Grotesk SemiBold, 17pt
    static let h2: Font = .custom("SpaceGrotesk-SemiBold", size: 17)

    /// Body: SF Pro (system), 15pt regular
    static let body: Font = .system(size: 15, weight: .regular)

    /// Caption: SF Pro (system), 13pt regular
    static let caption: Font = .system(size: 13, weight: .regular)

    /// Meta: SF Pro (system), 11pt medium
    static let meta: Font = .system(size: 11, weight: .medium)

    /// Timestamp: SF Mono, 12pt medium — for durations, counters
    static let timestamp: Font = .system(size: 12, weight: .medium, design: .monospaced)
}

// MARK: - Text Style View Modifier

struct CrateTextStyle: ViewModifier {

    enum Style {
        case logo
        case sectionLabel
        case h1
        case h2
        case body
        case caption
        case meta
        case timestamp
    }

    let style: Style
    let color: Color

    init(_ style: Style, color: Color = CrateColors.textPrimary) {
        self.style = style
        self.color = color
    }

    func body(content: Content) -> some View {
        switch style {
        case .logo:
            content
                .font(CrateTypography.logo)
                .tracking(CrateTypography.logoTracking)
                .foregroundColor(color)

        case .sectionLabel:
            content
                .font(CrateTypography.sectionLabel)
                .tracking(CrateTypography.sectionTracking)
                .textCase(.uppercase)
                .foregroundColor(color)

        case .h1:
            content
                .font(CrateTypography.h1)
                .tracking(CrateTypography.headingTracking)
                .foregroundColor(color)

        case .h2:
            content
                .font(CrateTypography.h2)
                .tracking(CrateTypography.headingTracking)
                .foregroundColor(color)

        case .body:
            content
                .font(CrateTypography.body)
                .tracking(CrateTypography.bodyTracking)
                .foregroundColor(color)

        case .caption:
            content
                .font(CrateTypography.caption)
                .tracking(CrateTypography.captionTracking)
                .foregroundColor(color)

        case .meta:
            content
                .font(CrateTypography.meta)
                .tracking(CrateTypography.captionTracking)
                .foregroundColor(color)

        case .timestamp:
            content
                .font(CrateTypography.timestamp)
                .tracking(CrateTypography.monoTracking)
                .foregroundColor(color)
        }
    }
}

// MARK: - View Extension

extension View {
    /// Apply a CRATE text style with optional color override.
    ///
    ///     Text("NOW PLAYING")
    ///         .crateText(.sectionLabel, color: CrateColors.textSecondary)
    ///
    func crateText(
        _ style: CrateTextStyle.Style,
        color: Color = CrateColors.textPrimary
    ) -> some View {
        modifier(CrateTextStyle(style, color: color))
    }
}
