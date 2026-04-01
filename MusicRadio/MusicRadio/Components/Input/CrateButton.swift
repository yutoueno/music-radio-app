import SwiftUI

struct CrateButton: View {

    enum Variant {
        case primary   // Accent fill, void text
        case secondary // Border only, primary text
        case ghost     // No background, secondary text
    }

    enum Size {
        case regular
        case compact

        var verticalPadding: CGFloat {
            switch self {
            case .regular: return 14
            case .compact: return 9
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .regular: return 24
            case .compact: return 16
            }
        }

        var fontSize: CGFloat {
            switch self {
            case .regular: return 14
            case .compact: return 12
            }
        }
    }

    let title: String
    var variant: Variant = .primary
    var size: Size = .regular
    var icon: String? = nil
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var fullWidth: Bool = false
    let action: () -> Void

    var body: some View {
        Button {
            guard !isLoading && !isDisabled else { return }
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        } label: {
            HStack(spacing: 6) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.7)
                        .tint(textColor)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: size.fontSize - 1, weight: .medium))
                    }
                    Text(title)
                        .font(.system(size: size.fontSize, weight: .semibold))
                }
            }
            .foregroundColor(isDisabled ? CrateColors.textDisabled : textColor)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(backgroundView)
            .overlay(borderView)
            .clipShape(Capsule())
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled || isLoading)
    }

    // MARK: - Variant Styling

    private var textColor: Color {
        switch variant {
        case .primary:   return CrateColors.void
        case .secondary: return CrateColors.textPrimary
        case .ghost:     return CrateColors.textSecondary
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch variant {
        case .primary:
            Capsule().fill(CrateColors.accent)
        case .secondary:
            Capsule().fill(Color.clear)
        case .ghost:
            Capsule().fill(Color.clear)
        }
    }

    @ViewBuilder
    private var borderView: some View {
        switch variant {
        case .primary:
            EmptyView()
        case .secondary:
            Capsule().stroke(CrateColors.textTertiary, lineWidth: 1)
        case .ghost:
            EmptyView()
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        CrateButton(title: "Start Listening", variant: .primary, action: {})
        CrateButton(title: "Start Listening", variant: .primary, icon: "play.fill", action: {})
        CrateButton(title: "Edit Profile", variant: .secondary, action: {})
        CrateButton(title: "Cancel", variant: .ghost, action: {})
        CrateButton(title: "Loading...", variant: .primary, isLoading: true, action: {})
        CrateButton(title: "Disabled", variant: .primary, isDisabled: true, action: {})
        CrateButton(title: "Full Width", variant: .primary, fullWidth: true, action: {})
        CrateButton(title: "Compact", variant: .secondary, size: .compact, action: {})
    }
    .padding(20)
    .background(CrateColors.void)
}
