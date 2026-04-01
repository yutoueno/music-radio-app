import SwiftUI

struct BroadcasterCard: View {
    let broadcaster: Broadcaster

    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: URL(string: broadcaster.avatarUrl ?? "")) { image in
                image.avatarStyle(size: 64)
            } placeholder: {
                Circle()
                    .fill(Color(.systemGray4))
                    .frame(width: 64, height: 64)
                    .overlay {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.title3)
                    }
            }

            Text(broadcaster.nickname)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
                .foregroundColor(.primary)

            Text("\(broadcaster.programCount ?? 0) programs")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 90)
    }
}
