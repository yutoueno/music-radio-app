import SwiftUI

struct InitialRegistrationView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    private enum Field {
        case nickname, password, confirmPassword
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

                    Text("Choose a nickname and set your password")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(CrateColors.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Spacer().frame(height: 48)

                    // Form
                    VStack(spacing: 20) {
                        CrateTextField(
                            placeholder: "Nickname",
                            text: $viewModel.registrationNickname,
                            textContentType: .nickname,
                            onSubmit: { focusedField = .password }
                        )
                        .focused($focusedField, equals: .nickname)

                        CrateTextField(
                            placeholder: "Password (8+ characters)",
                            text: $viewModel.registrationPassword,
                            isSecure: true,
                            textContentType: .newPassword,
                            onSubmit: { focusedField = .confirmPassword }
                        )
                        .focused($focusedField, equals: .password)

                        CrateTextField(
                            placeholder: "Confirm password",
                            text: $viewModel.registrationPasswordConfirm,
                            isSecure: true,
                            textContentType: .newPassword,
                            onSubmit: { submitRegistration() }
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

                        CrateButton(
                            title: "Complete Registration",
                            variant: .primary,
                            isLoading: viewModel.isLoading,
                            isDisabled: viewModel.registrationNickname.isEmpty
                                || viewModel.registrationPassword.isEmpty
                                || viewModel.registrationPasswordConfirm.isEmpty,
                            fullWidth: true
                        ) {
                            submitRegistration()
                        }
                    }
                    .padding(.horizontal, 32)

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

    // MARK: - Actions

    private func submitRegistration() {
        focusedField = nil
        Task { await viewModel.completeRegistration() }
    }
}
