import SwiftUI

struct TrackTimingEditor: View {
    @Binding var track: EditableTrack
    let index: Int
    let onDelete: () -> Void

    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    @State private var showTimingPicker = false

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                // Track artwork
                AsyncImage(url: URL(string: track.artworkUrl ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(CrateColors.elevated)
                        .overlay {
                            Image(systemName: "music.note")
                                .font(.system(size: 12))
                                .foregroundColor(CrateColors.textTertiary)
                        }
                }
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 4))

                VStack(alignment: .leading, spacing: CrateTheme.Spacing.textGapSmall) {
                    Text(track.trackName)
                        .crateText(.body)
                        .lineLimit(1)

                    Text(track.artistName)
                        .crateText(.caption, color: CrateColors.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                // Delete button
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(CrateColors.error)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            }

            // Timing row
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 12))
                    .foregroundColor(CrateColors.textTertiary)

                Text("Play at:")
                    .crateText(.caption, color: CrateColors.textSecondary)

                Button {
                    showTimingPicker.toggle()
                } label: {
                    Text(TimeInterval(track.playTimingSeconds).formattedTimingHHMMSS)
                        .crateText(.timestamp)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(CrateColors.elevated)
                        .cornerRadius(CrateTheme.CornerRadius.small)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("#\(index + 1)")
                    .crateText(.meta, color: CrateColors.textTertiary)
            }

            // Expandable timing picker
            if showTimingPicker {
                timingPickerView
                    .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
            }
        }
        .padding(CrateTheme.Spacing.cardPadding)
        .background(CrateColors.surface)
        .cornerRadius(CrateTheme.CornerRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.large)
                .stroke(CrateColors.border, lineWidth: 0.5)
        )
        .animation(CrateTheme.Animation.standard, value: showTimingPicker)
        .onAppear {
            updateTimingComponents()
        }
    }

    // MARK: - Timing Picker

    @ViewBuilder
    private var timingPickerView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 4) {
                timingField(label: "H", value: $hours, range: 0...23)
                Text(":")
                    .crateText(.h2, color: CrateColors.textTertiary)
                timingField(label: "M", value: $minutes, range: 0...59)
                Text(":")
                    .crateText(.h2, color: CrateColors.textTertiary)
                timingField(label: "S", value: $seconds, range: 0...59)
            }

            CrateButton(
                title: "Apply",
                variant: .primary,
                size: .compact
            ) {
                track.playTimingSeconds = hours * 3600 + minutes * 60 + seconds
                showTimingPicker = false
            }
        }
        .padding(CrateTheme.Spacing.cardPadding)
        .background(CrateColors.elevated)
        .cornerRadius(CrateTheme.CornerRadius.medium)
    }

    private func timingField(label: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .crateText(.meta, color: CrateColors.textTertiary)

            Picker(label, selection: value) {
                ForEach(range, id: \.self) { num in
                    Text(String(format: "%02d", num))
                        .tag(num)
                        .monospacedDigit()
                        .foregroundColor(CrateColors.textPrimary)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 60, height: 100)
            .clipped()
        }
    }

    private func updateTimingComponents() {
        let total = track.playTimingSeconds
        hours = total / 3600
        minutes = (total % 3600) / 60
        seconds = total % 60
    }
}
