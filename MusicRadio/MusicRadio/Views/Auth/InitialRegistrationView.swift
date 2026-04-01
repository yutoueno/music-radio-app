import SwiftUI

struct InitialRegistrationView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @FocusState private var focusedField: Field?

    private enum Field {
        case nickname, password, confirmPassword
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(.accentColor)

                    Text("Complete Your Profile")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Choose a nickname and set your password")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Nickname")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        TextField("Your display name", text: $viewModel.registrationNickname)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.nickname)
                            .focused($focusedField, equals: .nickname)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        SecureField("At least 8 characters", text: $viewModel.registrationPassword)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.newPassword)
                            .focused($focusedField, equals: .password)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Confirm Password")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        SecureField("Re-enter password", text: $viewModel.registrationPasswordConfirm)
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

                    Button {
                        focusedField = nil
                        Task { await viewModel.completeRegistration() }
                    } label: {
                        Group {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Create Account")
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
        .navigationTitle("Registration")
        .navigationBarTitleDisplayMode(.inline)
    }
}
