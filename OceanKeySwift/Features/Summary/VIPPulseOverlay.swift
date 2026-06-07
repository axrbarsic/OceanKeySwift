import SwiftUI

struct VIPPulseOverlay: View {
    @State private var phase = false

    var body: some View {
        TimelineView(.animation) { context in
            Canvas { canvas, size in
                let time = context.date.timeIntervalSinceReferenceDate
                let width = size.width * 0.24
                for index in 0..<4 {
                    let progress = (time * 0.42 + Double(index) * 0.22).truncatingRemainder(dividingBy: 1)
                    var rect = CGRect(x: size.width * progress - width, y: -size.height, width: width, height: size.height * 3)
                    let alpha = 0.18 + 0.12 * sin(time * 1.7 + Double(index))
                    let color = Color.white.opacity(alpha)
                    canvas.rotate(by: .degrees(28))
                    canvas.fill(Path(rect), with: .color(color))
                    canvas.rotate(by: .degrees(-28))
                    rect.origin.x += size.width * 0.5
                }
            }
        }
        .blendMode(.screen)
        .allowsHitTesting(false)
    }
}

#Preview {
    VIPPulseOverlay()
        .frame(width: 360, height: 76)
        .background(OceanKeyTheme.ready)
}
