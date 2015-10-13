//
//  MenuScene.swift
//  Launchy Demo
//
//  Created by Brandon Jenniges on 9/26/15.
//  Copyright © 2015 Brandon Jenniges. All rights reserved.
//

import SpriteKit
import GameKit

class MenuScene: SKScene {
    
    var viewController:GameViewController!
    
    var dragonArray:[Dragon]!
    
    var player:Player!
    
    let logoNodeName = "logo"
    
    override func didMoveToView(view: SKView) {
        #if os(tvOS)
            viewController.controllerUserInteractionEnabled = true
        #endif
        addBackground()
        addLogo()
        addPlayButton()
        setupDragons()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let scene = GameScene(size: self.view!.frame.size)
        scene.scaleMode = .AspectFill
        scene.viewController = viewController
        self.view!.presentScene(scene, transition: SKTransition.crossFadeWithDuration(1.0))
    }
    
    //MARK: Elements
    func addBackground() {
        let background = SKSpriteNode(texture:TextureAtlasManager.introAtlas.textureNamed("background"))
        background.position = CGPointMake(view!.frame.width / 2, view!.frame.height / 2)
        addChild(background)
    }
    
    func addLogo() {
        let logo = SKSpriteNode(texture:TextureAtlasManager.introAtlas.textureNamed("logo"))
        logo.name = logoNodeName
        logo.position = CGPointMake(view!.frame.width / 2, view!.frame.height / 2)
        logo.zPosition = 2
        addChild(logo)
        
        let growAction = SKAction.scaleTo(1.05, duration: 1)
        growAction.timingMode = .EaseInEaseOut
        let shrinkAction = SKAction.scaleTo(0.95, duration: 1)
        shrinkAction.timingMode = .EaseInEaseOut
        let sequence = SKAction.sequence([growAction, shrinkAction])
        let repeatAction = SKAction.repeatActionForever(sequence)
        
        logo.runAction(repeatAction)
    }
    
    /*
    func addPlatform() {
        let platform = SKSpriteNode(texture: TextureAtlasManager.playerAtlas.textureNamed("ground"))
        platform.position = CGPointMake(view!.frame.width / 2, view!.frame.height / 4)
        print(platform.texture?.size())
        platform.zPosition = 1
        addChild(platform)

    }
*/
    
    func addPlayButton() {
        let playButton = SKSpriteNode(texture: TextureAtlasManager.introAtlas.textureNamed("play"))
        let logoNode = childNodeWithName(logoNodeName)
        playButton.position = CGPointMake(logoNode!.position.x, logoNode!.position.y / 2)
        playButton.zPosition = 2
        addChild(playButton)
    }
    
    func setupPlayer() {
        let player = Player()
        //TODO: Position player
    }
    
    func setupDragons() {
        
        dragonArray = Dragon.getDragonArray()
        
        var index = 0
        let gapSize = view!.frame.width / CGFloat(dragonArray.count)
        
        let leftXPos = gapSize * CGFloat(0) + gapSize / 2
        let rightXPos = gapSize * CGFloat(3) + gapSize / 2
        let topYPos = view!.frame.size.height * 0.75
        let bottomYPos = view!.frame.size.height * 0.25
        
        let yPositions = [topYPos, topYPos, bottomYPos, bottomYPos]
        let xPositions = [leftXPos, rightXPos, leftXPos, rightXPos]
        for dragon in dragonArray {
            print(dragon.texture!.size())
            dragon.setUpDragonAnimations()
           // print(xPos)
            dragon.position = CGPointMake(xPositions[index], yPositions[index])
            addChild(dragon)
            index++
        }
    }
}
