import Foundation
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Sign In
    @Published var signInEmail: String = ""
    @Published var signInPassword: String = ""

    // Sign Up
    @Published var signUpEmail: String = ""

    // Email Verification
    @Published var verificationCode: String = ""
    @Published var verificationToken: String?

    // Registration
    @Published var registrationNickname: String = ""
    @Published var registrationPassword: String = ""
    @Published var registrationPasswordConfirm: String = ""

    // Password Reset
    @Published var resetEmail: String = ""
    @Published var resetToken: String = ""
    @Published var newPassword: String = ""
    @Published var newPasswordConfirm: String = ""

    // Navigation
    @Published var showSignUp: Bool = false
    @Published var showVerification: Bool = false
    @Published var showInitialRegistration: Bool = false
    @Published var showPasswordReset: Bool = false
    @Published var signUpSuccessMessage: String?
    @Published var resetSuccessMessage: String?

    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol = AuthRepository()) {
        self.authRepository = authRepository
        self.isAuthenticated = AuthManager.shared.isAuthenticated
    }

    // MARK: - Sign In

    func signIn() async {
        guard validateSignIn() else { return }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await authRepository.signIn(
                email: signInEmail.trimmingCharacters(in: .whitespacesAndNewlines),
                password: signInPassword
            )
            AuthManager.shared.setTokens(access: response.accessToken, refresh: response.refreshToken)
            AuthManager.shared.setUser(response.user)
            isAuthenticated = true
            clearSignInFields()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Sign Up

    func signUp() async {
        guard validateSignUp() else { return }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await authRepository.signUp(
                email: signUpEmail.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            signUpSuccessMessage = response.message
            showVerification = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Email Verification

    func verifyEmail() async {
        guard !verificationCode.isEmpty else {
            errorMessage = "Please enter the verification code"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await authRepository.verifyEmail(
                email: signUpEmail.trimmingCharacters(in: .whitespacesAndNewlines),
                code: verificationCode.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            verificationToken = response.token
            showInitialRegistration = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Complete Registration

    func completeRegistration() async {
        guard validateRegistration() else { return }
        guard let token = verificationToken else {
            errorMessage = "Verification token not found. Please restart the registration."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await authRepository.completeRegistration(
                token: token,
                nickname: registrationNickname.trimmingCharacters(in: .whitespacesAndNewlines),
                password: registrationPassword
            )
            AuthManager.shared.setTokens(access: response.accessToken, refresh: response.refreshToken)
            AuthManager.shared.setUser(response.user)
            isAuthenticated = true
            clearAllFields()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Password Reset

    func requestPasswordReset() async {
        guard !resetEmail.isEmpty else {
            errorMessage = "Please enter your email address"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await authRepository.requestPasswordReset(
                email: resetEmail.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            resetSuccessMessage = response.message
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func confirmPasswordReset() async {
        guard !resetToken.isEmpty else {
            errorMessage = "Please enter the reset token"
            return
        }
        guard newPassword.count >= 8 else {
            errorMessage = "Password must be at least 8 characters"
            return
        }
        guard newPassword == newPasswordConfirm else {
            errorMessage = "Passwords do not match"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await authRepository.confirmPasswordReset(
                token: resetToken,
                password: newPassword
            )
            resetSuccessMessage = "Password has been reset. Please sign in."
            showPasswordReset = false
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Logout

    func logout() async {
        do {
            try await authRepository.logout()
        } catch {
            print("[Auth] Logout API call failed: \(error.localizedDescription)")
        }
        await AuthManager.shared.logout()
        isAuthenticated = false
        clearAllFields()
    }

    // MARK: - Validation

    private func validateSignIn() -> Bool {
        if signInEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please enter your email address"
            return false
        }
        if signInPassword.isEmpty {
            errorMessage = "Please enter your password"
            return false
        }
        return true
    }

    private func validateSignUp() -> Bool {
        let email = signUpEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        if email.isEmpty {
            errorMessage = "Please enter your email address"
            return false
        }
        if !email.contains("@") || !email.contains(".") {
            errorMessage = "Please enter a valid email address"
            return false
        }
        return true
    }

    private func validateRegistration() -> Bool {
        if registrationNickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please enter a nickname"
            return false
        }
        if registrationPassword.count < 8 {
            errorMessage = "Password must be at least 8 characters"
            return false
        }
        if registrationPassword != registrationPasswordConfirm {
            errorMessage = "Passwords do not match"
            return false
        }
        return true
    }

    private func clearSignInFields() {
        signInEmail = ""
        signInPassword = ""
    }

    private func clearAllFields() {
        signInEmail = ""
        signInPassword = ""
        signUpEmail = ""
        verificationCode = ""
        verificationToken = nil
        registrationNickname = ""
        registrationPassword = ""
        registrationPasswordConfirm = ""
        resetEmail = ""
        resetToken = ""
        newPassword = ""
        newPasswordConfirm = ""
        showSignUp = false
        showVerification = false
        showInitialRegistration = false
        showPasswordReset = false
    }
}
