import Foundation
import SwiftUI
import PhotosUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading: Bool = false
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // Edit fields
    @Published var editNickname: String = ""
    @Published var editMessage: String = ""
    @Published var selectedAvatarData: Data?

    private let userRepository: UserRepositoryProtocol
    private let uploadRepository: UploadRepositoryProtocol

    init(
        userRepository: UserRepositoryProtocol = UserRepository(),
        uploadRepository: UploadRepositoryProtocol = UploadRepository()
    ) {
        self.userRepository = userRepository
        self.uploadRepository = uploadRepository
    }

    func loadProfile() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedProfile = try await userRepository.fetchMyProfile()
            profile = fetchedProfile
            editNickname = fetchedProfile.nickname
            editMessage = fetchedProfile.message ?? ""
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func saveProfile() async {
        isSaving = true
        errorMessage = nil
        successMessage = nil

        do {
            // Upload avatar if selected
            if let avatarData = selectedAvatarData {
                _ = try await uploadRepository.uploadAvatar(imageData: avatarData)
                selectedAvatarData = nil
            }

            // Update profile fields
            let updatedProfile = try await userRepository.updateProfile(
                nickname: editNickname.trimmingCharacters(in: .whitespacesAndNewlines),
                message: editMessage.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            profile = updatedProfile
            successMessage = "Profile updated successfully"
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }

    func resetEditFields() {
        guard let profile = profile else { return }
        editNickname = profile.nickname
        editMessage = profile.message ?? ""
        selectedAvatarData = nil
    }

    var hasChanges: Bool {
        guard let profile = profile else { return false }
        return editNickname != profile.nickname
            || editMessage != (profile.message ?? "")
            || selectedAvatarData != nil
    }
}
