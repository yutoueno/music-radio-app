import SwiftUI

struct PoCResultView: View {
    @ObservedObject var viewModel: PoCTestViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // GO / NO-GO Header
                goNoGoHeader

                // Detailed Results
                detailedResults

                // Recommendations
                recommendationsSection
            }
            .padding()
        }
        .navigationTitle("PoC Results")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - GO / NO-GO

    private var goNoGoHeader: some View {
        VStack(spacing: 16) {
            let isGo = viewModel.overallResult == .passed

            ZStack {
                Circle()
                    .fill(isGo ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                    .frame(width: 120, height: 120)

                VStack(spacing: 4) {
                    Image(systemName: isGo ? "checkmark.seal.fill" : "xmark.seal.fill")
                        .font(.system(size: 40))
                        .foregroundColor(isGo ? .green : .red)

                    Text(isGo ? "GO" : "NO-GO")
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(isGo ? .green : .red)
                }
            }

            Text(verdictMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 16)
    }

    private var verdictMessage: String {
        let passed = viewModel.allTestStatuses.filter { $0.1 == .passed }.count
        let total = viewModel.allTestStatuses.count
        let failed = viewModel.allTestStatuses.filter {
            if case .failed = $0.1 { return true }
            return false
        }.count
        let untested = viewModel.allTestStatuses.filter { $0.1 == .untested }.count

        if passed == total {
            return "All \(total) PoC items verified successfully. The project is cleared to proceed to Phase 1 development."
        } else if untested == total {
            return "No tests have been run yet. Please execute all test items before making a GO/NO-GO decision."
        } else if failed > 0 {
            return "\(failed) of \(total) test(s) failed. Review the failures below and address blocking issues before proceeding."
        } else {
            return "\(passed) of \(total) tests completed. Run remaining tests for full verification."
        }
    }

    // MARK: - Detailed Results

    private var detailedResults: some View {
        VStack(spacing: 16) {
            Text("Detailed Results")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(viewModel.allTestStatuses, id: \.0) { name, status in
                resultCard(name: name, status: status)
            }
        }
    }

    private func resultCard(name: String, status: PoCTestStatus) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: status.icon)
                    .font(.title3)
                    .foregroundColor(status.color)

                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Text(status.label)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(status.color)
                    .cornerRadius(8)
            }

            Text(descriptionForTest(name))
                .font(.caption)
                .foregroundColor(.secondary)

            if case .failed(let msg) = status {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text(msg)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(8)
                .background(Color.red.opacity(0.08))
                .cornerRadius(6)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private func descriptionForTest(_ name: String) -> String {
        if name.contains("P-1") {
            return "Verifies that AVAudioPlayer (radio) and ApplicationMusicPlayer (Apple Music) can produce audio at the same time without one silencing the other."
        } else if name.contains("P-2") {
            return "Confirms that .mixWithOthers and .duckOthers audio session options work correctly, allowing radio volume to be reduced while Apple Music plays."
        } else if name.contains("P-3") {
            return "Tests that users without an Apple Music subscription can still hear a ~30-second preview of tracks."
        } else if name.contains("P-4") {
            return "Verifies that the audio session is configured for background playback so audio continues when the app is not in the foreground."
        } else if name.contains("P-5") {
            return "Confirms that an Apple Music URL (e.g. https://music.apple.com/...) can be parsed into a MusicKit Track ID for programmatic playback."
        }
        return ""
    }

    // MARK: - Recommendations

    private var recommendationsSection: some View {
        VStack(spacing: 12) {
            Text("Next Steps")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            let isGo = viewModel.overallResult == .passed

            if isGo {
                recommendationRow(
                    icon: "arrow.right.circle.fill",
                    color: .green,
                    text: "Proceed to Phase 1: Core audio infrastructure implementation"
                )
                recommendationRow(
                    icon: "doc.text",
                    color: .blue,
                    text: "Document PoC results and share with the team"
                )
                recommendationRow(
                    icon: "person.2",
                    color: .purple,
                    text: "Test on multiple devices and iOS versions"
                )
            } else {
                let failures = viewModel.allTestStatuses.filter {
                    if case .failed = $0.1 { return true }
                    return false
                }

                for (name, _) in failures {
                    recommendationRow(
                        icon: "wrench.fill",
                        color: .orange,
                        text: "Fix: \(name)"
                    )
                }

                let untested = viewModel.allTestStatuses.filter { $0.1 == .untested }
                if !untested.isEmpty {
                    recommendationRow(
                        icon: "play.circle",
                        color: .blue,
                        text: "Run \(untested.count) remaining test(s)"
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private func recommendationRow(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
