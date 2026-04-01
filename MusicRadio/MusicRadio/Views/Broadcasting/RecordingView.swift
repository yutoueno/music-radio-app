import SwiftUI

struct RecordingView: View {
    @StateObject private var viewModel = RecordingViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showProgramEdit = false
    @State private var audioDataForEdit: Data?
    @State private var audioFileNameForEdit: String?

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.hasRecording && !viewModel.isRecording {
                previewView
            } else {
                recordingView
            }
        }
        .navigationTitle("Record Audio")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    viewModel.discardRecording()
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showProgramEdit) {
            NavigationStack {
                ProgramEditView(
                    initialAudioData: audioDataForEdit,
                    initialAudioFileName: audioFileNameForEdit
                )
            }
        }
        .errorAlert(error: Binding(
            get: { viewModel.errorMessage },
            set: { viewModel.errorMessage = $0 }
        ))
    }

    // MARK: - Recording View

    @ViewBuilder
    private var recordingView: some View {
        VStack(spacing: 40) {
            Spacer()

            // Timer
            Text(viewModel.durationFormatted)
                .font(.system(size: 52, weight: .light, design: .monospaced))
                .foregroundColor(viewModel.isRecording ? .red : .primary)

            // Audio Level Visualization
            AudioLevelBars(level: viewModel.normalizedLevel, isActive: viewModel.isRecording)
                .frame(height: 80)
                .padding(.horizontal, 40)

            // Record Button
            Button {
                if viewModel.isRecording {
                    viewModel.stopRecording()
                } else {
                    viewModel.startRecording()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.15))
                        .frame(width: 100, height: 100)

                    if viewModel.isRecording {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.red)
                            .frame(width: 32, height: 32)
                    } else {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 68, height: 68)
                    }
                }
            }
            .accessibilityLabel(viewModel.isRecording ? "Stop recording" : "Start recording")

            Text(viewModel.isRecording ? "Tap to stop" : "Tap to record")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()
        }
    }

    // MARK: - Preview View (after recording)

    @ViewBuilder
    private var previewView: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("Recording Complete")
                .font(.title2)
                .fontWeight(.bold)

            Text(viewModel.durationFormatted)
                .font(.system(size: 36, weight: .light, design: .monospaced))
                .foregroundColor(.secondary)

            // Preview playback button
            Button {
                viewModel.togglePreview()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.isPreviewPlaying ? "pause.fill" : "play.fill")
                    Text(viewModel.isPreviewPlaying ? "Pause Preview" : "Play Preview")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 12) {
                // Continue to program creation
                Button {
                    if let (data, fileName) = viewModel.prepareAudioForUpload() {
                        audioDataForEdit = data
                        audioFileNameForEdit = fileName
                        showProgramEdit = true
                    }
                } label: {
                    Label("Continue to Program", systemImage: "arrow.right.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)

                // Re-record
                Button {
                    viewModel.discardRecording()
                } label: {
                    Label("Record Again", systemImage: "arrow.counterclockwise")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
            }
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Audio Level Bars

struct AudioLevelBars: View {
    let level: CGFloat
    let isActive: Bool

    private let barCount = 20

    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 3) {
                ForEach(0..<barCount, id: \.self) { index in
                    let barLevel = barHeight(for: index, totalBars: barCount, level: level)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(barColor(for: index, totalBars: barCount))
                        .frame(
                            width: max(2, (geometry.size.width - CGFloat(barCount - 1) * 3) / CGFloat(barCount)),
                            height: isActive ? max(4, geometry.size.height * barLevel) : 4
                        )
                        .animation(.easeOut(duration: 0.08), value: level)
                }
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
    }

    private func barHeight(for index: Int, totalBars: Int, level: CGFloat) -> CGFloat {
        let center = CGFloat(totalBars) / 2.0
        let distance = abs(CGFloat(index) - center) / center
        let envelope = 1.0 - distance * 0.6
        return level * envelope
    }

    private func barColor(for index: Int, totalBars: Int) -> Color {
        let ratio = CGFloat(index) / CGFloat(totalBars)
        if ratio > 0.85 {
            return .red
        } else if ratio > 0.65 {
            return .orange
        }
        return .green
    }
}
