import SwiftUI
import UniformTypeIdentifiers

struct AudioUploadView: View {
    @ObservedObject var viewModel: ProgramEditViewModel
    @State private var showFilePicker = false

    var body: some View {
        VStack(spacing: CrateTheme.Spacing.cardGap) {
            if let fileName = viewModel.audioFileName {
                // File selected state
                fileInfoCard(fileName: fileName)

                // Upload progress
                if viewModel.isUploading {
                    uploadProgressView
                }
            } else {
                // Empty upload area
                uploadDropZone
            }
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [
                UTType.audio,
                UTType.mp3,
                UTType.mpeg4Audio,
                UTType.wav
            ],
            allowsMultipleSelection: false
        ) { result in
            handleFileSelection(result)
        }
    }

    // MARK: - Upload Drop Zone

    private var uploadDropZone: some View {
        Button {
            showFilePicker = true
        } label: {
            VStack(spacing: 16) {
                Image(systemName: "arrow.up.circle")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(CrateColors.accent)

                VStack(spacing: CrateTheme.Spacing.textGapSmall) {
                    Text("Select Audio File")
                        .crateText(.h2)

                    Text("MP3, M4A, WAV, FLAC")
                        .crateText(.caption, color: CrateColors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .background(CrateColors.elevated)
            .cornerRadius(CrateTheme.CornerRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.large)
                    .strokeBorder(
                        Color(red: 51/255, green: 51/255, blue: 51/255),
                        style: StrokeStyle(lineWidth: 1.5, dash: [8, 6])
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - File Info Card

    private func fileInfoCard(fileName: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(CrateColors.accent)

            VStack(alignment: .leading, spacing: CrateTheme.Spacing.textGapSmall) {
                Text(fileName)
                    .crateText(.body)
                    .lineLimit(1)

                if let data = viewModel.audioFileData {
                    Text(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file))
                        .crateText(.caption, color: CrateColors.textSecondary)
                }
            }

            Spacer()

            Button {
                viewModel.audioFileData = nil
                viewModel.audioFileName = nil
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(CrateColors.textTertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(CrateTheme.Spacing.cardPadding)
        .background(CrateColors.elevated)
        .cornerRadius(CrateTheme.CornerRadius.medium)
    }

    // MARK: - Upload Progress

    private var uploadProgressView: some View {
        VStack(spacing: CrateTheme.Spacing.inline) {
            CrateProgressBar(progress: viewModel.uploadProgress)
                .frame(height: 3)

            Text("\(Int(viewModel.uploadProgress * 100))% uploaded")
                .crateText(.caption, color: CrateColors.textSecondary)
        }
        .padding(.horizontal, 4)
    }

    // MARK: - File Selection

    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }

            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }

            do {
                let data = try Data(contentsOf: url)
                viewModel.setAudioFile(data: data, fileName: url.lastPathComponent)
            } catch {
                viewModel.errorMessage = "Failed to read audio file: \(error.localizedDescription)"
            }

        case .failure(let error):
            viewModel.errorMessage = "File selection failed: \(error.localizedDescription)"
        }
    }
}
