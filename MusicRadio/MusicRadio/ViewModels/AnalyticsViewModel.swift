import Foundation

// MARK: - Analytics Models

struct AnalyticsOverview: Codable {
    let totalPlays: Int
    let totalFavorites: Int
    let totalFollowers: Int
    let totalPrograms: Int
    let playsThisWeek: Int?
    let playsLastWeek: Int?
    let favoritesThisWeek: Int?

    var playsGrowthPercentage: Double? {
        guard let thisWeek = playsThisWeek,
              let lastWeek = playsLastWeek,
              lastWeek > 0 else { return nil }
        return Double(thisWeek - lastWeek) / Double(lastWeek) * 100
    }
}

struct AnalyticsProgramStats: Codable, Identifiable {
    let programId: String
    let title: String
    let playCount: Int
    let favoriteCount: Int
    let avgListenDuration: Double?

    var id: String { programId }
}

struct DailyPlayTrend: Codable, Identifiable {
    let date: String
    let count: Int

    var id: String { date }
}

struct AnalyticsTopTrack: Codable, Identifiable {
    let appleMusicTrackId: String
    let title: String
    let artistName: String
    let artworkUrl: String?
    let totalAppearances: Int

    var id: String { appleMusicTrackId }
}

// MARK: - ViewModel

@MainActor
final class AnalyticsViewModel: ObservableObject {
    @Published var overview: AnalyticsOverview?
    @Published var programStats: [AnalyticsProgramStats] = []
    @Published var playTrends: [DailyPlayTrend] = []
    @Published var topTracks: [AnalyticsTopTrack] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient = APIClient.shared

    func loadAll() async {
        isLoading = true
        errorMessage = nil

        async let overviewTask: Void = loadOverview()
        async let programsTask: Void = loadProgramStats()
        async let trendsTask: Void = loadPlayTrends()
        async let tracksTask: Void = loadTopTracks()

        _ = await (overviewTask, programsTask, trendsTask, tracksTask)

        isLoading = false
    }

    private func loadOverview() async {
        do {
            let response: APIResponse<AnalyticsOverview> = try await apiClient.request(
                endpoint: .analyticsOverview,
                responseType: APIResponse<AnalyticsOverview>.self
            )
            overview = response.data
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadProgramStats() async {
        do {
            let response: APIResponse<[AnalyticsProgramStats]> = try await apiClient.request(
                endpoint: .analyticsProgramStats,
                responseType: APIResponse<[AnalyticsProgramStats]>.self
            )
            programStats = response.data
        } catch {
            // Non-critical, don't override error
        }
    }

    private func loadPlayTrends() async {
        do {
            let response: APIResponse<[DailyPlayTrend]> = try await apiClient.request(
                endpoint: .analyticsPlayTrends(days: 30),
                responseType: APIResponse<[DailyPlayTrend]>.self
            )
            playTrends = response.data
        } catch {
            // Non-critical
        }
    }

    private func loadTopTracks() async {
        do {
            let response: APIResponse<[AnalyticsTopTrack]> = try await apiClient.request(
                endpoint: .analyticsTopTracks,
                responseType: APIResponse<[AnalyticsTopTrack]>.self
            )
            topTracks = response.data
        } catch {
            // Non-critical
        }
    }

    func refresh() async {
        await loadAll()
    }
}
