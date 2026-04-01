import AVFoundation
import Combine

final class AudioSessionManager {
    static let shared = AudioSessionManager()

    private let audioSession = AVAudioSession.sharedInstance()
    private var interruptionObserver: AnyCancellable?

    var onInterruptionBegan: (() -> Void)?
    var onInterruptionEnded: ((_ shouldResume: Bool) -> Void)?

    private init() {
        setupInterruptionHandling()
    }

    func configureAudioSession() {
        do {
            try audioSession.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .duckOthers]
            )
            try audioSession.setActive(true)
            print("[AudioSession] Configured with .playback, .mixWithOthers, .duckOthers")
        } catch {
            print("[AudioSession] Configuration failed: \(error.localizedDescription)")
        }
    }

    func activateSession() {
        do {
            try audioSession.setActive(true, options: [])
            print("[AudioSession] Session activated")
        } catch {
            print("[AudioSession] Activation failed: \(error.localizedDescription)")
        }
    }

    func deactivateSession() {
        do {
            try audioSession.setActive(false, options: [.notifyOthersOnDeactivation])
            print("[AudioSession] Session deactivated")
        } catch {
            print("[AudioSession] Deactivation failed: \(error.localizedDescription)")
        }
    }

    func enableDucking(_ enabled: Bool) {
        do {
            let options: AVAudioSession.CategoryOptions = enabled
                ? [.mixWithOthers, .duckOthers]
                : [.mixWithOthers]
            try audioSession.setCategory(.playback, mode: .default, options: options)
            print("[AudioSession] Ducking \(enabled ? "enabled" : "disabled")")
        } catch {
            print("[AudioSession] Failed to set ducking: \(error.localizedDescription)")
        }
    }

    private func setupInterruptionHandling() {
        interruptionObserver = NotificationCenter.default
            .publisher(for: AVAudioSession.interruptionNotification)
            .sink { [weak self] notification in
                self?.handleInterruption(notification)
            }
    }

    private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            print("[AudioSession] Interruption began")
            onInterruptionBegan?()
        case .ended:
            let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            let shouldResume = options.contains(.shouldResume)
            print("[AudioSession] Interruption ended, shouldResume: \(shouldResume)")
            if shouldResume {
                activateSession()
            }
            onInterruptionEnded?(shouldResume)
        @unknown default:
            break
        }
    }
}
