import SwiftUI

struct RecommendedSection: View {
    let programs: [Program]
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)

            if isLoading && programs.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
            } else if programs.isEmpty {
                emptyState
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(programs) { program in
                            NavigationLink(destination: ProgramView(programId: program.id)) {
                                ProgramCard(program: program, style: .large)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "radio")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("No recommendations yet")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }
}
