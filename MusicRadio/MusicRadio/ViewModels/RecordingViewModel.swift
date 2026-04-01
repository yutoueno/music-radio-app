import AVFoundation
import Foundation

@MainActor
final class RecordingViewModel: ObservableObject {
    @Published var recorder = AudioRecorder()
    @Published var isPreviewPlaying = false
    @Published var previewCurrentTime: TimeInterval = 0
    @Published var recordedAudioData: Data?
    @Published var recordedFileName: String?

    private var previewPlayer: AVAudioPlayer?
    private var previewTimer: Timer?

    var isRecording: Bool { recorder.isRecording }
    var hasRecording: Bool { recorder.recordedFileURL != nil }
    var recordingDuration: TimeInterval { recorder.recordingDuration }
    var normalizedLevel: CGFloat { recorder.normalizedLevel }
    var errorMessage: String? {
        get { recorder.errorMessage }
        set { recorder.errorMessage = newValue }
    }

    // MARK: - Recording Controls

    func startRecording() {
        stopPreview()
        recorder.startRecording()
    }

    func stopRecording() {
        recorder.stopRecording()
    }

    func discardRecording() {
        stopPreview()
        recorder.discardRecording()
        recordedAudioData = nil
        recordedFileName = nil
    }

    // MARK: - Preview Playback

    func togglePreview() {
        if isPreviewPlaying {
            stopPreview()
        } else {
            startPreview()
        }
    }

    private func startPreview() {
        guard let url = recorder.recordedFileURL else { return }

        do {
            previewPlayer = try AVAudioPlayer(contentsOf: url)
            previewPlayer?.play()
            isPreviewPlaying = true

            previewTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if let player = self.previewPlayer {
                        self.previewCurrentTime = player.currentTime
                        if !player.isPlaying {
                            self.stopPreview()
                        }
                    }
                }
            }
        } catch {
            recorder.errorMessage = "Preview failed: \(error.localizedDescription)"
        }
    }

    func stopPreview() {
        previewTimer?.invalidate()
        previewTimer = nil
        previewPlayer?.stop()
        previewPlayer = nil
        isPreviewPlaying = false
        previewCurrentTime = 0
    }

    // MARK: - Prepare for program creation

    func prepareAudioForUpload() -> (Data, String)? {
        guard let url = recorder.recordedFileURL else { return nil }

        do {
            let data = try Data(contentsOf: url)
            let fileName = url.lastPathComponent
            recordedAudioData = data
            recordedFileName = fileName
            return (data, fileName)
        } catch {
            recorder.errorMessage = "Failed to read recording: \(error.localizedDescription)"
            return nil
        }
    }

    var durationFormatted: String {
        let duration = recorder.recordingDuration
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        let tenths = Int((duration.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%d", minutes, seconds, tenths)
    }
}
