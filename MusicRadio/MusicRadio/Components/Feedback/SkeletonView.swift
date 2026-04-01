import SwiftUI

struct SkeletonView: View {
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    var cornerRadius: CGFloat = 6

    @State private var shimmerOffset: CGFloat = -1.0

    var body: some View {
        GeometryReader { geometry in
            let viewWidth = width ?? geometry.size.width
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(CrateColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .clear, location: 0.0),
                                    .init(color: CrateColors.elevated.opacity(0.6), location: 0.5),
                                    .init(color: .clear, location: 1.0)
                                ]),
                                startPoint: UnitPoint(x: shimmerOffset - 0.3, y: 0.5),
                                endPoint: UnitPoint(x: shimmerOffset + 0.3, y: 0.5)
                            )
                        )
                        .mask(
                            RoundedRectangle(cornerRadius: cornerRadius)
                        )
                )
                .frame(width: viewWidth)
        }
        .frame(width: width, height: height)
        .onAppear {
            withAnimation(
                .linear(duration: 1.5)
                .repeatForever(autoreverses: false)
            ) {
                shimmerOffset = 2.0
            }
        }
    }
}

// MARK: - Skeleton Shapes

struct SkeletonLine: View {
    var width: CGFloat? = nil
    var height: CGFloat = 12

    var body: some View {
        SkeletonView(width: width, height: height, cornerRadius: height / 2)
    }
}

struct SkeletonCircle: View {
    var size: CGFloat = 44

    var body: some View {
        SkeletonView(width: size, height: size, cornerRadius: size / 2)
    }
}

// MARK: - Skeleton Program Card

struct SkeletonProgramCard: View {
    var body: some View {
        HStack(spacing: 12) {
            SkeletonView(width: 52, height: 52, cornerRadius: 6)

            VStack(alignment: .leading, spacing: 8) {
                SkeletonLine(width: 140, height: 12)
                SkeletonLine(width: 90, height: 10)
            }

            Spacer()

            SkeletonCircle(size: 32)
        }
        .padding(12)
        .background(CrateColors.surface)
        .cornerRadius(10)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        SkeletonView(height: 40, cornerRadius: 8)

        HStack(spacing: 12) {
            SkeletonCircle(size: 44)
            VStack(alignment: .leading, spacing: 6) {
                SkeletonLine(width: 120)
                SkeletonLine(width: 80, height: 10)
            }
        }

        SkeletonProgramCard()
        SkeletonProgramCard()
        SkeletonProgramCard()
    }
    .padding()
    .background(CrateColors.void)
}
