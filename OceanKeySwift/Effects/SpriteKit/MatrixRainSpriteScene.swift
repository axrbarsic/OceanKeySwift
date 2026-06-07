import GameplayKit
import SpriteKit
import UIKit

final class MatrixRainSpriteScene: SKScene, ResizableSpriteScene {
    private var drops: [MatrixRainDrop] = []
    private var random = GKLinearCongruentialRandomSource(seed: UInt64(Date().timeIntervalSinceReferenceDate))
    private var configuration: MatrixRainConfiguration
    private var lastUpdateTime: TimeInterval?
    private var vignetteNode: SKSpriteNode?

    init(size: CGSize, configuration: MatrixRainConfiguration = .default) {
        self.configuration = configuration
        super.init(size: size)
        configureScene()
    }

    override init(size: CGSize) {
        self.configuration = .default
        super.init(size: size)
        configureScene()
    }

    required init?(coder: NSCoder) {
        self.configuration = .default
        super.init(coder: coder)
        configureScene()
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        resize(to: size)
        isPaused = false
    }

    func resize(to size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        removeAllChildren()
        drops.removeAll(keepingCapacity: true)
        backgroundColor = MatrixRainMetrics.background

        let backgroundNode = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        backgroundNode.fillColor = MatrixRainMetrics.background
        backgroundNode.strokeColor = .clear
        backgroundNode.zPosition = -20
        addChild(backgroundNode)

        for _ in 0..<MatrixRainMetrics.highDropCount {
            spawnDrop(startY: CGFloat.random(in: -2...0, using: &random))
        }

        let vignette = SKSpriteNode(texture: Self.makeVignetteTexture(size: size))
        vignette.position = CGPoint(x: size.width / 2, y: size.height / 2)
        vignette.size = size
        vignette.zPosition = 20
        vignette.blendMode = .alpha
        addChild(vignette)
        vignetteNode = vignette
    }

    func apply(configuration: MatrixRainConfiguration) {
        guard self.configuration != configuration else { return }
        self.configuration = configuration
        for drop in drops {
            drop.updateColors()
        }
    }

    override func update(_ currentTime: TimeInterval) {
        guard size.width > 0, size.height > 0 else { return }

        let delta: CGFloat
        if let lastUpdateTime {
            delta = CGFloat(max(0, currentTime - lastUpdateTime))
        } else {
            delta = 1 / 60
        }
        lastUpdateTime = currentTime

        let step = min(delta, 1 / 30)
        let speedScale = configuration.normalizedSpeed
        syncDropCount()

        for index in drops.indices.reversed() {
            let drop = drops[index]
            drop.y += drop.velocity * 0.5 * step * speedScale
            if drop.y > 1.3 {
                drop.removeFromParent()
                drops.remove(at: index)
                spawnDrop(startY: -0.3)
            } else {
                if random.nextUniform() < 0.03 {
                    drop.replaceRandomGlyph(randomGlyph())
                }
                drop.layout(in: size)
            }
        }
    }

    private func configureScene() {
        scaleMode = .resizeFill
        backgroundColor = MatrixRainMetrics.background
        anchorPoint = .zero
    }

    private func spawnDrop(startY: CGFloat) {
        let drop = MatrixRainDrop(
            x: CGFloat(random.nextUniform()),
            y: startY,
            velocity: 0.3 + CGFloat(random.nextUniform()) * 1.2,
            opacity: 0.28 + CGFloat(random.nextUniform()) * 0.58,
            glyphs: (0..<(8 + random.nextInt(upperBound: 25))).map { _ in randomGlyph() }
        )
        drops.append(drop)
        addChild(drop)
        drop.layout(in: size)
    }

    private func syncDropCount() {
        while drops.count > MatrixRainMetrics.highDropCount {
            drops.removeLast().removeFromParent()
        }
        while drops.count < MatrixRainMetrics.highDropCount {
            spawnDrop(startY: CGFloat.random(in: -1...0, using: &random))
        }
    }

    private func randomGlyph() -> String {
        String(MatrixRainMetrics.glyphs[random.nextInt(upperBound: MatrixRainMetrics.glyphs.count)])
    }

    private static func makeVignetteTexture(size: CGSize) -> SKTexture {
        let scale = UIScreen.main.scale
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let image = renderer.image { context in
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [
                UIColor.clear.cgColor,
                MatrixRainMetrics.background.withAlphaComponent(0.74).cgColor
            ] as CFArray
            let locations: [CGFloat] = [0, 1]
            guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) else {
                return
            }
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            context.cgContext.drawRadialGradient(
                gradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: size.width * 0.82,
                options: [.drawsAfterEndLocation]
            )
        }
        return SKTexture(image: image)
    }
}

