import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showEditProfile = false
    @State private var showLogoutConfirm = false

    var body: some View {
        ScrollView {
            if viewModel.isLoading && viewModel.profile == nil {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 300)
            } else if let profile = viewModel.profile {
                VStack(spacing: 24) {
                    profileHeader(profile)
                    menuSection
                }
                .padding(.bottom, 80)
            }
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showEditProfile = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showEditProfile) {
            NavigationStack {
                ProfileEditView(viewModel: viewModel)
            }
        }
        .alert("Sign Out", isPresented: $showLogoutConfirm) {
            Button("Sign Out", role: .destructive) {
                Task { await authViewModel.logout() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .onFirstAppear {
            await viewModel.loadProfile()
        }
        .errorAlert(error: $viewModel.errorMessage)
    }

    @ViewBuilder
    private func profileHeader(_ profile: UserProfile) -> some View {
        VStack(spacing: 16) {
            AsyncImage(url: URL(string: profile.avatarUrl ?? "")) { image in
                image.avatarStyle(size: 90)
            } placeholder: {
                Circle()
                    .fill(Color(.systemGray4))
                    .frame(width: 90, height: 90)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
            }

            Text(profile.nickname)
                .font(.title2)
                .fontWeight(.bold)

            if let message = profile.message, !message.isEmpty {
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 32) {
                statItem(value: profile.programCount ?? 0, label: "Programs")
                statItem(value: profile.followerCount, label: "Followers")
                statItem(value: profile.followingCount ?? 0, label: "Following")
                statItem(value: profile.favoriteCount ?? 0, label: "Favorites")
            }
        }
        .padding()
    }

    private func statItem(value: Int, label: String) -> some View {
        VStack {
            Text("\(value)")
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private var menuSection: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: MyProgramsView()) {
                menuRow(icon: "radio", title: "My Programs")
            }

            Divider().padding(.leading, 52)

            NavigationLink(destination: FavoriteProgramsView()) {
                menuRow(icon: "heart.fill", title: "Favorites")
            }

            Divider().padding(.leading, 52)

            NavigationLink(destination: FollowListView()) {
                menuRow(icon: "person.2.fill", title: "Following")
            }

            Divider().padding(.leading, 52)

            NavigationLink(destination: PoCTestView()) {
                menuRow(icon: "checkmark.shield", title: "PoC Test")
            }

            Divider().padding(.leading, 52)

            Button {
                showLogoutConfirm = true
            } label: {
                menuRow(icon: "rectangle.portrait.and.arrow.right", title: "Sign Out", isDestructive: true)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private func menuRow(icon: String, title: String, isDestructive: Bool = false) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(isDestructive ? .red : .accentColor)

            Text(title)
                .foregroundColor(isDestructive ? .red : .primary)

            Spacer()

            if !isDestructive {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
