import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showEditProfile = false
    @State private var showLogoutConfirm = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if viewModel.isLoading && viewModel.profile == nil {
                ProgressView()
                    .tint(CrateColors.textSecondary)
                    .frame(maxWidth: .infinity, minHeight: 400)
            } else if let profile = viewModel.profile {
                VStack(spacing: CrateTheme.Spacing.sectionGap) {
                    profileHeader(profile)
                    statsRow(profile)
                    menuSection
                }
                .crateScreenPadding()
                .padding(.bottom, 100)
            }
        }
        .background(CrateColors.void.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("PROFILE")
                    .crateText(.sectionLabel, color: CrateColors.textSecondary)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showEditProfile = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(CrateColors.textSecondary)
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

    // MARK: - Profile Header

    @ViewBuilder
    private func profileHeader(_ profile: UserProfile) -> some View {
        VStack(spacing: 14) {
            // Large avatar
            AvatarView(
                url: profile.avatarUrl,
                name: profile.nickname,
                size: .medium
            )
            .scaleEffect(2.0)
            .frame(width: 88, height: 88)

            // Nickname
            Text(profile.nickname)
                .crateText(.h1)

            // Message
            if let message = profile.message, !message.isEmpty {
                Text(message)
                    .crateText(.body, color: CrateColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
    }

    // MARK: - Stats Row

    @ViewBuilder
    private func statsRow(_ profile: UserProfile) -> some View {
        HStack(spacing: 0) {
            statItem(value: profile.programCount ?? 0, label: "Shows")
            statDivider
            statItem(value: profile.followerCount, label: "Followers")
            statDivider
            statItem(value: profile.followingCount ?? 0, label: "Following")
            statDivider
            statItem(value: profile.favoriteCount ?? 0, label: "Favorites")
        }
        .padding(.vertical, 14)
        .background(CrateColors.surface)
        .cornerRadius(CrateTheme.CornerRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.large)
                .stroke(CrateColors.border, lineWidth: 0.5)
        )
    }

    private func statItem(value: Int, label: String) -> some View {
        VStack(spacing: CrateTheme.Spacing.textGapSmall) {
            Text("\(value)")
                .crateText(.h2)

            Text(label)
                .crateText(.meta, color: CrateColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(CrateColors.border)
            .frame(width: 0.5, height: 32)
    }

    // MARK: - Menu Section

    @ViewBuilder
    private var menuSection: some View {
        VStack(spacing: CrateTheme.Spacing.cardGap) {
            // Main menu group
            VStack(spacing: 0) {
                NavigationLink(destination: MyProgramsView()) {
                    menuRow(icon: "radio", title: "My Shows")
                }

                menuDivider

                NavigationLink(destination: FavoriteProgramsView()) {
                    menuRow(icon: "heart.fill", title: "Favorites")
                }

                menuDivider

                NavigationLink(destination: FollowListView()) {
                    menuRow(icon: "person.2.fill", title: "Following")
                }

                menuDivider

                NavigationLink(destination: PoCTestView()) {
                    menuRow(icon: "checkmark.shield", title: "PoC Test")
                }
            }
            .background(CrateColors.surface)
            .cornerRadius(CrateTheme.CornerRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.large)
                    .stroke(CrateColors.border, lineWidth: 0.5)
            )

            // Sign out (separate card)
            Button {
                showLogoutConfirm = true
            } label: {
                menuRow(
                    icon: "rectangle.portrait.and.arrow.right",
                    title: "Sign Out",
                    isDestructive: true
                )
            }
            .background(CrateColors.surface)
            .cornerRadius(CrateTheme.CornerRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.large)
                    .stroke(CrateColors.border, lineWidth: 0.5)
            )
        }
    }

    private var menuDivider: some View {
        Rectangle()
            .fill(CrateColors.border)
            .frame(height: 0.5)
            .padding(.leading, 52)
    }

    private func menuRow(
        icon: String,
        title: String,
        isDestructive: Bool = false
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isDestructive ? CrateColors.error : CrateColors.accent)
                .frame(width: 24, alignment: .center)

            Text(title)
                .crateText(.body, color: isDestructive ? CrateColors.error : CrateColors.textPrimary)

            Spacer()

            if !isDestructive {
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(CrateColors.textTertiary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}
