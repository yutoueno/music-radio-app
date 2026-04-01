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
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                // Track artwork
                AsyncImage(url: URL(string: track.artworkUrl ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .overlay {
                            Image(systemName: "music.note")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                }
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 4))

                VStack(alignment: .leading, spacing: 2) {
                    Text(track.trackName)
                        .font(.subheadline)
                        .lineLimit(1)
                    Text(track.artistName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                }
            }

            // Timing editor
            HStack {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("Play at:")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button {
                    showTimingPicker.toggle()
                } label: {
                    Text(TimeInterval(track.playTimingSeconds).formattedTimingHHMMSS)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .monospacedDigit()
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                }

                Spacer()

                Text("#\(index + 1)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if showTimingPicker {
                timingPickerView
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            updateTimingComponents()
        }
    }

    @ViewBuilder
    private var timingPickerView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 4) {
                timingField(label: "H", value: $hours, range: 0...23)
                Text(":")
                    .font(.title3)
                    .fontWeight(.medium)
                timingField(label: "M", value: $minutes, range: 0...59)
                Text(":")
                    .font(.title3)
                    .fontWeight(.medium)
                timingField(label: "S", value: $seconds, range: 0...59)
            }

            Button("Apply") {
                track.playTimingSeconds = hours * 3600 + minutes * 60 + seconds
                showTimingPicker = false
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.accentColor)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }

    private func timingField(label: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            Picker(label, selection: value) {
                ForEach(range, id: \.self) { num in
                    Text(String(format: "%02d", num))
                        .tag(num)
                        .monospacedDigit()
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
