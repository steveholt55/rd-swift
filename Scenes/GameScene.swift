//
//  GameScene.swift
//  tvOS
//
//  Created by Brandon Jenniges on 9/26/15.
//  Copyright (c) 2015 Brandon Jenniges. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    static let fireballCategory:UInt32 = 0x1 << 0
    static let playerCategory:UInt32 = 0x1 << 1
    static let floorCategory:UInt32 = 0x1 << 2
    
    var scenePaused = false
    
    enum GameState {
        case MainMenu
        case Intro
        case Play
        case ShowingScore
        case GameOver
    }
    
    enum Layer: CGFloat {
        case Background = 0
        case Foreground = 1
        case Game = 2
        case Hud = 3
        case GameOver = 4
    }
    
    var viewController:GameViewController!
    
    var player:Player!
    var ground:SKSpriteNode!
    var scoreLabel:SKLabelNode!
    
    var gameState:GameState?
    var gapPositions = [CGFloat]()
    
    var lastUpdateTime:NSTimeInterval?
    var dt:NSTimeInterval?
    var lastUpdateTimeInterval:NSTimeInterval = 0
    var lastSpawnTimeInterval:NSTimeInterval = 0
    var score = 0
    
    var worldNode: SKSpriteNode!
    var pauseNode: SKSpriteNode!
    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.view!.showsPhysics = true
        
        worldNode = childNodeWithName("background") as! SKSpriteNode
        
        #if os(tvOS)
            viewController.controllerUserInteractionEnabled = false
        #endif
        
        ground = worldNode.childNodeWithName("ground") as! SKSpriteNode
       // self.addChild(myLabel)
        scoreLabel = worldNode.childNodeWithName("scoreLabel") as! SKLabelNode
        setupGaps()
        switchToIntro()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        if scenePaused {
            unPauseScene()
        }
        
        let state:GameState = gameState!
        switch state {
        case .MainMenu:
            switchToIntro()
            break
        case .Intro:
            switchToPlay()
            break
        case .Play:
            
            break
        case .ShowingScore:
            break
        case .GameOver:
            startNewGame()
            break
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        
        let state:GameState = gameState!
        if state == .Play {
            player.movePlayer(touches)
        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        if gameState == .Play {
            player.stopRunning()
            player.movement = .Neutral
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if let lastUpdateTime = lastUpdateTime {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        
        lastUpdateTime = currentTime
        
        var timeSinceLast = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime
        
        if timeSinceLast > 1 {
            timeSinceLast = 1.0 / 60.0
            lastUpdateTimeInterval = currentTime
        }
        
        updateWithTimeSinceLastUpdate(timeSinceLast)
        
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLast:CFTimeInterval) {
        lastSpawnTimeInterval = timeSinceLast + lastSpawnTimeInterval
        if lastSpawnTimeInterval > 1 {
            lastSpawnTimeInterval = 0
            if gameState == .Play {
                addFireball()
            }
        }
    }
    
    //MARK: States
    func switchToMainMenu() {
    }
    
    func switchToIntro() {
        self.gameState = .Intro
        setupPlayer()
        setupDragons()
    }
    
    func switchToPlay() {
        self.gameState = .Play
        let intro = worldNode.childNodeWithName("intro")
        let removeIntroAction = SKAction.fadeAlphaTo(0, duration: 2.0)
        intro?.runAction(removeIntroAction, completion: { () -> Void in
            
            
           // let moveRightAction = SKAction.moveToX(700, duration: 2.0)
           // self.player.runAction(moveRightAction)
        })
        
        
    }
    
    func switchToShowingScore() {
        
    }
    
    func switchToGameOver() {
        self.gameState = .GameOver
        let scorecard = worldNode.childNodeWithName("scorecard") as! ScoreBoard
        scorecard.setupWithGameScore(score)
        let moveAction = SKAction.moveToY((self.view?.frame.height)! / 2, duration: 0.4)
        scorecard.runAction(moveAction)
        self.player.die()
    }
    
    func startNewGame() {
        if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
            /* Set the scale mode to scale to fit the window */
            scene.viewController = viewController
            self.view!.presentScene(scene, transition: SKTransition.crossFadeWithDuration(1.0))
        }
    }
    
    //MARK: Elements
    func setupPlayer() {
        player = worldNode.childNodeWithName("player") as! Player
        player.runPlayerLookingAnimation()
        player.movement = .Neutral
        player.setPlayerRightMovementMax((self.ground.position.x + self.ground.frame.width / 2) - player.frame.width / 2, min: (self.ground.position.x - self.ground.frame.size.width / 2) + player.frame.width / 2)
        player.previousPlayerTouch = (self.view?.frame.width)! / 2
        player.setupPhysics()
    }
    
    func setupDragons() {
        let dragon0 = worldNode.childNodeWithName("dragon0") as! Dragon
        let dragon1 = worldNode.childNodeWithName("dragon1") as! Dragon
        let dragon2 = worldNode.childNodeWithName("dragon2") as! Dragon
        let dragon3 = worldNode.childNodeWithName("dragon3") as! Dragon
        Dragon.dragonArray = [dragon0, dragon1, dragon2, dragon3]
        
        var index = 0
        for dragon in Dragon.dragonArray {
            dragon.setUpDragonAnimations(index)
            index++
        }
    }
    
    func setupGaps() {
        var tempArray = [CGFloat]()
        
        let groundStart = ground.position.x - ground.frame.size.width / 2
        for index in 0...12 {
            tempArray.append(groundStart + CGFloat((index * Int(ground.frame.size.width / 12))))
        }
        gapPositions = tempArray
    }
    
    func addFireball() {
        let fire = Fireball(texture: Fireball.fireTextureAtlas.textureNamed("fireball1"))
        fire.setupFireball()
        fire.zPosition = CGFloat(Layer.Game.rawValue)
        
        let x = gapPositions[Int(arc4random_uniform(12))] + fire.size.width / 2
        fire.position = CGPointMake(x, frame.size.height + frame.size.height / 2.0)
        fire.setupPhysicsBody()
        fire.zPosition = Layer.Game.rawValue
        worldNode.addChild(fire)
        fire.send(-worldNode.frame.size.height / 2) //Needs this because of worldNode's anchor point
    }
    
    func increaseScore() {
        score++
        scoreLabel.text = "\(score)"
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        switchToGameOver()
    }
    
    func pauseScene() {
        scenePaused = true
        worldNode.paused = true
        if let overlayScene = SKScene(fileNamed: "PauseScene") {
            let contentTemplateNode = overlayScene.childNodeWithName("Overlay") as! SKSpriteNode
            
            // Create a background node with the same color as the template.
            pauseNode = SKSpriteNode(color: contentTemplateNode.color, size: contentTemplateNode.size)
            pauseNode.zPosition = 10
            pauseNode.position = CGPointMake(pauseNode.frame.size.width / 2, pauseNode.frame.size.height / 2)
            
            // Copy the template node into the background node.
            let contentNode = contentTemplateNode.copy() as! SKSpriteNode
            pauseNode.addChild(contentNode)
            
            // Set the content node to a clear color to allow the background node to be seen through it.
            contentNode.color = .clearColor()
            contentNode.position = .zero
            
            scene?.addChild(pauseNode)
        }
    }

    func unPauseScene() {
        scenePaused = false
        worldNode.paused = false
        if let pauseNode = pauseNode {
            pauseNode.removeFromParent()
        }
    }
    
}
