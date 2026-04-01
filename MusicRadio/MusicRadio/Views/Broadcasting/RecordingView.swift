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
        .background(CrateColors.void.ignoresSafeArea())
        .navigationTitle("Record Audio")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.discardRecording()
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundColor(CrateColors.textSecondary)
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
        VStack(spacing: 0) {
            Spacer()

            // Timer
            Text(viewModel.durationFormatted)
                .font(.system(size: 56, weight: .light, design: .monospaced))
                .tracking(CrateTypography.monoTracking)
                .foregroundColor(viewModel.isRecording ? CrateColors.error : CrateColors.textPrimary)

            Spacer().frame(height: 40)

            // Audio Level Visualization
            CrateAudioLevelBars(level: viewModel.normalizedLevel, isActive: viewModel.isRecording)
                .frame(height: 80)
                .crateScreenPadding()
                .padding(.horizontal, 24)

            Spacer().frame(height: 48)

            // Record Button
            Button {
                if viewModel.isRecording {
                    viewModel.stopRecording()
                } else {
                    viewModel.startRecording()
                }
            } label: {
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(CrateColors.error.opacity(0.3), lineWidth: 3)
                        .frame(width: 96, height: 96)

                    // Glow
                    if viewModel.isRecording {
                        Circle()
                            .fill(CrateColors.error.opacity(0.1))
                            .frame(width: 96, height: 96)
                    }

                    // Inner shape
                    if viewModel.isRecording {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(CrateColors.error)
                            .frame(width: 32, height: 32)
                    } else {
                        Circle()
                            .fill(CrateColors.error)
                            .frame(width: 64, height: 64)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(viewModel.isRecording ? "Stop recording" : "Start recording")

            Spacer().frame(height: 20)

            Text(viewModel.isRecording ? "Tap to stop" : "Tap to record")
                .crateText(.caption, color: CrateColors.textSecondary)

            Spacer()
        }
    }

    // MARK: - Preview View (after recording)

    @ViewBuilder
    private var previewView: some View {
        VStack(spacing: 0) {
            Spacer()

            // Success indicator
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(CrateColors.success)

            Spacer().frame(height: 20)

            Text("Recording Complete")
                .crateText(.h1)

            Spacer().frame(height: 12)

            Text(viewModel.durationFormatted)
                .font(.system(size: 36, weight: .light, design: .monospaced))
                .tracking(CrateTypography.monoTracking)
                .foregroundColor(CrateColors.textSecondary)

            Spacer().frame(height: 32)

            // Preview playback button
            CrateButton(
                title: viewModel.isPreviewPlaying ? "Pause Preview" : "Play Preview",
                variant: .secondary,
                icon: viewModel.isPreviewPlaying ? "pause.fill" : "play.fill",
                fullWidth: true
            ) {
                viewModel.togglePreview()
            }
            .crateScreenPadding()

            Spacer()

            // Action buttons
            VStack(spacing: 12) {
                CrateButton(
                    title: "Continue to Program",
                    variant: .primary,
                    icon: "arrow.right.circle.fill",
                    fullWidth: true
                ) {
                    if let (data, fileName) = viewModel.prepareAudioForUpload() {
                        audioDataForEdit = data
                        audioFileNameForEdit = fileName
                        showProgramEdit = true
                    }
                }

                CrateButton(
                    title: "Record Again",
                    variant: .ghost,
                    icon: "arrow.counterclockwise",
                    fullWidth: true
                ) {
                    viewModel.discardRecording()
                }
            }
            .crateScreenPadding()
            .padding(.bottom, 32)
        }
    }
}

// MARK: - CRATE Audio Level Bars

struct CrateAudioLevelBars: View {
    let level: CGFloat
    let isActive: Bool

    private let barCount = 24

    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 2) {
                ForEach(0..<barCount, id: \.self) { index in
                    let barLevel = barHeight(for: index, totalBars: barCount, level: level)
                    RoundedRectangle(cornerRadius: 1)
                        .fill(barColor(for: index, totalBars: barCount))
                        .frame(
                            width: max(2, (geometry.size.width - CGFloat(barCount - 1) * 2) / CGFloat(barCount)),
                            height: isActive ? max(3, geometry.size.height * barLevel) : 3
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
            return CrateColors.error
        } else if ratio > 0.65 {
            return CrateColors.accent
        }
        return CrateColors.accentDim
    }
}

// Keep backward compatibility alias
typealias AudioLevelBars = CrateAudioLevelBars
