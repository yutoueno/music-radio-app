import AVFoundation
import Combine

final class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var averagePower: Float = -160
    @Published var peakPower: Float = -160
    @Published var recordedFileURL: URL?
    @Published var errorMessage: String?

    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var levelTimer: Timer?

    override init() {
        super.init()
    }

    // MARK: - Start Recording

    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            errorMessage = "Failed to configure audio session: \(error.localizedDescription)"
            return
        }

        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "recording_\(UUID().uuidString).m4a"
        let fileURL = tempDir.appendingPathComponent(fileName)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey: 128000,
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.delegate = self
            audioRecorder?.record()

            isRecording = true
            recordingDuration = 0
            recordedFileURL = nil
            errorMessage = nil

            // Duration timer
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self, let recorder = self.audioRecorder else { return }
                DispatchQueue.main.async {
                    self.recordingDuration = recorder.currentTime
                }
            }

            // Level metering timer
            levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                guard let self = self, let recorder = self.audioRecorder else { return }
                recorder.updateMeters()
                DispatchQueue.main.async {
                    self.averagePower = recorder.averagePower(forChannel: 0)
                    self.peakPower = recorder.peakPower(forChannel: 0)
                }
            }
        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
        }
    }

    // MARK: - Stop Recording

    func stopRecording() {
        timer?.invalidate()
        timer = nil
        levelTimer?.invalidate()
        levelTimer = nil

        guard let recorder = audioRecorder, recorder.isRecording else {
            isRecording = false
            return
        }

        recorder.stop()
        isRecording = false
        recordedFileURL = recorder.url

        // Restore audio session for playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        } catch {
            // Non-critical
        }
    }

    // MARK: - Discard

    func discardRecording() {
        if let url = recordedFileURL {
            try? FileManager.default.removeItem(at: url)
        }
        recordedFileURL = nil
        recordingDuration = 0
        averagePower = -160
        peakPower = -160
    }

    /// Normalized level in 0...1 range for UI visualization.
    var normalizedLevel: CGFloat {
        // averagePower ranges from -160 (silence) to 0 (max)
        let minDB: Float = -60
        let clamped = max(minDB, averagePower)
        return CGFloat((clamped - minDB) / (0 - minDB))
    }

    deinit {
        timer?.invalidate()
        levelTimer?.invalidate()
    }
}

// MARK: - AVAudioRecorderDelegate

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            DispatchQueue.main.async { [weak self] in
                self?.errorMessage = "Recording did not complete successfully"
            }
        }
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.errorMessage = "Recording encode error: \(error?.localizedDescription ?? "unknown")"
        }
    }
}
