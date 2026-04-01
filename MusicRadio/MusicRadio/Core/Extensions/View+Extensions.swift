import SwiftUI

extension View {
    func cardStyle() -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }

    func onFirstAppear(perform action: @escaping () async -> Void) -> some View {
        modifier(FirstAppearModifier(action: action))
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    func errorAlert(error: Binding<String?>) -> some View {
        alert("Error", isPresented: Binding<Bool>(
            get: { error.wrappedValue != nil },
            set: { if !$0 { error.wrappedValue = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            if let message = error.wrappedValue {
                Text(message)
            }
        }
    }

    func paginationLoader(
        isLoading: Bool,
        hasMore: Bool,
        action: @escaping () async -> Void
    ) -> some View {
        modifier(PaginationLoaderModifier(isLoading: isLoading, hasMore: hasMore, action: action))
    }
}

// MARK: - First Appear Modifier

private struct FirstAppearModifier: ViewModifier {
    @State private var hasAppeared = false
    let action: () async -> Void

    func body(content: Content) -> some View {
        content
            .task {
                guard !hasAppeared else { return }
                hasAppeared = true
                await action()
            }
    }
}

// MARK: - Pagination Loader Modifier

private struct PaginationLoaderModifier: ViewModifier {
    let isLoading: Bool
    let hasMore: Bool
    let action: () async -> Void

    func body(content: Content) -> some View {
        content.overlay(alignment: .bottom) {
            if isLoading && hasMore {
                ProgressView()
                    .padding()
            }
        }
    }
}

// MARK: - Image Helpers

extension Image {
    func avatarStyle(size: CGFloat) -> some View {
        self
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
    }

    func thumbnailStyle(width: CGFloat, height: CGFloat) -> some View {
        self
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
