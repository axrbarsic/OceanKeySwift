import SwiftUI

struct CellTVStaticOverlay: View {
    let statusColor: Color
    let roomID: String

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
            let frame = UInt64(timeline.date.timeIntervalSinceReferenceDate * 60)
            let seed = CellTVStaticNoise.seed(roomID: roomID, frame: frame)
            Canvas(opaque: false, rendersAsynchronously: true) { context, size in
                CellTVStaticNoise.draw(
                    in: &context,
                    size: size,
                    statusColor: statusColor,
                    seed: seed
                )
            }
            .opacity(0.96)
            .overlay {
                scanlines
                    .opacity(0.55)
            }
        }
    }

    private var scanlines: some View {
        LinearGradient(
            stops: [
                .init(color: .black.opacity(0.52), location: 0.00),
                .init(color: .clear, location: 0.22),
                .init(color: .white.opacity(0.18), location: 0.50),
                .init(color: .clear, location: 0.78),
                .init(color: .black.opacity(0.46), location: 1.00)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

private enum CellTVStaticNoise {
    static func seed(roomID: String, frame: UInt64) -> UInt64 {
        var hash: UInt64 = 1469598103934665603
        for byte in roomID.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1099511628211
        }
        return hash ^ (frame &* 0x9E3779B97F4A7C15)
    }

    static func draw(in context: inout GraphicsContext, size: CGSize, statusColor: Color, seed: UInt64) {
        guard size.width > 0, size.height > 0 else { return }

        var generator = SeededNoise(seed: seed)
        let pixel = max(2.0, min(3.0, size.height / 30.0))
        let columns = max(1, Int(size.width / pixel))
        let rows = max(1, Int(size.height / pixel))

        for row in 0..<rows {
            let rowY = CGFloat(row) * pixel
            let rowFlicker = 0.70 + generator.nextUnit() * 0.55
            for column in 0..<columns {
                let noise = generator.nextUnit()
                let color = color(for: noise, statusColor: statusColor, rowFlicker: rowFlicker)
                let rect = CGRect(
                    x: CGFloat(column) * pixel,
                    y: rowY,
                    width: pixel * (noise > 0.965 ? 2.2 : 1.03),
                    height: pixel * (noise < 0.05 || noise > 0.95 ? 1.35 : 1.03)
                )
                context.fill(Path(rect), with: .color(color))
            }
        }

        for _ in 0..<12 {
            let y = generator.nextUnit() * size.height
            let height = 1.0 + generator.nextUnit() * 3.0
            let alpha = 0.16 + generator.nextUnit() * 0.28
            let rect = CGRect(x: 0, y: y, width: size.width, height: height)
            let lineColor = generator.nextUnit() > 0.45 ? Color.black.opacity(alpha) : Color.white.opacity(alpha)
            context.fill(Path(rect), with: .color(lineColor))
        }

        for _ in 0..<3 where generator.nextUnit() > 0.35 {
            let x = generator.nextUnit() * size.width
            let width = 8 + generator.nextUnit() * 34
            let alpha = 0.16 + generator.nextUnit() * 0.20
            let rect = CGRect(x: x, y: 0, width: width, height: size.height)
            context.fill(Path(rect), with: .color(statusColor.opacity(alpha)))
        }
    }

    private static func color(for noise: CGFloat, statusColor: Color, rowFlicker: CGFloat) -> Color {
        if noise < 0.18 {
            return .black.opacity((0.28 + (0.18 - noise) * 2.1) * rowFlicker)
        }
        if noise > 0.82 {
            return .white.opacity((0.16 + (noise - 0.82) * 2.4) * rowFlicker)
        }
        if noise > 0.58 {
            return statusColor.opacity((0.18 + (noise - 0.58) * 0.9) * rowFlicker)
        }
        return .black.opacity(0.05 + noise * 0.12)
    }
}

private struct SeededNoise {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed == 0 ? 0xD1B54A32D192ED03 : seed
    }

    mutating func nextUnit() -> CGFloat {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        z ^= z >> 31
        return CGFloat(Double(z & 0xFFFF) / Double(0xFFFF))
    }
}
