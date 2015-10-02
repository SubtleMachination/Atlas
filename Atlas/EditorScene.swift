//
//  GameScene.swift
//  Atlas
//
//  Created by Dusty Artifact on 9/30/15.
//  Copyright (c) 2015 Runemark Studios. All rights reserved.
//

import SpriteKit

class EditorScene: SKScene
{
    var window:CGSize
    var center:CGPoint
    
    override init(size:CGSize)
    {
        window = size
        center = CGPoint(x:window.width/2.0, y:window.height/2.0)
        
        super.init(size:size)
        
        let tileSprite = SKSpriteNode(imageNamed:"tile.png")
        tileSprite.position = center
        
        self.addChild(tileSprite)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView)
    {
        
    }
    
    override func mouseDown(theEvent: NSEvent)
    {
//        let location = theEvent.locationInNode(self)
    }
    
    override func update(currentTime: CFTimeInterval)
    {
        
    }
}
