import SwiftUI

@main
struct MusicRadioApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var dualPlaybackCoordinator = DualPlaybackCoordinator()
    @StateObject private var programViewModel = ProgramViewModel()
    @StateObject private var deepLinkManager = DeepLinkManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    MainTabView()
                        .environmentObject(authViewModel)
                        .environmentObject(dualPlaybackCoordinator)
                        .environmentObject(programViewModel)
                        .environmentObject(deepLinkManager)
                } else {
                    SignInView()
                        .environmentObject(authViewModel)
                }
            }
            .preferredColorScheme(.dark)
            .onOpenURL { url in
                deepLinkManager.handleDeepLink(url)
            }
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .top
    @EnvironmentObject var deepLinkManager: DeepLinkManager
    @EnvironmentObject var dualPlaybackCoordinator: DualPlaybackCoordinator
    @EnvironmentObject var programViewModel: ProgramViewModel

    enum Tab: Int {
        case top, favorites, publish, profile
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NavigationStack(path: $deepLinkManager.navigationPath) {
                    TopView()
                        .navigationDestination(for: DeepLinkDestination.self) { destination in
                            switch destination {
                            case .program(let id):
                                ProgramView(programId: id)
                            }
                        }
                }
                .tabItem {
                    Image(systemName: selectedTab == .top ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(Tab.top)

                NavigationStack {
                    FavoriteProgramsView()
                }
                .tabItem {
                    Image(systemName: selectedTab == .favorites ? "heart.fill" : "heart")
                    Text("Favorites")
                }
                .tag(Tab.favorites)

                NavigationStack {
                    BroadcastingView()
                }
                .tabItem {
                    Image(systemName: selectedTab == .publish ? "plus.circle.fill" : "plus.circle")
                    Text("Publish")
                }
                .tag(Tab.publish)

                NavigationStack {
                    ProfileView()
                }
                .tabItem {
                    Image(systemName: selectedTab == .profile ? "person.fill" : "person")
                    Text("Profile")
                }
                .tag(Tab.profile)
            }
            .tint(CrateColors.accent)
            .onAppear {
                configureCrateTabBar()
            }

            // Mini Player overlay above tab bar
            if programViewModel.currentProgram != nil {
                CrateMiniPlayerView(
                    onTapExpand: {
                        // Navigate to full player
                    },
                    onFavoriteTap: {
                        Task {
                            await programViewModel.toggleFavorite()
                        }
                    }
                )
                .padding(.bottom, 49) // Standard tab bar height
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.3), value: programViewModel.currentProgram != nil)
            }
        }
        .onChange(of: deepLinkManager.pendingDestination) { destination in
            if destination != nil {
                selectedTab = .top
                deepLinkManager.applyPendingNavigation()
            }
        }
    }

    private func configureCrateTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        // Surface background (#111)
        appearance.backgroundColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)

        // Separator line
        appearance.shadowColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1)

        // Inactive: #555
        let inactiveColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1)
        appearance.stackedLayoutAppearance.normal.iconColor = inactiveColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: inactiveColor,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]

        // Active: accent (#7C83FF)
        let activeColor = UIColor(red: 124/255, green: 131/255, blue: 255/255, alpha: 1)
        appearance.stackedLayoutAppearance.selected.iconColor = activeColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: activeColor,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Deep Link Manager

enum DeepLinkDestination: Hashable {
    case program(String)
}

@MainActor
final class DeepLinkManager: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var pendingDestination: DeepLinkDestination?

    func handleDeepLink(_ url: URL) {
        guard url.scheme == "musicradio" else { return }

        // Handle musicradio://program/{id}
        if url.host == "program" {
            let programId = url.pathComponents.count > 1
                ? url.pathComponents[1]
                : String(url.path.dropFirst())

            if !programId.isEmpty {
                pendingDestination = .program(programId)
            }
        }
    }

    func applyPendingNavigation() {
        guard let destination = pendingDestination else { return }
        pendingDestination = nil
        navigationPath = NavigationPath()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.navigationPath.append(destination)
        }
    }
}
