import SwiftUI

enum CrateColors {
    // MARK: - Background

    /// #0A0A0A — deepest background, app canvas
    static let void = Color(red: 10/255, green: 10/255, blue: 10/255)

    /// #111111 — primary surface (cards, sheets)
    static let surface = Color(red: 17/255, green: 17/255, blue: 17/255)

    /// #1A1A1A — elevated surface (modals, popovers)
    static let elevated = Color(red: 26/255, green: 26/255, blue: 26/255)

    /// #1A1A2E — subtle tinted background
    static let subtle = Color(red: 26/255, green: 26/255, blue: 46/255)

    // MARK: - Accent

    /// #7C83FF — primary accent
    static let accent = Color(red: 124/255, green: 131/255, blue: 255/255)

    /// #5A5FCC — dimmed accent for pressed / secondary actions
    static let accentDim = Color(red: 90/255, green: 95/255, blue: 204/255)

    /// #7C83FF @ 15% — glow overlay for accent highlights
    static let accentGlow = Color(red: 124/255, green: 131/255, blue: 255/255).opacity(0.15)

    // MARK: - Text

    /// #F0F0F0 — primary text
    static let textPrimary = Color(red: 240/255, green: 240/255, blue: 240/255)

    /// #888888 — secondary text (subtitles, metadata)
    static let textSecondary = Color(red: 136/255, green: 136/255, blue: 136/255)

    /// #555555 — tertiary text (placeholders)
    static let textTertiary = Color(red: 85/255, green: 85/255, blue: 85/255)

    /// #444444 — muted text (less important labels)
    static let textMuted = Color(red: 68/255, green: 68/255, blue: 68/255)

    /// #333333 — disabled text
    static let textDisabled = Color(red: 51/255, green: 51/255, blue: 51/255)

    // MARK: - Border

    /// #222222 — default border
    static let border = Color(red: 34/255, green: 34/255, blue: 34/255)

    /// #1A1A1A — subtle border (nearly invisible separators)
    static let borderSubtle = Color(red: 26/255, green: 26/255, blue: 26/255)

    // MARK: - Semantic

    /// #FF4D4D — error / destructive
    static let error = Color(red: 255/255, green: 77/255, blue: 77/255)

    /// #4DFF88 — success / confirmation
    static let success = Color(red: 77/255, green: 255/255, blue: 136/255)
}
