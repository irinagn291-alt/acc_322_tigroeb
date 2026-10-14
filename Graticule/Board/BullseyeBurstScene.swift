import SpriteKit
import UIKit

/// The only SpriteKit surface. Cross-fades a burst when a BullseyeMark lands.
final class BullseyeBurstScene: SKScene {
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = .clear
        scaleMode = .resizeFill
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
        scaleMode = .resizeFill
    }

    func play() {
        removeAllChildren()
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        for index in 0..<8 {
            let node = SKShapeNode(circleOfRadius: 10)
            node.fillColor = DesignTokens.accentColor
            node.strokeColor = DesignTokens.inkColor
            node.lineWidth = 2
            node.position = center
            node.alpha = 0.95
            addChild(node)
            let angle = CGFloat(index) * (.pi / 4)
            node.alpha = 0
            let target = CGPoint(
                x: center.x + cos(angle) * 4,
                y: center.y + sin(angle) * 4
            )
            let appear = SKAction.fadeIn(withDuration: 0.09)
            appear.timingMode = .easeOut
            let settle = SKAction.fadeOut(withDuration: 0.09)
            settle.timingMode = .easeOut
            let drift = SKAction.move(to: target, duration: 0.18)
            drift.timingMode = .easeOut
            node.run(SKAction.group([
                SKAction.sequence([appear, settle]),
                drift
            ]))
        }
    }
}
