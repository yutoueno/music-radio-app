import SwiftUI

struct BroadcasterProgramList: View {
    let programs: [Program]
    let isLoadingMore: Bool
    let hasMore: Bool
    let onLoadMore: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Programs")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal)

            if programs.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "radio")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary)
                    Text("No programs yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 150)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(programs) { program in
                        NavigationLink(destination: ProgramView(programId: program.id)) {
                            ProgramCard(program: program, style: .list)
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            if program.id == programs.last?.id && hasMore {
                                onLoadMore()
                            }
                        }
                    }

                    if isLoadingMore {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
