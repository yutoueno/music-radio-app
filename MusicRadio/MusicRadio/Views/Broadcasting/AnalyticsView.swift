import SwiftUI

struct BroadcasterAnalyticsView: View {
    @StateObject private var viewModel = AnalyticsViewModel()

    var body: some View {
        ScrollView {
            if viewModel.isLoading && viewModel.overview == nil {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 300)
            } else {
                VStack(spacing: 24) {
                    overviewCards
                    playTrendChart
                    programStatsList
                    topTracksList
                }
                .padding()
            }
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            await viewModel.loadAll()
        }
        .onFirstAppear {
            await viewModel.loadAll()
        }
        .errorAlert(error: $viewModel.errorMessage)
    }

    // MARK: - Overview Cards

    @ViewBuilder
    private var overviewCards: some View {
        if let overview = viewModel.overview {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 16) {
                AnalyticsCard(
                    title: "Total Plays",
                    value: "\(overview.totalPlays)",
                    icon: "play.fill",
                    color: .blue
                )
                AnalyticsCard(
                    title: "Favorites",
                    value: "\(overview.totalFavorites)",
                    icon: "heart.fill",
                    color: .pink
                )
                AnalyticsCard(
                    title: "Followers",
                    value: "\(overview.totalFollowers)",
                    icon: "person.2.fill",
                    color: .purple
                )
                AnalyticsCard(
                    title: "Programs",
                    value: "\(overview.totalPrograms)",
                    icon: "radio.fill",
                    color: .orange
                )
            }
        }
    }

    // MARK: - Play Trend Chart

    @ViewBuilder
    private var playTrendChart: some View {
        if !viewModel.playTrends.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Play Trends (30 days)")
                    .font(.headline)

                PlayTrendBarChart(trends: viewModel.playTrends)
                    .frame(height: 150)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
    }

    // MARK: - Program Stats

    @ViewBuilder
    private var programStatsList: some View {
        if !viewModel.programStats.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Program Stats")
                    .font(.headline)

                ForEach(viewModel.programStats) { stat in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(stat.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(1)

                            HStack(spacing: 12) {
                                Label("\(stat.playCount)", systemImage: "play.fill")
                                Label("\(stat.favoriteCount)", systemImage: "heart.fill")
                                if let avg = stat.avgListenDuration {
                                    Label(String(format: "%.0fs avg", avg), systemImage: "clock")
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
        }
    }

    // MARK: - Top Tracks

    @ViewBuilder
    private var topTracksList: some View {
        if !viewModel.topTracks.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Top Tracks")
                    .font(.headline)

                ForEach(viewModel.topTracks) { track in
                    HStack(spacing: 12) {
                        if let artworkUrl = track.artworkUrl, let url = URL(string: artworkUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .frame(width: 44, height: 44)
                                    .cornerRadius(6)
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(.systemGray5))
                                    .frame(width: 44, height: 44)
                            }
                        } else {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(.systemGray5))
                                .frame(width: 44, height: 44)
                                .overlay {
                                    Image(systemName: "music.note")
                                        .foregroundColor(.secondary)
                                }
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(track.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(1)
                            Text(track.artistName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }

                        Spacer()

                        Text("\(track.totalAppearances)x")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
        }
    }
}

// MARK: - Analytics Card

private struct AnalyticsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

// MARK: - Play Trend Bar Chart

private struct PlayTrendBarChart: View {
    let trends: [DailyPlayTrend]

    var body: some View {
        GeometryReader { geometry in
            let maxCount = trends.map(\.count).max() ?? 1
            let barWidth = max(2, (geometry.size.width - CGFloat(trends.count) * 2) / CGFloat(trends.count))

            HStack(alignment: .bottom, spacing: 2) {
                ForEach(trends) { trend in
                    let height = maxCount > 0
                        ? CGFloat(trend.count) / CGFloat(maxCount) * geometry.size.height * 0.85
                        : 0

                    VStack(spacing: 2) {
                        Spacer()
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.accentColor.opacity(0.8))
                            .frame(width: barWidth, height: max(2, height))
                    }
                }
            }
        }
    }
}
