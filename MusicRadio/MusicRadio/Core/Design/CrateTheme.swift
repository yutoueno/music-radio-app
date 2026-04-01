import SwiftUI

enum CrateTheme {

    // MARK: - Corner Radii

    enum CornerRadius {
        /// Cards, sheets — 10pt
        static let large: CGFloat = 10

        /// Buttons, inputs — 10pt
        static let medium: CGFloat = 10

        /// Tags, badges — 8pt
        static let small: CGFloat = 8

        /// Pill buttons, search bars — 50pt
        static let pill: CGFloat = 50

        /// Circular avatars — use `.clipShape(.circle)` instead;
        /// this value works for fixed-size containers via `cornerRadius`.
        static let avatar: CGFloat = 9999

        /// Thin progress bars — 1pt
        static let progress: CGFloat = 1
    }

    // MARK: - Spacing

    enum Spacing {
        /// Horizontal screen margins — 16pt
        static let screenMargin: CGFloat = 16

        /// Vertical gap between sections — 24pt
        static let sectionGap: CGFloat = 24

        /// Gap between cards in a list — 10pt
        static let cardGap: CGFloat = 10

        /// Internal card padding — 12pt
        static let cardPadding: CGFloat = 12

        /// Small vertical text gap — 4pt
        static let textGapSmall: CGFloat = 4

        /// Medium vertical text gap — 6pt
        static let textGapMedium: CGFloat = 6

        /// Inline element spacing (icon-to-text, etc.) — 8pt
        static let inline: CGFloat = 8
    }

    // MARK: - Animation

    enum Animation {
        /// Standard UI transition
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.25)

        /// Slow, dramatic transition (player expand/collapse)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.4)

        /// Snappy micro-interaction (button press)
        static let snappy = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
    }

    // MARK: - Shadows

    enum Shadow {
        /// Subtle card shadow for elevated surfaces
        static func card() -> some View {
            Color.black.opacity(0.3)
                .blur(radius: 8)
                .offset(y: 2)
        }
    }
}

// MARK: - Convenience View Modifiers

extension View {
    /// Apply CRATE card styling: elevated background, rounded corners, border.
    func crateCard() -> some View {
        self
            .padding(CrateTheme.Spacing.cardPadding)
            .background(CrateColors.elevated)
            .cornerRadius(CrateTheme.CornerRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.large)
                    .stroke(CrateColors.border, lineWidth: 0.5)
            )
    }

    /// Apply CRATE surface styling: surface background, rounded corners.
    func crateSurface() -> some View {
        self
            .padding(CrateTheme.Spacing.cardPadding)
            .background(CrateColors.surface)
            .cornerRadius(CrateTheme.CornerRadius.medium)
    }

    /// Apply standard screen margins.
    func crateScreenPadding() -> some View {
        self.padding(.horizontal, CrateTheme.Spacing.screenMargin)
    }
}
