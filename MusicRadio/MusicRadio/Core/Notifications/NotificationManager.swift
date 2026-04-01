import Foundation
import UIKit
import UserNotifications

@MainActor
final class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()

    @Published private(set) var isPermissionGranted: Bool = false
    @Published private(set) var deviceToken: String?

    private let apiClient = APIClient.shared

    private override init() {
        super.init()
    }

    // MARK: - Permission

    func requestPermission() async {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            isPermissionGranted = granted
            if granted {
                await registerForRemoteNotifications()
            }
        } catch {
            print("[NotificationManager] Permission request failed: \(error.localizedDescription)")
        }
    }

    func checkPermission() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        isPermissionGranted = settings.authorizationStatus == .authorized
    }

    // MARK: - Device Token Registration

    private func registerForRemoteNotifications() async {
        UIApplication.shared.registerForRemoteNotifications()
    }

    func didRegisterForRemoteNotifications(deviceToken data: Data) {
        let token = data.map { String(format: "%02.2hhx", $0) }.joined()
        self.deviceToken = token
        print("[NotificationManager] Device token: \(token)")

        Task {
            await registerDeviceTokenWithBackend(token: token)
        }
    }

    func didFailToRegisterForRemoteNotifications(error: Error) {
        print("[NotificationManager] Failed to register: \(error.localizedDescription)")
    }

    private func registerDeviceTokenWithBackend(token: String) async {
        do {
            try await apiClient.requestVoid(
                endpoint: .registerDeviceToken(token: token)
            )
            print("[NotificationManager] Device token registered with backend")
        } catch {
            print("[NotificationManager] Failed to register token with backend: \(error.localizedDescription)")
        }
    }

    // MARK: - Handle Received Notifications

    func handleNotification(userInfo: [AnyHashable: Any]) {
        // Parse notification data
        if let type = userInfo["type"] as? String {
            switch type {
            case "new_program":
                if let programId = userInfo["program_id"] as? String {
                    print("[NotificationManager] New program notification: \(programId)")
                    // Navigation handling could be done via NotificationCenter or a shared state
                    NotificationCenter.default.post(
                        name: .didReceiveProgramNotification,
                        object: nil,
                        userInfo: ["program_id": programId]
                    )
                }
            case "favorited":
                if let programId = userInfo["program_id"] as? String {
                    print("[NotificationManager] Favorite notification for program: \(programId)")
                    NotificationCenter.default.post(
                        name: .didReceiveProgramNotification,
                        object: nil,
                        userInfo: ["program_id": programId]
                    )
                }
            default:
                print("[NotificationManager] Unknown notification type: \(type)")
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .badge, .sound])
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        Task { @MainActor in
            NotificationManager.shared.handleNotification(userInfo: userInfo)
        }
        completionHandler()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let didReceiveProgramNotification = Notification.Name("didReceiveProgramNotification")
}