private final class MatrixRainDrop: SKNode {
    var y: CGFloat
    let x: CGFloat
    let velocity: CGFloat
    let opacity: CGFloat
    private var glyphs: [String]
    private var glyphNodes: [SKLabelNode] = []
    private var glowNodesByHead: [SKLabelNode] = []

    init(
        x: CGFloat,
        y: CGFloat,
        velocity: CGFloat,
        opacity: CGFloat,
        glyphs: [String]
    ) {
        self.x = x
        self.y = y
        self.velocity = velocity
        self.opacity = opacity
        self.glyphs = glyphs
        super.init()
        buildNodes()
    }

    required init?(coder: NSCoder) {
        nil
    }

    func layout(in size: CGSize) {
        let px = x * size.width
        let py = y * size.height
        for index in glyphNodes.indices {
            let charY = py - CGFloat(index) * MatrixRainMetrics.charHeight
            glyphNodes[index].isHidden = charY < -MatrixRainMetrics.charHeight ||
                charY > size.height + MatrixRainMetrics.charHeight
            glyphNodes[index].position = CGPoint(x: px, y: charY + MatrixRainMetrics.cellSize / 2)
        }
        let headY = py + MatrixRainMetrics.cellSize / 2
        let glowOffsets = [CGPoint(x: 1, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: 0, y: 1), CGPoint(x: 0, y: -1)]
        for (index, node) in glowNodesByHead.enumerated() {
            node.text = glyphs.first
            node.isHidden = glyphNodes.first?.isHidden ?? true
            node.position = CGPoint(x: px + glowOffsets[index].x, y: headY + glowOffsets[index].y)
        }
        updateColors()
    }

    func updateColors() {
        for (index, node) in glyphNodes.enumerated() {
            let alpha: CGFloat = index == 0
                ? opacity
                : opacity * (1.0 - CGFloat(index) / CGFloat(max(glyphNodes.count, 1))) * 0.7
            let brightness: CGFloat = index < 3 ? 0.9 : 0.4
            node.fontColor = UIColor(
                red: (130 / 255) * brightness,
                green: brightness,
                blue: (100 / 255) * brightness,
                alpha: alpha.clamped(to: 0...1)
            )
        }
        for node in glowNodesByHead {
            node.fontColor = UIColor(red: 128 / 255, green: 1, blue: 128 / 255, alpha: opacity * 0.6)
        }
    }

    func replaceRandomGlyph(_ glyph: String) {
        guard !glyphs.isEmpty else { return }
        let index = Int.random(in: 0..<glyphs.count)
        glyphs[index] = glyph
        glyphNodes[index].text = glyph
        if index == 0 {
            for node in glowNodesByHead {
                node.text = glyph
            }
        }
    }

    private func buildNodes() {
        for glyph in glyphs {
            let node = makeGlyphNode(text: glyph)
            node.zPosition = 0
            glyphNodes.append(node)
            addChild(node)
        }
        for _ in 0..<4 {
            let node = makeGlyphNode(text: glyphs.first ?? "")
            node.zPosition = -1
            glowNodesByHead.append(node)
            addChild(node)
        }
        updateColors()
    }

    private func makeGlyphNode(text: String) -> SKLabelNode {
        let node = SKLabelNode(fontNamed: MatrixRainMetrics.fontName)
        node.text = text
        node.fontSize = MatrixRainMetrics.fontSize
        node.fontColor = .white
        node.verticalAlignmentMode = .center
        node.horizontalAlignmentMode = .center
        node.blendMode = .add
        return node
    }
}

private enum MatrixRainMetrics {
    static let glyphs = Array(
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" +
        "ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃ" +
        "日田大木本山川空海風火水金土月星"
    )
    static let fontName = "Courier-Bold"
    static let fontSize: CGFloat = 18
    static let cellSize: CGFloat = 24
    static let charHeight = fontSize * 1.2
    static let background = UIColor(red: 2 / 255, green: 8 / 255, blue: 4 / 255, alpha: 1)
    static let highDropCount = 80
}

private extension CGFloat {
    static func random(in range: ClosedRange<CGFloat>, using source: inout GKLinearCongruentialRandomSource) -> CGFloat {
        let value = CGFloat(source.nextUniform())
        return range.lowerBound + (range.upperBound - range.lowerBound) * value
    }

    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
