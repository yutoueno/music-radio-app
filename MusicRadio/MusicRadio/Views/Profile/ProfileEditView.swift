import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        ZStack(alignment: .bottomTrailing) {
                            if let avatarData = viewModel.selectedAvatarData,
                               let uiImage = UIImage(data: avatarData) {
                                Image(uiImage: uiImage)
                                    .avatarStyle(size: 80)
                            } else {
                                AsyncImage(url: URL(string: viewModel.profile?.avatarUrl ?? "")) { image in
                                    image.avatarStyle(size: 80)
                                } placeholder: {
                                    Circle()
                                        .fill(Color(.systemGray4))
                                        .frame(width: 80, height: 80)
                                        .overlay {
                                            Image(systemName: "person.fill")
                                                .font(.title)
                                                .foregroundColor(.white)
                                        }
                                }
                            }

                            Image(systemName: "camera.fill")
                                .font(.caption)
                                .padding(6)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }

            Section("Nickname") {
                TextField("Nickname", text: $viewModel.editNickname)
                    .textContentType(.nickname)
            }

            Section("Message") {
                TextEditor(text: $viewModel.editMessage)
                    .frame(minHeight: 80)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    viewModel.resetEditFields()
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    Task {
                        await viewModel.saveProfile()
                        if viewModel.errorMessage == nil {
                            dismiss()
                        }
                    }
                }
                .fontWeight(.semibold)
                .disabled(viewModel.isSaving || !viewModel.hasChanges)
            }
        }
        .overlay {
            if viewModel.isSaving {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .overlay {
                        ProgressView("Saving...")
                            .padding()
                            .background(.regularMaterial)
                            .cornerRadius(12)
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
}
