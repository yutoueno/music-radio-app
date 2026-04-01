import SwiftUI
import UniformTypeIdentifiers

struct AudioUploadView: View {
    @ObservedObject var viewModel: ProgramEditViewModel
    @State private var showFilePicker = false

    var body: some View {
        VStack(spacing: 16) {
            if let fileName = viewModel.audioFileName {
                // File selected
                HStack(spacing: 12) {
                    Image(systemName: "waveform.circle.fill")
                        .font(.title)
                        .foregroundColor(.accentColor)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(fileName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)

                        if let data = viewModel.audioFileData {
                            Text(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    Button {
                        viewModel.audioFileData = nil
                        viewModel.audioFileName = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

                // Upload progress
                if viewModel.isUploading {
                    VStack(spacing: 8) {
                        ProgressView(value: viewModel.uploadProgress)
                            .tint(.accentColor)
                        Text("\(Int(viewModel.uploadProgress * 100))% uploaded")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                // No file selected
                Button {
                    showFilePicker = true
                } label: {
                    VStack(spacing: 12) {
                        Image(systemName: "arrow.up.doc.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.accentColor)

                        Text("Select Audio File")
                            .font(.headline)
                            .foregroundColor(.accentColor)

                        Text("MP3, M4A, WAV, FLAC")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.accentColor.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [8]))
                    )
                }
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

    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }

            // Start accessing security-scoped resource
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
