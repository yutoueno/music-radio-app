import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: CrateTheme.Spacing.sectionGap) {
                // Avatar upload area
                avatarUploadSection
                    .padding(.top, 8)

                // Nickname field
                CrateLabeledTextField(
                    label: "Nickname",
                    placeholder: "Your display name",
                    text: $viewModel.editNickname
                )

                // Message field
                VStack(alignment: .leading, spacing: 6) {
                    Text("MESSAGE")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(1.5)
                        .foregroundColor(CrateColors.textSecondary)

                    TextEditor(text: $viewModel.editMessage)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(CrateColors.textPrimary)
                        .scrollContentBackground(.hidden)
                        .padding(14)
                        .frame(minHeight: 100)
                        .background(CrateColors.elevated)
                        .cornerRadius(8)
                }

                // Save button
                CrateButton(
                    title: "Save Changes",
                    variant: .primary,
                    isLoading: viewModel.isSaving,
                    isDisabled: !viewModel.hasChanges,
                    fullWidth: true
                ) {
                    Task {
                        await viewModel.saveProfile()
                        if viewModel.errorMessage == nil {
                            dismiss()
                        }
                    }
                }
                .padding(.top, 8)
            }
            .crateScreenPadding()
            .padding(.bottom, 40)
        }
        .background(CrateColors.void.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("EDIT PROFILE")
                    .crateText(.sectionLabel, color: CrateColors.textSecondary)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.resetEditFields()
                    dismiss()
                } label: {
                    Text("Cancel")
                        .crateText(.body, color: CrateColors.textSecondary)
                }
            }
        }
        .overlay {
            if viewModel.isSaving {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .overlay {
                        VStack(spacing: 12) {
                            ProgressView()
                                .tint(CrateColors.accent)
                            Text("Saving...")
                                .crateText(.caption, color: CrateColors.textSecondary)
                        }
                        .padding(24)
                        .background(CrateColors.elevated)
                        .cornerRadius(CrateTheme.CornerRadius.large)
                    }
            }
        }
        .onChange(of: selectedPhotoItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    viewModel.selectedAvatarData = data
                }
            }
        }
        .errorAlert(error: $viewModel.errorMessage)
    }

    // MARK: - Avatar Upload Section

    @ViewBuilder
    private var avatarUploadSection: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
            VStack(spacing: 14) {
                // Avatar preview
                ZStack(alignment: .bottomTrailing) {
                    if let avatarData = viewModel.selectedAvatarData,
                       let uiImage = UIImage(data: avatarData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 88, height: 88)
                            .clipShape(Circle())
                    } else {
                        AvatarView(
                            url: viewModel.profile?.avatarUrl,
                            name: viewModel.profile?.nickname ?? "?",
                            size: .medium
                        )
                        .scaleEffect(2.0)
                        .frame(width: 88, height: 88)
                    }

                    // Camera badge
                    ZStack {
                        Circle()
                            .fill(CrateColors.accent)
                            .frame(width: 28, height: 28)

                        Image(systemName: "camera.fill")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(CrateColors.void)
                    }
                    .offset(x: 2, y: 2)
                }

                Text("Change Photo")
                    .crateText(.caption, color: CrateColors.accent)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.large)
                    .fill(CrateColors.elevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.large)
                    .strokeBorder(
                        CrateColors.textTertiary.opacity(0.4),
                        style: StrokeStyle(lineWidth: 1, dash: [6, 4])
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProfileEditView(viewModel: ProfileViewModel())
    }
}
