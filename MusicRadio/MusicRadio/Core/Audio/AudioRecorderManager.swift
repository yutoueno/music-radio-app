import AVFoundation
import Combine
import Foundation

@MainActor
final class AudioRecorderManager: NSObject, ObservableObject {
    @Published private(set) var isRecording: Bool = false
    @Published private(set) var recordingDuration: TimeInterval = 0
    @Published private(set) var hasRecording: Bool = false
    @Published private(set) var waveformLevels: [Float] = Array(repeating: 0, count: 50)
    @Published private(set) var error: String?
    @Published private(set) var recordingURL: URL?

    private var audioRecorder: AVAudioRecorder?
    private var durationTimer: Timer?
    private var meterTimer: Timer?
    private var startTime: Date?

    // MARK: - Recording Settings

    private let recordingSettings: [String: Any] = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 44100,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]

    override init() {
        super.init()
    }

    // MARK: - Public API

    func startRecording() {
        error = nil

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            self.error = "Failed to configure audio session: \(error.localizedDescription)"
            return
        }

        // Check microphone permission
        switch audioSession.recordPermission {
        case .granted:
            beginRecording()
        case .denied:
            self.error = "Microphone access denied. Please enable in Settings."
        case .undetermined:
            audioSession.requestRecordPermission { [weak self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self?.beginRecording()
                    } else {
                        self?.error = "Microphone access is required to record."
                    }
                }
            }
        @unknown default:
            self.error = "Unknown microphone permission state"
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        stopTimers()

        if let url = audioRecorder?.url {
            recordingURL = url
            hasRecording = FileManager.default.fileExists(atPath: url.path)
        }

        // Restore audio session for playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        } catch {
            print("[AudioRecorder] Failed to restore audio session: \(error.localizedDescription)")
        }
    }

    func deleteRecording() {
        if let url = recordingURL {
            try? FileManager.default.removeItem(at: url)
        }
        recordingURL = nil
        hasRecording = false
        recordingDuration = 0
        waveformLevels = Array(repeating: 0, count: 50)
    }

    // MARK: - Private

    private func beginRecording() {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "recording_\(Int(Date().timeIntervalSince1970)).m4a"
        let fileURL = tempDir.appendingPathComponent(fileName)

        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: recordingSettings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()

            isRecording = true
            hasRecording = false
            recordingDuration = 0
            startTime = Date()
            waveformLevels = Array(repeating: 0, count: 50)

            startTimers()
        } catch {
            self.error = "Failed to start recording: \(error.localizedDescription)"
        }
    }

    private func startTimers() {
        // Duration timer
        durationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, let start = self.startTime else { return }
                self.recordingDuration = Date().timeIntervalSince(start)
            }
        }

        // Metering timer for waveform
        meterTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.updateWaveform()
            }
        }
    }

    private func stopTimers() {
        durationTimer?.invalidate()
        durationTimer = nil
        meterTimer?.invalidate()
        meterTimer = nil
    }

    private func updateWaveform() {
        guard let recorder = audioRecorder, recorder.isRecording else { return }
        recorder.updateMeters()

        let normalizedValue = normalizedPowerLevel(from: recorder.averagePower(forChannel: 0))
        waveformLevels.append(normalizedValue)
        if waveformLevels.count > 50 {
            waveformLevels.removeFirst()
        }
    }

    private func normalizedPowerLevel(from decibels: Float) -> Float {
        // AVAudioRecorder meter range is -160 to 0 dB
        let minDb: Float = -60
        let maxDb: Float = 0

        let clamped = max(minDb, min(maxDb, decibels))
        return (clamped - minDb) / (maxDb - minDb)
    }

    deinit {
        durationTimer?.invalidate()
        meterTimer?.invalidate()
        audioRecorder?.stop()
    }
}

// MARK: - AVAudioRecorderDelegate

extension AudioRecorderManager: AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task { @MainActor in
            if !flag {
                self.error = "Recording did not finish successfully"
                self.hasRecording = false
            }
        }
    }

    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        Task { @MainActor in
            self.error = "Recording encoding error: \(error?.localizedDescription ?? "Unknown")"
            self.isRecording = false
            self.stopTimers()
        }
    }
}
