import SwiftUI

struct AnalyticsView: View {
    @StateObject private var viewModel = AnalyticsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            analyticsHeader

            // Content
            Group {
                if viewModel.isLoading && viewModel.overview == nil {
                    loadingState
                } else {
                    ScrollView {
                        VStack(spacing: CrateTheme.Spacing.sectionGap) {
                            overviewCards
                            topProgramsSection
                        }
                        .padding(.horizontal, CrateTheme.Spacing.screenMargin)
                        .padding(.top, 4)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .background(CrateColors.void)
        .navigationBarHidden(true)
        .refreshable {
            await viewModel.refresh()
        }
        .onFirstAppear {
            await viewModel.loadAll()
        }
        .errorAlert(error: $viewModel.errorMessage)
    }

    // MARK: - Header

    private var analyticsHeader: some View {
        HStack {
            Text("ANALYTICS")
                .crateText(.sectionLabel, color: CrateColors.textSecondary)
            Spacer()
        }
        .padding(.horizontal, CrateTheme.Spacing.screenMargin)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Loading

    private var loadingState: some View {
        VStack(spacing: CrateTheme.Spacing.sectionGap) {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: CrateTheme.Spacing.cardGap),
                GridItem(.flexible(), spacing: CrateTheme.Spacing.cardGap)
            ], spacing: CrateTheme.Spacing.cardGap) {
                ForEach(0..<4, id: \.self) { _ in
                    SkeletonView(height: 110, cornerRadius: CrateTheme.CornerRadius.medium)
                }
            }

            VStack(spacing: CrateTheme.Spacing.cardGap) {
                SkeletonLine(width: 140, height: 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ForEach(0..<3, id: \.self) { _ in
                    SkeletonProgramCard()
                }
            }
        }
        .padding(.horizontal, CrateTheme.Spacing.screenMargin)
        .padding(.top, 4)
    }

    // MARK: - Overview Cards

    private var overviewCards: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: CrateTheme.Spacing.cardGap),
            GridItem(.flexible(), spacing: CrateTheme.Spacing.cardGap)
        ], spacing: CrateTheme.Spacing.cardGap) {
            statCard(
                label: "Total Plays",
                value: "\(viewModel.overview?.totalPlays ?? 0)",
                icon: "play.fill",
                highlight: true,
                subtitle: weeklyGrowthText
            )
            statCard(
                label: "Favorites",
                value: "\(viewModel.overview?.totalFavorites ?? 0)",
                icon: "heart.fill",
                highlight: false,
                subtitle: nil
            )
            statCard(
                label: "Followers",
                value: "\(viewModel.overview?.totalFollowers ?? 0)",
                icon: "person.2.fill",
                highlight: false,
                subtitle: nil
            )
            statCard(
                label: "Programs",
                value: "\(viewModel.overview?.totalPrograms ?? 0)",
                icon: "radio",
                highlight: false,
                subtitle: nil
            )
        }
    }

    private var weeklyGrowthText: String? {
        guard let growth = viewModel.overview?.playsGrowthPercentage else { return nil }
        let sign = growth >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", growth))% this week"
    }

    private func statCard(
        label: String,
        value: String,
        icon: String,
        highlight: Bool,
        subtitle: String?
    ) -> some View {
        VStack(alignment: .leading, spacing: CrateTheme.Spacing.textGapMedium) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(CrateColors.accent)

            Spacer(minLength: 0)

            // Value
            Text(value)
                .font(CrateTypography.h1)
                .tracking(CrateTypography.headingTracking)
                .foregroundColor(highlight ? CrateColors.accent : CrateColors.textPrimary)

            // Label
            Text(label.uppercased())
                .font(CrateTypography.meta)
                .tracking(CrateTypography.captionTracking)
                .foregroundColor(CrateColors.textTertiary)

            // Subtitle (growth)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(CrateTypography.timestamp)
                    .foregroundColor(
                        subtitle.hasPrefix("+") ? CrateColors.success : CrateColors.error
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 100)
        .padding(CrateTheme.Spacing.cardPadding)
        .background(CrateColors.surface)
        .cornerRadius(CrateTheme.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.medium)
                .stroke(CrateColors.border, lineWidth: 0.5)
        )
    }

    // MARK: - Top Programs

    @ViewBuilder
    private var topProgramsSection: some View {
        if !viewModel.programStats.isEmpty {
            VStack(alignment: .leading, spacing: CrateTheme.Spacing.cardGap) {
                Text("TOP PROGRAMS")
                    .crateText(.sectionLabel, color: CrateColors.textSecondary)
                    .padding(.bottom, 4)

                ForEach(Array(viewModel.programStats.enumerated()), id: \.element.id) { index, stat in
                    programStatRow(stat, rank: index + 1)
                }
            }
        }
    }

    private func programStatRow(_ stat: AnalyticsProgramStats, rank: Int) -> some View {
        HStack(spacing: 12) {
            // Rank number
            Text("\(rank)")
                .font(CrateTypography.timestamp)
                .foregroundColor(CrateColors.textMuted)
                .frame(width: 20, alignment: .center)

            // Thumbnail placeholder
            ZStack {
                RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.small)
                    .fill(CrateColors.elevated)
                    .frame(width: 48, height: 48)

                Image(systemName: "radio")
                    .font(.system(size: 16))
                    .foregroundColor(CrateColors.textTertiary)
            }

            // Title
            VStack(alignment: .leading, spacing: CrateTheme.Spacing.textGapSmall) {
                Text(stat.title)
                    .font(CrateTypography.body)
                    .foregroundColor(CrateColors.textPrimary)
                    .lineLimit(1)
            }

            Spacer()

            // Stats
            VStack(alignment: .trailing, spacing: CrateTheme.Spacing.textGapSmall) {
                HStack(spacing: 4) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 9))
                    Text("\(stat.playCount)")
                        .font(CrateTypography.caption)
                }
                .foregroundColor(CrateColors.textPrimary)

                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 9))
                    Text("\(stat.favoriteCount)")
                        .font(CrateTypography.meta)
                }
                .foregroundColor(CrateColors.textTertiary)
            }
        }
        .padding(CrateTheme.Spacing.cardPadding)
        .background(CrateColors.surface)
        .cornerRadius(CrateTheme.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.medium)
                .stroke(CrateColors.border, lineWidth: 0.5)
        )
    }
}
