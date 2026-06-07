import SwiftUI

struct MatrixRainBackground: View {
    var body: some View {
        TimelineView(.animation) { context in
            Canvas { canvas, size in
                canvas.fill(Path(CGRect(origin: .zero, size: size)), with: .color(OceanKeyTheme.background))
                let time = context.date.timeIntervalSinceReferenceDate
                let columns = max(18, Int(size.width / 22))
                let rows = max(20, Int(size.height / 28))
                for column in 0..<columns {
                    let x = Double(column) * Double(size.width) / Double(columns)
                    let speed = 0.18 + Double((column * 37) % 11) * 0.018
                    let head = (time * speed + Double((column * 19) % 17) / 17).truncatingRemainder(dividingBy: 1)
                    for row in 0..<rows {
                        let trail = Double(row) / Double(rows)
                        let y = (head - trail).positiveRemainder * Double(size.height + 120) - 60
                        let alpha = max(0.035, 0.55 - trail * 0.62)
                        let glyph = MatrixGlyphs.value(column: column, row: row, time: time)
                        var text = Text(glyph)
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundStyle(OceanKeyTheme.accent.opacity(alpha))
                        if row == 0 {
                            text = text.foregroundStyle(Color.white.opacity(0.78))
                        }
                        canvas.draw(text, at: CGPoint(x: x, y: y))
                    }
                }
            }
        }
        .overlay(Color.black.opacity(0.35))
    }
}

private enum MatrixGlyphs {
    static let glyphs = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789木火水金月日")

    static func value(column: Int, row: Int, time: TimeInterval) -> String {
        let tick = Int(time * 3)
        let index = abs(column * 31 + row * 17 + tick) % glyphs.count
        return String(glyphs[index])
    }
}

private extension Double {
    var positiveRemainder: Double {
        let value = truncatingRemainder(dividingBy: 1)
        return value < 0 ? value + 1 : value
    }
}

#Preview {
    MatrixRainBackground()
}
