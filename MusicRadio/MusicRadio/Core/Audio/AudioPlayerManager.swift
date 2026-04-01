import AVFoundation
import Combine
import Foundation
import UIKit

final class AudioPlayerManager: NSObject, ObservableObject {
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var waveformSamples: [Float] = []
    @Published private(set) var error: AudioPlayerError?

    private var audioPlayer: AVAudioPlayer?
    private var displayLink: CADisplayLink?
    private var currentURL: URL?

    enum AudioPlayerError: LocalizedError {
        case fileNotFound
        case downloadFailed(String)
        case playbackFailed(String)

        var errorDescription: String? {
            switch self {
            case .fileNotFound:
                return "Audio file not found"
            case .downloadFailed(let message):
                return "Download failed: \(message)"
            case .playbackFailed(let message):
                return "Playback failed: \(message)"
            }
        }
    }

    override init() {
        super.init()
    }

    // MARK: - Public API

    func loadAudio(from url: URL) async {
        await MainActor.run { isLoading = true }

        do {
            let localURL: URL
            if url.isFileURL {
                localURL = url
            } else {
                localURL = try await downloadAudio(from: url)
            }

            let player = try AVAudioPlayer(contentsOf: localURL)
            player.delegate = self
            player.prepareToPlay()
            player.enableRate = true

            let samples = extractWaveformSamples(from: localURL, count: 100)

            await MainActor.run {
                self.audioPlayer = player
                self.duration = player.duration
                self.currentURL = localURL
                self.waveformSamples = samples
                self.isLoading = false
                self.error = nil
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.error = .playbackFailed(error.localizedDescription)
            }
        }
    }

    func play() {
        guard let player = audioPlayer else { return }
        AudioSessionManager.shared.activateSession()
        player.play()
        isPlaying = true
        startDisplayLink()
    }

    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopDisplayLink()
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        isPlaying = false
        currentTime = 0
        stopDisplayLink()
    }

    func seek(to time: TimeInterval) {
        let clampedTime = max(0, min(time, duration))
        audioPlayer?.currentTime = clampedTime
        currentTime = clampedTime
    }

    func seekToPercentage(_ percentage: Double) {
        let time = duration * max(0, min(1, percentage))
        seek(to: time)
    }

    func setRate(_ rate: Float) {
        audioPlayer?.rate = rate
    }

    func setVolume(_ volume: Float) {
        audioPlayer?.volume = max(0, min(1, volume))
    }

    func cleanup() {
        stop()
        audioPlayer = nil
        currentURL = nil
        waveformSamples = []
        duration = 0
    }

    // MARK: - Display Link

    private func startDisplayLink() {
        stopDisplayLink()
        displayLink = CADisplayLink(target: self, selector: #selector(updatePlaybackTime))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 10, maximum: 30)
        displayLink?.add(to: .main, forMode: .common)
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func updatePlaybackTime() {
        guard let player = audioPlayer, player.isPlaying else { return }
        currentTime = player.currentTime
    }

    // MARK: - Download

    private func downloadAudio(from url: URL) async throws -> URL {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AudioPlayerError.downloadFailed("Invalid response")
        }

        let tempDir = FileManager.default.temporaryDirectory
        let fileName = url.lastPathComponent.isEmpty ? "radio_audio.mp3" : url.lastPathComponent
        let localURL = tempDir.appendingPathComponent(fileName)

        try data.write(to: localURL)
        return localURL
    }

    // MARK: - Waveform Extraction

    private func extractWaveformSamples(from url: URL, count: Int) -> [Float] {
        guard let audioFile = try? AVAudioFile(forReading: url) else {
            return Array(repeating: 0.5, count: count)
        }

        let format = audioFile.processingFormat
        let frameCount = AVAudioFrameCount(audioFile.length)

        guard frameCount > 0,
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return Array(repeating: 0.5, count: count)
        }

        do {
            try audioFile.read(into: buffer)
        } catch {
            return Array(repeating: 0.5, count: count)
        }

        guard let channelData = buffer.floatChannelData?[0] else {
            return Array(repeating: 0.5, count: count)
        }

        let samplesPerBin = Int(frameCount) / count
        var samples: [Float] = []

        for i in 0..<count {
            let start = i * samplesPerBin
            let end = min(start + samplesPerBin, Int(frameCount))
            var maxAmplitude: Float = 0

            for j in start..<end {
                let amplitude = abs(channelData[j])
                if amplitude > maxAmplitude {
                    maxAmplitude = amplitude
                }
            }
            samples.append(maxAmplitude)
        }

        // Normalize
        let maxSample = samples.max() ?? 1.0
        if maxSample > 0 {
            samples = samples.map { $0 / maxSample }
        }

        return samples
    }

    deinit {
        stopDisplayLink()
        audioPlayer?.stop()
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioPlayerManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.isPlaying = false
            self?.currentTime = 0
            self?.stopDisplayLink()
        }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.isPlaying = false
            self?.error = .playbackFailed(error?.localizedDescription ?? "Decode error")
            self?.stopDisplayLink()
        }
    }
}
