import SwiftUI

struct SignUpView: View {
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

                    Text("Enter your email to get started")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(CrateColors.textTertiary)

                    Spacer().frame(height: 48)

                    // Form
                    VStack(spacing: 20) {
                        CrateTextField(
                            placeholder: "Email",
                            text: $viewModel.signUpEmail,
                            keyboardType: .emailAddress,
                            textContentType: .emailAddress,
                            autocapitalization: .never,
                            onSubmit: { submitSignUp() }
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
                            title: "Create Account",
                            variant: .primary,
                            isLoading: viewModel.isLoading,
                            isDisabled: viewModel.signUpEmail.isEmpty,
                            fullWidth: true
                        ) {
                            submitSignUp()
                        }
                    }
                    .padding(.horizontal, 32)

                    Spacer().frame(height: 48)

                    // Already have account
                    HStack(spacing: 6) {
                        Text("Already have an account?")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(CrateColors.textTertiary)

                        Button {
                            dismiss()
                        } label: {
                            Text("Sign in")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(CrateColors.accent)
                        }
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
        .navigationDestination(isPresented: $viewModel.showVerification) {
            EmailVerificationView()
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

    private func submitSignUp() {
        isFocused = false
        Task { await viewModel.signUp() }
    }
}

// MARK: - Shared Back Button

func crateBackButton(action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Image(systemName: "chevron.left")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(CrateColors.textSecondary)
    }
}
