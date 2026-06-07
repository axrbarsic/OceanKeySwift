import SpriteKit
import SwiftUI

enum SpriteKitEffectKind {
    case matrixRain
}

@MainActor
struct SpriteKitEffectView: UIViewRepresentable {
    let effect: SpriteKitEffectKind

    init(_ effect: SpriteKitEffectKind) {
        self.effect = effect
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(effect: effect)
    }

    func makeUIView(context: Context) -> EffectSKView {
        let view = EffectSKView()
        view.backgroundColor = .clear
        view.allowsTransparency = true
        view.ignoresSiblingOrder = true
        view.shouldCullNonVisibleNodes = true
        view.preferredFramesPerSecond = UIScreen.main.maximumFramesPerSecond
        view.presentScene(context.coordinator.scene)
        return view
    }

    func updateUIView(_ view: EffectSKView, context: Context) {
        view.resizeScene()
    }

    final class Coordinator {
        let scene: SKScene

        init(effect: SpriteKitEffectKind) {
            switch effect {
            case .matrixRain:
                scene = MatrixRainSpriteScene(size: .zero)
            }
        }
    }
}

final class EffectSKView: SKView {
    override func layoutSubviews() {
        super.layoutSubviews()
        resizeScene()
    }

    func resizeScene() {
        guard bounds.size.width > 0, bounds.size.height > 0 else { return }
        guard scene?.size != bounds.size else { return }
        scene?.size = bounds.size
        (scene as? ResizableSpriteScene)?.resize(to: bounds.size)
    }
}

@MainActor
protocol ResizableSpriteScene: AnyObject {
    func resize(to size: CGSize)
}
