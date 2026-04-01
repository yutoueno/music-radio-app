import SwiftUI

struct EmailVerificationView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            CrateColors.void.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 60)

                    // CRATE logo
                    crateLogo

                    Spacer().frame(height: 16)

                    Text("We sent a verification code to")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(CrateColors.textTertiary)

                    Text(viewModel.signUpEmail)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(CrateColors.textSecondary)
                        .padding(.top, 4)

                    Spacer().frame(height: 48)

                    // Form
                    VStack(spacing: 20) {
                        CrateTextField(
                            placeholder: "6-digit code",
                            text: $viewModel.verificationCode,
                            keyboardType: .numberPad,
                            onSubmit: { submitVerify() }
                        )
                        .focused($isFocused)

                        // Error
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(CrateColors.error)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, -8)
                        }

                        CrateButton(
                            title: "Verify",
                            variant: .primary,
                            isLoading: viewModel.isLoading,
                            isDisabled: viewModel.verificationCode.isEmpty,
                            fullWidth: true
                        ) {
                            submitVerify()
                        }

                        // Resend
                        Button {
                            Task { await viewModel.signUp() }
                        } label: {
                            Text("Resend code")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(CrateColors.textTertiary)
                        }
                        .disabled(viewModel.isLoading)
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
        .navigationDestination(isPresented: $viewModel.showInitialRegistration) {
            InitialRegistrationView()
                .environmentObject(viewModel)
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

    private func submitVerify() {
        isFocused = false
        Task { await viewModel.verifyEmail() }
    }
}
