import SwiftUI

struct EmailVerificationView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Image(systemName: "envelope.open.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.accentColor)

                    Text("Check Your Email")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("We sent a verification code to\n\(viewModel.signUpEmail)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Verification Code")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        TextField("Enter 6-digit code", text: $viewModel.verificationCode)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .font(.title3.monospaced())
                            .focused($isFocused)
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        isFocused = false
                        Task { await viewModel.verifyEmail() }
                    } label: {
                        Group {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Verify")
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

                    Button("Resend Code") {
                        Task { await viewModel.signUp() }
                    }
                    .font(.subheadline)
                    .disabled(viewModel.isLoading)
                }
                .padding(.horizontal, 32)
            }
        }
        .navigationTitle("Verification")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $viewModel.showInitialRegistration) {
            InitialRegistrationView()
                .environmentObject(viewModel)
        }
    }
}
