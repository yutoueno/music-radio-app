import SwiftUI

struct CrateTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var autocapitalization: TextInputAutocapitalization = .sentences
    var onSubmit: (() -> Void)? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            Group {
                if isSecure {
                    SecureField("", text: $text, prompt: promptText)
                        .textContentType(textContentType)
                } else {
                    TextField("", text: $text, prompt: promptText)
                        .keyboardType(keyboardType)
                        .textContentType(textContentType)
                        .textInputAutocapitalization(autocapitalization)
                }
            }
            .font(.system(size: 15, weight: .regular))
            .foregroundColor(CrateColors.textPrimary)
            .focused($isFocused)
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(CrateColors.elevated)
            .cornerRadius(8)
            .onSubmit {
                onSubmit?()
            }

            // Focus underline
            Rectangle()
                .fill(isFocused ? CrateColors.accent : Color.clear)
                .frame(height: 2)
                .padding(.horizontal, 4)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }

    private var promptText: Text {
        Text(placeholder)
            .foregroundColor(CrateColors.textMuted)
    }
}

// MARK: - Labeled variant

struct CrateLabeledTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var errorMessage: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .tracking(1.5)
                .foregroundColor(CrateColors.textSecondary)

            CrateTextField(
                placeholder: placeholder,
                text: $text,
                isSecure: isSecure,
                keyboardType: keyboardType
            )

            if let error = errorMessage {
                Text(error)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(CrateColors.error)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State var email = ""
        @State var password = ""
        @State var name = "DJ Midnight"

        var body: some View {
            VStack(spacing: 20) {
                CrateTextField(
                    placeholder: "Enter your email",
                    text: $email,
                    keyboardType: .emailAddress
                )

                CrateTextField(
                    placeholder: "Password",
                    text: $password,
                    isSecure: true
                )

                CrateLabeledTextField(
                    label: "Display Name",
                    placeholder: "Your name",
                    text: $name
                )

                CrateLabeledTextField(
                    label: "Email",
                    placeholder: "your@email.com",
                    text: $email,
                    errorMessage: "Invalid email address"
                )
            }
            .padding(20)
            .background(CrateColors.void)
        }
    }
    return PreviewWrapper()
}
