import UIKit
import MusicKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        Task {
            await requestMusicKitAuthorization()
        }
        AudioSessionManager.shared.configureAudioSession()

        // Setup push notifications
        UNUserNotificationCenter.current().delegate = NotificationManager.shared
        Task {
            await NotificationManager.shared.requestPermission()
        }

        return true
    }

    // MARK: - Remote Notification Registration

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task { @MainActor in
            NotificationManager.shared.didRegisterForRemoteNotifications(deviceToken: deviceToken)
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Task { @MainActor in
            NotificationManager.shared.didFailToRegisterForRemoteNotifications(error: error)
        }
    }

    // MARK: - MusicKit

    private func requestMusicKitAuthorization() async {
        let status = await MusicAuthorization.request()
        switch status {
        case .authorized:
            print("[MusicKit] Authorization granted")
        case .denied:
            print("[MusicKit] Authorization denied")
        case .notDetermined:
            print("[MusicKit] Authorization not determined")
        case .restricted:
            print("[MusicKit] Authorization restricted")
        @unknown default:
            print("[MusicKit] Unknown authorization status")
        }
    }
}
