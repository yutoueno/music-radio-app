import SwiftUI

struct SignInView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @FocusState private var focusedField: Field?

    private enum Field {
        case email, password
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Logo / Header
                    VStack(spacing: 12) {
                        Image(systemName: "radio")
                            .font(.system(size: 64))
                            .foregroundColor(.accentColor)

                        Text("Music Radio")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Listen to radio programs with Apple Music")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 60)

                    // Form
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            TextField("your@email.com", text: $viewModel.signInEmail)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .focused($focusedField, equals: .email)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            SecureField("Password", text: $viewModel.signInPassword)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.password)
                                .focused($focusedField, equals: .password)
                        }

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button {
                            focusedField = nil
                            Task { await viewModel.signIn() }
                        } label: {
                            Group {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Sign In")
                                }
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(viewModel.isLoading)
                    }
                    .padding(.horizontal, 32)

                    // Links
                    VStack(spacing: 12) {
                        Button("Forgot Password?") {
                            viewModel.showPasswordReset = true
                        }
                        .font(.subheadline)

                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(.secondary)
                            Button("Sign Up") {
                                viewModel.showSignUp = true
                            }
                            .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                    }
                }
            }
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
}
