//
//  Copyright © 2016 Brandon Jenniges. All rights reserved.
//

import SpriteKit

enum ControlPadTouchDirection {
    case Left
    case Right
}

protocol ControlPadTouches {
    func controlPadDidBeginTouch(direction: ControlPadTouchDirection)
    func controlPadDidEndTouch()
}

class ControlPad: SKSpriteNode {
    
    let left:SKSpriteNode
    let right:SKSpriteNode
    
    var delegate:ControlPadTouches?
    
    init(texture: SKTexture?, size: CGSize) {
        let testImage = ControlPadPaintCodeImage(frame: CGRectMake(0, 0, size.width / 2, size.height))
        let testTexture = SKTexture(image: testImage.getTestImage())
        
        left = SKSpriteNode(texture: testTexture)
        left.anchorPoint = CGPointMake(0, 0)
        left.position = CGPointMake(0, 0)
        
        right = SKSpriteNode(texture: testTexture)
        right.anchorPoint = CGPointMake(0, 0)
        right.position = CGPointMake(size.width / 2, 0)
        
        super.init(texture: texture, color: .clearColor(), size: size)
        
        self.addChild(left)
        self.addChild(right)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            var currentDirection: ControlPadTouchDirection?
            
            if left.containsPoint(location) {
                left.alpha = 0.5
                currentDirection = .Left
            } else if right.containsPoint(location) {
                right.alpha = 0.5
                currentDirection = .Right
            }
            
            if let delegate = delegate, let direction = currentDirection {
                delegate.controlPadDidBeginTouch(direction)
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        right.alpha = 1
        left.alpha = 1
        
        if let delegate = delegate {
            delegate.controlPadDidEndTouch()
        }
    }
    
}
