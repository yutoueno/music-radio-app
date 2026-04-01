import SwiftUI

struct FavoritesSection: View {
    let programs: [Program]
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Favorites")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                if !programs.isEmpty {
                    NavigationLink("See All") {
                        FavoriteProgramsView()
                    }
                    .font(.subheadline)
                }
            }
            .padding(.horizontal)

            if isLoading && programs.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
            } else if programs.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "heart")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary)
                    Text("No favorites yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Tap the heart on programs you love")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 160)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(programs) { program in
                            NavigationLink(destination: ProgramView(programId: program.id)) {
                                ProgramCard(program: program, style: .compact)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
