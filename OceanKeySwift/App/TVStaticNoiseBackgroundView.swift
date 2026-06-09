import CoreImage
import SwiftUI
import UIKit

struct TVStaticNoiseConfiguration: Equatable {
    var speed: Double
    var particleSize: Double
    var brightness: Double
    var greenTint: Double

    static let `default` = TVStaticNoiseConfiguration(
        speed: 1,
        particleSize: 1,
        brightness: -0.08,
        greenTint: 0
    )
}

struct TVStaticNoiseBackgroundView: UIViewRepresentable {
    var configuration: TVStaticNoiseConfiguration = .default

    func makeUIView(context: Context) -> TVStaticNoiseRenderView {
        let view = TVStaticNoiseRenderView()
        view.configure(configuration)
        view.start()
        return view
    }

    func updateUIView(_ view: TVStaticNoiseRenderView, context: Context) {
        view.configure(configuration)
        view.start()
    }

    static func dismantleUIView(_ view: TVStaticNoiseRenderView, coordinator: ()) {
        view.stop()
    }
}

final class TVStaticNoiseRenderView: UIView {
    private let imageView = UIImageView()
    private let scanlineView = TVStaticScanlineView()
    private let context = CIContext(options: [.cacheIntermediates: false])
    private let randomFilter = CIFilter(name: "CIRandomGenerator")
    private var displayLink: CADisplayLink?
    private var framePhase: Double = 0
    private var renderSize = CGSize(width: 180, height: 320)
    private var configuration: TVStaticNoiseConfiguration = .default

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        isUserInteractionEnabled = false

        imageView.contentMode = .scaleAspectFill
        imageView.layer.magnificationFilter = .nearest
        imageView.layer.minificationFilter = .nearest
        imageView.isOpaque = true
        imageView.backgroundColor = .black

        addSubview(imageView)
        addSubview(scanlineView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        scanlineView.frame = bounds
        updateRenderSize()
    }

    func configure(_ configuration: TVStaticNoiseConfiguration) {
        guard self.configuration != configuration else { return }
        self.configuration = configuration
        updateRenderSize()
        renderFrame()
    }

    func start() {
        guard displayLink == nil else { return }
        let link = CADisplayLink(target: self, selector: #selector(renderFrame))
        link.preferredFrameRateRange = CAFrameRateRange(
            minimum: 60,
            maximum: Float(UIScreen.main.maximumFramesPerSecond),
            preferred: Float(UIScreen.main.maximumFramesPerSecond)
        )
        link.add(to: .main, forMode: .common)
        displayLink = link
        renderFrame()
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func renderFrame() {
        framePhase += max(configuration.speed, 0.05)
        guard bounds.width > 0, bounds.height > 0 else { return }
        guard let image = makeNoiseImage() else { return }
        imageView.image = image
    }

    private func updateRenderSize() {
        guard bounds.width > 0, bounds.height > 0 else { return }
        let aspect = bounds.height / max(bounds.width, 1)
        let particleSize = CGFloat(max(configuration.particleSize, 0.5))
        let width = min(360, max(96, 180 / particleSize))
        renderSize = CGSize(width: width, height: max(240, width * aspect))
    }

    private func makeNoiseImage() -> UIImage? {
        guard let source = randomFilter?.outputImage else { return nil }

        let jitterX = CGFloat(Int(framePhase * 37) % 8192)
        let jitterY = CGFloat(Int(framePhase * 91) % 8192)
        let greenTint = min(max(configuration.greenTint, 0), 1)
        let redWeight = 1 - (0.82 * greenTint)
        let greenWeight = 1 + (0.12 * greenTint)
        let blueWeight = 1 - (0.74 * greenTint)
        let cropped = source
            .transformed(by: CGAffineTransform(translationX: jitterX, y: jitterY))
            .cropped(to: CGRect(origin: .zero, size: renderSize))
            .applyingFilter("CIColorControls", parameters: [
                kCIInputSaturationKey: 0,
                kCIInputContrastKey: 1.9,
                kCIInputBrightnessKey: configuration.brightness
            ])
            .applyingFilter("CIColorMatrix", parameters: [
                "inputRVector": CIVector(x: redWeight, y: 0, z: 0, w: 0),
                "inputGVector": CIVector(x: greenWeight, y: 0, z: 0, w: 0),
                "inputBVector": CIVector(x: blueWeight, y: 0, z: 0, w: 0),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1)
            ])

        guard let cgImage = context.createCGImage(cropped, from: CGRect(origin: .zero, size: renderSize)) else {
            return nil
        }
        return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
    }
}

private final class TVStaticScanlineView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        isUserInteractionEnabled = false
        backgroundColor = .clear
        contentMode = .redraw
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(UIColor.black.withAlphaComponent(0.18).cgColor)
        var y: CGFloat = 0
        while y < rect.height {
            context.fill(CGRect(x: 0, y: y, width: rect.width, height: 1))
            y += 4
        }
    }
}
