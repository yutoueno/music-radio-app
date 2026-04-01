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
            ZStack(alignment: .bottom) {
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

                if authViewModel.isAuthenticated && programViewModel.currentProgram != nil {
                    MiniPlayerView()
                        .environmentObject(dualPlaybackCoordinator)
                        .environmentObject(programViewModel)
                        .transition(.move(edge: .bottom))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: programViewModel.currentProgram != nil)
            .onOpenURL { url in
                deepLinkManager.handleDeepLink(url)
            }
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .top
    @EnvironmentObject var deepLinkManager: DeepLinkManager

    enum Tab: Int {
        case top, favorites, broadcasting, profile
    }

    var body: some View {
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
                Label("Top", systemImage: "radio")
            }
            .tag(Tab.top)

            NavigationStack {
                FavoriteProgramsView()
            }
            .tabItem {
                Label("Favorites", systemImage: "heart.fill")
            }
            .tag(Tab.favorites)

            NavigationStack {
                BroadcastingView()
            }
            .tabItem {
                Label("Broadcasting", systemImage: "mic.fill")
            }
            .tag(Tab.broadcasting)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(Tab.profile)
        }
        .onChange(of: deepLinkManager.pendingDestination) { destination in
            if destination != nil {
                selectedTab = .top
                deepLinkManager.applyPendingNavigation()
            }
        }
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
                : String(url.path.dropFirst()) // Remove leading /

            if !programId.isEmpty {
                pendingDestination = .program(programId)
            }
        }
    }

    func applyPendingNavigation() {
        guard let destination = pendingDestination else { return }
        pendingDestination = nil
        // Reset navigation stack and push destination
        navigationPath = NavigationPath()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.navigationPath.append(destination)
        }
    }
}
