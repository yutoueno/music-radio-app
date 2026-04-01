import SwiftUI

struct ProgramCard: View {
    let program: Program
    let style: CardStyle

    enum CardStyle {
        case large
        case compact
        case list
    }

    var body: some View {
        switch style {
        case .large:
            largeCard
        case .compact:
            compactCard
        case .list:
            listCard
        }
    }

    // MARK: - Large Card (horizontal scroll)

    private var largeCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: program.thumbnailUrl ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .overlay {
                        Image(systemName: "radio")
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
            }
            .frame(width: 220, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(program.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .foregroundColor(.primary)

                Text(program.broadcaster?.nickname ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Label("\(program.playCount ?? 0)", systemImage: "play.fill")
                    Label(program.durationFormatted, systemImage: "clock")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
        }
        .frame(width: 220)
    }

    // MARK: - Compact Card (horizontal scroll)

    private var compactCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: URL(string: program.thumbnailUrl ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray5))
                    .overlay {
                        Image(systemName: "radio")
                            .foregroundColor(.secondary)
                    }
            }
            .frame(width: 160, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(program.title)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
                .foregroundColor(.primary)

            Text(program.broadcaster?.nickname ?? "")
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(width: 160)
    }

    // MARK: - List Card (vertical list)

    private var listCard: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: program.thumbnailUrl ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .overlay {
                        Image(systemName: "radio")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
            }
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(program.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .foregroundColor(.primary)

                HStack(spacing: 4) {
                    AsyncImage(url: URL(string: program.broadcaster?.avatarUrl ?? "")) { image in
                        image.avatarStyle(size: 16)
                    } placeholder: {
                        Circle()
                            .fill(Color(.systemGray4))
                            .frame(width: 16, height: 16)
                    }
                    Text(program.broadcaster?.nickname ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 10) {
                    Label("\(program.playCount ?? 0)", systemImage: "play.fill")
                    Label("\(program.favoriteCount ?? 0)", systemImage: "heart.fill")
                    Label(program.durationFormatted, systemImage: "clock")
                    if let programType = program.programType {
                        Image(systemName: programType.iconName)
                    }
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
