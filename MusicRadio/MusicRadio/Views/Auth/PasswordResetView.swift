import SwiftUI

struct PasswordResetView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @FocusState private var focusedField: Field?
    @State private var showConfirmation = false

    private enum Field {
        case email, token, password, confirmPassword
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 48))
                        .foregroundColor(.accentColor)

                    Text("Reset Password")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Enter your email to receive a reset link")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)

                if !showConfirmation {
                    requestSection
                } else {
                    confirmationSection
                }
            }
        }
        .navigationTitle("Reset Password")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var requestSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Email")
                    .font(.subheadline)
                    .fontWeight(.medium)
                TextField("your@email.com", text: $viewModel.resetEmail)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .focused($focusedField, equals: .email)
            }

            if let message = viewModel.resetSuccessMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                focusedField = nil
                Task {
                    await viewModel.requestPasswordReset()
                    if viewModel.errorMessage == nil {
                        showConfirmation = true
                    }
                }
            } label: {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Send Reset Link")
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
    }

    @ViewBuilder
    private var confirmationSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Reset Token")
                    .font(.subheadline)
                    .fontWeight(.medium)
                TextField("Enter token from email", text: $viewModel.resetToken)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .token)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("New Password")
                    .font(.subheadline)
                    .fontWeight(.medium)
                SecureField("At least 8 characters", text: $viewModel.newPassword)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)
                    .focused($focusedField, equals: .password)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Confirm Password")
                    .font(.subheadline)
                    .fontWeight(.medium)
                SecureField("Re-enter password", text: $viewModel.newPasswordConfirm)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)
                    .focused($focusedField, equals: .confirmPassword)
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let message = viewModel.resetSuccessMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                focusedField = nil
                Task { await viewModel.confirmPasswordReset() }
            } label: {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Reset Password")
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
    }
}
