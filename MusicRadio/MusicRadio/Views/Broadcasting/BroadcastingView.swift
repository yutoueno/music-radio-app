import SwiftUI

struct BroadcastingView: View {
    @StateObject private var viewModel = ProgramEditViewModel()
    @State private var showCreateProgram = false
    @State private var showRecording = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CrateTheme.Spacing.sectionGap) {
                // Header
                Text("PUBLISH")
                    .crateText(.h1)
                    .tracking(CrateTypography.sectionTracking)
                    .padding(.top, 8)

                // Action Cards Grid
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: CrateTheme.Spacing.cardGap),
                        GridItem(.flexible(), spacing: CrateTheme.Spacing.cardGap)
                    ],
                    spacing: CrateTheme.Spacing.cardGap
                ) {
                    // New Show
                    PublishActionCard(
                        icon: "plus.circle",
                        title: "New Show",
                        subtitle: "Create a new program"
                    ) {
                        showCreateProgram = true
                    }

                    // Record Audio
                    PublishActionCard(
                        icon: "mic",
                        title: "Record Audio",
                        subtitle: "Record your voice"
                    ) {
                        showRecording = true
                    }

                    // My Shows
                    NavigationLink {
                        MyProgramsView()
                    } label: {
                        PublishActionCardContent(
                            icon: "list.bullet.rectangle",
                            title: "My Shows",
                            subtitle: "Manage programs"
                        )
                    }
                    .buttonStyle(.plain)

                    // Analytics
                    NavigationLink {
                        BroadcasterAnalyticsView()
                    } label: {
                        PublishActionCardContent(
                            icon: "chart.bar",
                            title: "Analytics",
                            subtitle: "View statistics"
                        )
                    }
                    .buttonStyle(.plain)
                }

                Spacer(minLength: 100)
            }
            .crateScreenPadding()
        }
        .background(CrateColors.void.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCreateProgram) {
            NavigationStack {
                ProgramEditView()
            }
        }
        .sheet(isPresented: $showRecording) {
            NavigationStack {
                RecordingView()
            }
        }
    }
}

// MARK: - Publish Action Card (Button)

private struct PublishActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            PublishActionCardContent(icon: icon, title: title, subtitle: subtitle)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Publish Action Card Content

private struct PublishActionCardContent: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: CrateTheme.Spacing.textGapMedium) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .light))
                .foregroundColor(CrateColors.accent)
                .frame(width: 40, height: 40)
                .background(CrateColors.accentGlow)
                .clipShape(RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.small))

            VStack(alignment: .leading, spacing: CrateTheme.Spacing.textGapSmall) {
                Text(title)
                    .crateText(.h2)

                Text(subtitle)
                    .crateText(.caption, color: CrateColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(CrateTheme.Spacing.cardPadding + 4)
        .background(CrateColors.surface)
        .cornerRadius(CrateTheme.CornerRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: CrateTheme.CornerRadius.large)
                .stroke(CrateColors.border, lineWidth: 0.5)
        )
    }
}
