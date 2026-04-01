import SwiftUI

struct PasswordResetView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    @State private var showConfirmation = false

    private enum Field {
        case email, token, password, confirmPassword
    }

    var body: some View {
        ZStack {
            CrateColors.void.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 60)

                    // CRATE logo
                    crateLogo

                    Spacer().frame(height: 16)

                    Text(showConfirmation
                         ? "Enter the code from your email"
                         : "Enter your email to receive a reset code")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(CrateColors.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Spacer().frame(height: 48)

                    if !showConfirmation {
                        requestSection
                    } else {
                        confirmationSection
                    }

                    Spacer().frame(height: 40)
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                crateBackButton { dismiss() }
            }
        }
    }

    // MARK: - Logo

    private var crateLogo: some View {
        VStack(spacing: 8) {
            Text("CRATE")
                .font(.custom("SpaceGrotesk-Light", size: 28))
                .tracking(8)
                .foregroundColor(CrateColors.textPrimary)

            Rectangle()
                .fill(CrateColors.accent.opacity(0.3))
                .frame(width: 40, height: 1)
        }
    }

    // MARK: - Request Section

    @ViewBuilder
    private var requestSection: some View {
        VStack(spacing: 20) {
            CrateTextField(
                placeholder: "Email",
                text: $viewModel.resetEmail,
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                autocapitalization: .never,
                onSubmit: { submitRequest() }
            )
            .focused($focusedField, equals: .email)

            // Success message
            if let message = viewModel.resetSuccessMessage {
                Text(message)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(CrateColors.success)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, -8)
            }

            // Error
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(CrateColors.error)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, -8)
            }

            CrateButton(
                title: "Reset Password",
                variant: .primary,
                isLoading: viewModel.isLoading,
                isDisabled: viewModel.resetEmail.isEmpty,
                fullWidth: true
            ) {
                submitRequest()
            }
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Confirmation Section

    @ViewBuilder
    private var confirmationSection: some View {
        VStack(spacing: 20) {
            CrateTextField(
                placeholder: "Reset code",
                text: $viewModel.resetToken,
                onSubmit: { focusedField = .password }
            )
            .focused($focusedField, equals: .token)

            CrateTextField(
                placeholder: "New password",
                text: $viewModel.newPassword,
                isSecure: true,
                textContentType: .newPassword,
                onSubmit: { focusedField = .confirmPassword }
            )
            .focused($focusedField, equals: .password)

            CrateTextField(
                placeholder: "Confirm password",
                text: $viewModel.newPasswordConfirm,
                isSecure: true,
                textContentType: .newPassword,
                onSubmit: { submitConfirm() }
            )
            .focused($focusedField, equals: .confirmPassword)

            // Error
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(CrateColors.error)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, -8)
            }

            // Success
            if let message = viewModel.resetSuccessMessage {
                Text(message)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(CrateColors.success)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, -8)
            }

            CrateButton(
                title: "Reset Password",
                variant: .primary,
                isLoading: viewModel.isLoading,
                isDisabled: viewModel.resetToken.isEmpty || viewModel.newPassword.isEmpty,
                fullWidth: true
            ) {
                submitConfirm()
            }
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Actions

    private func submitRequest() {
        focusedField = nil
        Task {
            await viewModel.requestPasswordReset()
            if viewModel.errorMessage == nil {
                withAnimation(CrateTheme.Animation.standard) {
                    showConfirmation = true
                }
            }
        }
    }

    private func submitConfirm() {
        focusedField = nil
        Task { await viewModel.confirmPasswordReset() }
    }
}
