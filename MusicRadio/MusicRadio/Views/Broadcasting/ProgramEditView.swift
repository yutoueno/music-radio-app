import SwiftUI

struct ProgramEditView: View {
    @StateObject private var viewModel = ProgramEditViewModel()
    @Environment(\.dismiss) private var dismiss
    var editingProgramId: String?

    /// Optional initial audio data (e.g. from in-app recording).
    var initialAudioData: Data?
    var initialAudioFileName: String?

    @State private var currentStep: Int = 0
    private let totalSteps = 4

    var body: some View {
        VStack(spacing: 0) {
            // Step Indicator
            stepIndicator
                .padding(.top, 12)
                .padding(.bottom, CrateTheme.Spacing.sectionGap)

            // Step Content
            TabView(selection: $currentStep) {
                step1AudioUpload
                    .tag(0)

                step2ProgramInfo
                    .tag(1)

                step3TrackTiming
                    .tag(2)

                step4SchedulePublish
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(CrateTheme.Animation.standard, value: currentStep)

            // Navigation Buttons
            navigationButtons
                .padding(.horizontal, CrateTheme.Spacing.screenMargin)
                .padding(.bottom, 16)
        }
        .background(CrateColors.void.ignoresSafeArea())
        .navigationTitle(editingProgramId != nil ? "Edit Program" : "New Show")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundColor(CrateColors.textSecondary)
                }
            }
        }
        .overlay {
            if viewModel.isSaving || viewModel.isUploading {
                savingOverlay
            }
        }
        .onFirstAppear {
            if let id = editingProgramId {
                await viewModel.loadProgram(id: id)
            }
            if let data = initialAudioData, let fileName = initialAudioFileName {
                viewModel.setAudioFile(data: data, fileName: fileName)
            }
        }
        .errorAlert(error: $viewModel.errorMessage)
    }

    // MARK: - Step Indicator

    private var stepIndicator: some View {
        HStack(spacing: 12) {
            ForEach(0..<totalSteps, id: \.self) { step in
                VStack(spacing: 6) {
                    Circle()
                        .fill(step == currentStep ? CrateColors.accent : (step < currentStep ? CrateColors.accentDim : CrateColors.elevated))
                        .frame(width: 10, height: 10)
                        .overlay {
                            if step < currentStep {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 6, weight: .bold))
                                    .foregroundColor(CrateColors.void)
                            }
                        }

                    Text(stepLabel(for: step))
                        .font(.system(size: 9, weight: .medium))
                        .tracking(0.5)
                        .foregroundColor(step == currentStep ? CrateColors.textPrimary : CrateColors.textTertiary)
                        .textCase(.uppercase)
                }
            }
        }
        .crateScreenPadding()
    }

    private func stepLabel(for step: Int) -> String {
        switch step {
        case 0: return "Audio"
        case 1: return "Info"
        case 2: return "Tracks"
        case 3: return "Publish"
        default: return ""
        }
    }

    // MARK: - Step 1: Audio Upload

    private var step1AudioUpload: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CrateTheme.Spacing.sectionGap) {
                VStack(alignment: .leading, spacing: CrateTheme.Spacing.textGapMedium) {
                    Text("AUDIO FILE")
                        .crateText(.sectionLabel, color: CrateColors.textSecondary)

                    Text("Upload or record the audio for your show.")
                        .crateText(.body, color: CrateColors.textSecondary)
                }

                AudioUploadView(viewModel: viewModel)
            }
            .crateScreenPadding()
        }
    }

    // MARK: - Step 2: Program Info

    private var step2ProgramInfo: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CrateTheme.Spacing.sectionGap) {
                Text("PROGRAM INFO")
                    .crateText(.sectionLabel, color: CrateColors.textSecondary)

                VStack(spacing: 16) {
                    CrateLabeledTextField(
                        label: "Title",
                        placeholder: "Enter program title",
                        text: $viewModel.title
                    )

                    // Program Type Picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("TYPE")
                            .font(.system(size: 10, weight: .semibold))
                            .tracking(1.5)
                            .foregroundColor(CrateColors.textSecondary)

                        Menu {
                            ForEach(ProgramType.allCases, id: \.self) { type in
                                Button {
                                    viewModel.programType = type
                                } label: {
                                    Label(type.displayName, systemImage: type.iconName)
                                }
                            }
                        } label: {
                            HStack {
                                Label(viewModel.programType.displayName, systemImage: viewModel.programType.iconName)
                                    .crateText(.body)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                                    .foregroundColor(CrateColors.textTertiary)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 14)
                            .background(CrateColors.elevated)
                            .cornerRadius(8)
                        }
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DESCRIPTION")
                            .font(.system(size: 10, weight: .semibold))
                            .tracking(1.5)
                            .foregroundColor(CrateColors.textSecondary)

                        ZStack(alignment: .topLeading) {
                            if viewModel.description.isEmpty {
                                Text("Add a description (optional)")
                                    .foregroundColor(CrateColors.textMuted)
                                    .padding(.horizontal, 14)
                                    .padding(.top, 14)
                            }
                            TextEditor(text: $viewModel.description)
                                .font(.system(size: 15))
                                .foregroundColor(CrateColors.textPrimary)
                                .scrollContentBackground(.hidden)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                        }
                        .frame(minHeight: 100)
                        .background(CrateColors.elevated)
                        .cornerRadius(8)
                    }
                }
            }
            .crateScreenPadding()
        }
    }

    // MARK: - Step 3: Track Timing

    private var step3TrackTiming: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CrateTheme.Spacing.sectionGap) {
                HStack {
                    Text("TRACKS")
                        .crateText(.sectionLabel, color: CrateColors.textSecondary)

                    Spacer()

                    Text("\(viewModel.tracks.count) tracks")
                        .crateText(.caption, color: CrateColors.textTertiary)
                }

                // Track List
                if viewModel.tracks.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 32, weight: .light))
                            .foregroundColor(CrateColors.textTertiary)

                        Text("No tracks added yet")
                            .crateText(.body, color: CrateColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                } else {
                    VStack(spacing: CrateTheme.Spacing.cardGap) {
                        ForEach(Array(viewModel.tracks.enumerated()), id: \.element.id) { index, _ in
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
                    }
                }

                // Add Track Search
                trackSearchSection
            }
            .crateScreenPadding()
        }
    }

    private var trackSearchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ADD FROM APPLE MUSIC")
                .crateText(.sectionLabel, color: CrateColors.textSecondary)

            HStack(spacing: CrateTheme.Spacing.inline) {
                CrateTextField(
                    placeholder: "Search tracks...",
                    text: $viewModel.trackSearchQuery,
                    onSubmit: {
                        Task { await viewModel.searchTracks() }
                    }
                )

                if viewModel.isSearchingTracks {
                    ProgressView()
                        .tint(CrateColors.accent)
                } else {
                    Button {
                        Task { await viewModel.searchTracks() }
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16))
                            .foregroundColor(CrateColors.accent)
                            .frame(width: 44, height: 44)
                            .background(CrateColors.elevated)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }

            if !viewModel.trackSearchResults.isEmpty {
                VStack(spacing: 2) {
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
                                            .fill(CrateColors.elevated)
                                            .frame(width: 44, height: 44)
                                    }
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(song.title)
                                        .crateText(.body)
                                        .lineLimit(1)
                                    Text(song.artistName)
                                        .crateText(.caption, color: CrateColors.textSecondary)
                                        .lineLimit(1)
                                }

                                Spacer()

                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(CrateColors.accent)
                            }
                            .padding(CrateTheme.Spacing.cardPadding)
                            .background(CrateColors.surface)
                            .cornerRadius(CrateTheme.CornerRadius.medium)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Step 4: Schedule & Publish

    private var step4SchedulePublish: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CrateTheme.Spacing.sectionGap) {
                Text("SCHEDULE & PUBLISH")
                    .crateText(.sectionLabel, color: CrateColors.textSecondary)

                // Summary Card
                VStack(alignment: .leading, spacing: 16) {
                    summaryRow(label: "Title", value: viewModel.title.isEmpty ? "Untitled" : viewModel.title)
                    summaryRow(label: "Type", value: viewModel.programType.displayName)
                    summaryRow(label: "Audio", value: viewModel.audioFileName ?? "No file selected")
                    summaryRow(label: "Tracks", value: "\(viewModel.tracks.count) tracks")
                }
                .padding(CrateTheme.Spacing.cardPadding + 4)
                .background(CrateColors.elevated)
                .cornerRadius(CrateTheme.CornerRadius.large)
                .overlay(
                    RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.large)
                        .stroke(CrateColors.border, lineWidth: 0.5)
                )

                // Publish Actions
                VStack(spacing: 12) {
                    CrateButton(
                        title: "Save & Publish",
                        variant: .primary,
                        icon: "paperplane.fill",
                        isLoading: viewModel.isSaving,
                        isDisabled: viewModel.title.isEmpty,
                        fullWidth: true
                    ) {
                        Task {
                            await viewModel.saveProgram()
                            if viewModel.errorMessage == nil {
                                await viewModel.publishProgram()
                                if viewModel.errorMessage == nil {
                                    dismiss()
                                }
                            }
                        }
                    }

                    CrateButton(
                        title: "Save as Draft",
                        variant: .secondary,
                        icon: "square.and.arrow.down",
                        isLoading: viewModel.isSaving,
                        isDisabled: viewModel.title.isEmpty,
                        fullWidth: true
                    ) {
                        Task {
                            await viewModel.saveProgram()
                            if viewModel.errorMessage == nil {
                                dismiss()
                            }
                        }
                    }
                }
            }
            .crateScreenPadding()
        }
    }

    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .tracking(1.5)
                .foregroundColor(CrateColors.textTertiary)
                .frame(width: 60, alignment: .leading)

            Text(value)
                .crateText(.body)
                .lineLimit(1)

            Spacer()
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if currentStep > 0 {
                CrateButton(
                    title: "Back",
                    variant: .secondary,
                    icon: "chevron.left"
                ) {
                    withAnimation(CrateTheme.Animation.standard) {
                        currentStep -= 1
                    }
                }
            }

            Spacer()

            if currentStep < totalSteps - 1 {
                CrateButton(
                    title: "Next",
                    variant: .primary,
                    icon: "chevron.right"
                ) {
                    withAnimation(CrateTheme.Animation.standard) {
                        currentStep += 1
                    }
                }
            }
        }
    }

    // MARK: - Saving Overlay

    private var savingOverlay: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .overlay {
                VStack(spacing: 16) {
                    ProgressView()
                        .tint(CrateColors.accent)

                    Text(viewModel.isUploading ? "Uploading audio..." : "Saving...")
                        .crateText(.body, color: CrateColors.textSecondary)
                }
                .padding(24)
                .background(CrateColors.elevated)
                .cornerRadius(CrateTheme.CornerRadius.large)
            }
    }
}
