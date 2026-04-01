import SwiftUI

struct SignInView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @FocusState private var focusedField: Field?

    private enum Field {
        case email, password
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CrateColors.void.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 80)

                        // CRATE logo
                        crateLogo

                        Spacer().frame(height: 48)

                        // Form
                        VStack(spacing: 20) {
                            CrateTextField(
                                placeholder: "Email",
                                text: $viewModel.signInEmail,
                                keyboardType: .emailAddress,
                                textContentType: .emailAddress,
                                autocapitalization: .never,
                                onSubmit: { focusedField = .password }
                            )
                            .focused($focusedField, equals: .email)

                            CrateTextField(
                                placeholder: "Password",
                                text: $viewModel.signInPassword,
                                isSecure: true,
                                textContentType: .password,
                                onSubmit: { submitSignIn() }
                            )
                            .focused($focusedField, equals: .password)

                            // Error
                            if let error = viewModel.errorMessage {
                                Text(error)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(CrateColors.error)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, -8)
                            }

                            CrateButton(
                                title: "Sign In",
                                variant: .primary,
                                isLoading: viewModel.isLoading,
                                isDisabled: viewModel.signInEmail.isEmpty || viewModel.signInPassword.isEmpty,
                                fullWidth: true
                            ) {
                                submitSignIn()
                            }
                        }
                        .padding(.horizontal, 32)

                        Spacer().frame(height: 28)

                        // Forgot password
                        Button {
                            viewModel.showPasswordReset = true
                        } label: {
                            Text("Forgot password?")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(CrateColors.textTertiary)
                        }

                        Spacer().frame(height: 48)

                        // Create account
                        HStack(spacing: 6) {
                            Text("Don't have an account?")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(CrateColors.textTertiary)

                            Button {
                                viewModel.showSignUp = true
                            } label: {
                                Text("Create account")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(CrateColors.accent)
                            }
                        }

                        Spacer().frame(height: 40)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $viewModel.showSignUp) {
                SignUpView()
                    .environmentObject(viewModel)
            }
            .navigationDestination(isPresented: $viewModel.showPasswordReset) {
                PasswordResetView()
                    .environmentObject(viewModel)
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

    private func submitSignIn() {
        focusedField = nil
        Task { await viewModel.signIn() }
    }
}
