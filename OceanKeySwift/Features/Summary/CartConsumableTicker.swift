import SwiftUI

enum CartConsumableTickerFormatter {
    static func text(
        for cart: CartSection,
        catalogEntries: [CartConsumableCatalogEntry]? = nil
    ) -> String? {
        let items = CartConsumableCatalog.merged(
            with: cart.consumables,
            catalogEntries: catalogEntries
        )
            .filter { $0.quantity > 0 && !$0.isCompleted }

        guard !items.isEmpty else { return nil }
        return items
            .map { "\($0.title) \($0.quantity)" }
            .joined(separator: "  •  ")
    }
}

struct CartConsumableTicker: View {
    let text: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var measuredTextWidth: CGFloat = 0
    @State private var availableWidth: CGFloat = 0
    @State private var isAnimating = false
    @State private var animationID = UUID()

    private let horizontalInset: CGFloat = 8
    private let repeatSpacing: CGFloat = 28

    var body: some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let contentWidth = max(measuredTextWidth, 1)
            let scrollDistance = contentWidth + repeatSpacing

            ZStack(alignment: .leading) {
                if shouldScroll {
                    HStack(spacing: repeatSpacing) {
                        tickerText
                        tickerText
                    }
                    .offset(x: isAnimating ? -scrollDistance : width)
                    .animation(
                        .linear(duration: scrollDuration(width: width, contentWidth: contentWidth))
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                    .id(animationID)
                } else {
                    tickerText
                        .offset(x: horizontalInset)
                }
            }
            .frame(width: width, height: 32, alignment: .leading)
            .onAppear { updateAvailableWidth(width) }
            .onChange(of: width) { _, newValue in updateAvailableWidth(newValue) }
            .onChange(of: text) { _, _ in restartAnimation() }
            .onChange(of: reduceMotion) { _, _ in restartAnimation() }
            .onPreferenceChange(CartTickerTextWidthKey.self) { width in
                measuredTextWidth = width
                restartAnimation()
            }
        }
        .frame(height: 32)
        .clipShape(Capsule())
        .background(.black.opacity(0.24), in: Capsule())
        .overlay {
            Capsule()
                .stroke(OceanKeyTheme.pending.opacity(0.34), lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Нужны расходники: \(text)")
    }

    private var tickerText: some View {
        HStack(spacing: 6) {
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 12, weight: .black))
            Text(text)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .lineLimit(1)
        }
        .fixedSize(horizontal: true, vertical: false)
        .foregroundStyle(OceanKeyTheme.pending)
        .shadow(color: .black.opacity(0.8), radius: 1.2, x: 0, y: 1)
        .background {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: CartTickerTextWidthKey.self,
                    value: proxy.size.width
                )
            }
        }
    }

    private var shouldScroll: Bool {
        !reduceMotion && measuredTextWidth > max(availableWidth - horizontalInset * 2, 1)
    }

    private func scrollDuration(width: CGFloat, contentWidth: CGFloat) -> Double {
        max(Double(width + contentWidth + repeatSpacing) / 36.0, 5.0)
    }

    private func updateAvailableWidth(_ width: CGFloat) {
        availableWidth = max(width, 1)
        restartAnimation()
    }

    private func restartAnimation() {
        animationID = UUID()
        isAnimating = false
        guard shouldScroll else { return }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 80_000_000)
            isAnimating = true
        }
    }
}

private struct CartTickerTextWidthKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
