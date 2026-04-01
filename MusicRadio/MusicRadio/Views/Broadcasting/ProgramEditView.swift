import SwiftUI

struct ProgramEditView: View {
    @StateObject private var viewModel = ProgramEditViewModel()
    @Environment(\.dismiss) private var dismiss
    var editingProgramId: String?

    /// Optional initial audio data (e.g. from in-app recording).
    var initialAudioData: Data?
    var initialAudioFileName: String?

    var body: some View {
        Form {
            Section("Program Details") {
                TextField("Title", text: $viewModel.title)

                Picker("Type", selection: $viewModel.programType) {
                    ForEach(ProgramType.allCases, id: \.self) { type in
                        Label(type.displayName, systemImage: type.iconName)
                            .tag(type)
                    }
                }

                ZStack(alignment: .topLeading) {
                    if viewModel.description.isEmpty {
                        Text("Description (optional)")
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                    TextEditor(text: $viewModel.description)
                        .frame(minHeight: 80)
                }
            }

            Section("Audio File") {
                AudioUploadView(viewModel: viewModel)
            }

            Section {
                trackSection
            } header: {
                HStack {
                    Text("Tracks")
                    Spacer()
                    Text("\(viewModel.tracks.count) tracks")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Track Search
            Section("Add Track from Apple Music") {
                HStack {
                    TextField("Search tracks...", text: $viewModel.trackSearchQuery)
                        .textFieldStyle(.plain)
                        .onSubmit {
                            Task { await viewModel.searchTracks() }
                        }

                    if viewModel.isSearchingTracks {
                        ProgressView()
                    } else {
                        Button {
                            Task { await viewModel.searchTracks() }
                        } label: {
                            Image(systemName: "magnifyingglass")
                        }
                    }
                }

                if !viewModel.trackSearchResults.isEmpty {
                    ForEach(viewModel.trackSearchResults, id: \.id) { song in
                        Button {
                            viewModel.addTrack(from: song)
                        } label: {
                            HStack(spacing: 12) {
                                if let artwork = song.artwork {
                                    AsyncImage(url: artwork.url(width: 44, height: 44)) { image in
                                        image
                                            .resizable()
                                            .frame(width: 44, height: 44)
                                            .cornerRadius(4)
                                    } placeholder: {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color(.systemGray5))
                                            .frame(width: 44, height: 44)
                                    }
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(song.title)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    Text(song.artistName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }

                                Spacer()

                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(editingProgramId != nil ? "Edit Program" : "New Program")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        Task {
                            await viewModel.saveProgram()
                            if viewModel.errorMessage == nil {
                                dismiss()
                            }
                        }
                    } label: {
                        Label("Save as Draft", systemImage: "square.and.arrow.down")
                    }

                    Button {
                        Task {
                            await viewModel.saveProgram()
                            if viewModel.errorMessage == nil {
                                await viewModel.publishProgram()
                                if viewModel.errorMessage == nil {
                                    dismiss()
                                }
                            }
                        }
                    } label: {
                        Label("Save & Publish", systemImage: "paperplane.fill")
                    }
                } label: {
                    Text("Save")
                        .fontWeight(.semibold)
                }
                .disabled(viewModel.isSaving || viewModel.isUploading)
            }
        }
        .overlay {
            if viewModel.isSaving || viewModel.isUploading {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .overlay {
                        VStack(spacing: 12) {
                            ProgressView()
                            Text(viewModel.isUploading ? "Uploading audio..." : "Saving...")
                                .font(.subheadline)
                        }
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(12)
                    }
            }
        }
        .onFirstAppear {
            if let id = editingProgramId {
                await viewModel.loadProgram(id: id)
            }
            // Apply initial audio from recording if provided
            if let data = initialAudioData, let fileName = initialAudioFileName {
                viewModel.setAudioFile(data: data, fileName: fileName)
            }
        }
        .errorAlert(error: $viewModel.errorMessage)
    }

    @ViewBuilder
    private var trackSection: some View {
        if viewModel.tracks.isEmpty {
            Text("No tracks added yet")
                .foregroundColor(.secondary)
                .font(.subheadline)
        } else {
            ForEach(Array(viewModel.tracks.enumerated()), id: \.element.id) { index, track in
                TrackTimingEditor(
                    track: Binding(
                        get: { viewModel.tracks[index] },
                        set: { viewModel.tracks[index] = $0 }
                    ),
                    index: index,
                    onDelete: {
                        viewModel.removeTrack(at: index)
                    }
                )
            }
            .onMove { source, destination in
                viewModel.moveTrack(from: source, to: destination)
            }
        }
    }
}
