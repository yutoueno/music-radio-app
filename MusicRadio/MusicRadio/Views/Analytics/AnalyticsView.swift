import SwiftUI

struct AnalyticsView: View {
    @StateObject private var viewModel = AnalyticsViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.overview == nil {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        overviewCards
                        programStatsSection
                    }
                    .padding()
                    .padding(.bottom, 80)
                }
            }
        }
        .navigationTitle("Analytics")
        .refreshable {
            await viewModel.refresh()
        }
        .onFirstAppear {
            await viewModel.loadAll()
        }
        .errorAlert(error: $viewModel.errorMessage)
    }

    // MARK: - Overview Cards

    private var overviewCards: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            overviewCard(
                title: "Total Plays",
                value: "\(viewModel.overview?.totalPlays ?? 0)",
                iconName: "play.fill",
                iconColor: .blue,
                subtitle: weeklyGrowthText
            )
            overviewCard(
                title: "Favorites",
                value: "\(viewModel.overview?.totalFavorites ?? 0)",
                iconName: "heart.fill",
                iconColor: .pink,
                subtitle: nil
            )
            overviewCard(
                title: "Followers",
                value: "\(viewModel.overview?.totalFollowers ?? 0)",
                iconName: "person.2.fill",
                iconColor: .purple,
                subtitle: nil
            )
            overviewCard(
                title: "Programs",
                value: "\(viewModel.overview?.totalPrograms ?? 0)",
                iconName: "radio",
                iconColor: .orange,
                subtitle: nil
            )
        }
    }

    private var weeklyGrowthText: String? {
        guard let growth = viewModel.overview?.playsGrowthPercentage else { return nil }
        let sign = growth >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", growth))% this week"
    }

    private func overviewCard(
        title: String,
        value: String,
        iconName: String,
        iconColor: Color,
        subtitle: String?
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconName)
                    .font(.subheadline)
                    .foregroundColor(iconColor)
                Spacer()
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(subtitle.hasPrefix("+") ? .green : .red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Program Stats

    @ViewBuilder
    private var programStatsSection: some View {
        if !viewModel.programStats.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Program Performance")
                    .font(.title3)
                    .fontWeight(.bold)

                ForEach(viewModel.programStats) { stat in
                    programStatRow(stat)
                }
            }
        }
    }

    private func programStatRow(_ stat: AnalyticsProgramStats) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .overlay {
                    Image(systemName: "radio")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 4) {
                Text(stat.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundColor(.primary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "play.fill")
                        .font(.caption2)
                    Text("\(stat.playCount)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.primary)

                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                    Text("\(stat.favoriteCount)")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
