//
//  ACQuickButton.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/27/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation
import SpriteKit

class ACQuickButton : SKNode
{
    let bg:SKSpriteNode
    let clickable:SKSpriteNode
    
    init(size:CGSize, color:NSColor)
    {
        bg = SKSpriteNode(imageNamed:"square.png")
        bg.resizeNode(size.width, y:size.height)
        bg.position = CGPointMake(0, 0)
        bg.color = color
        bg.colorBlendFactor = 1.0
        bg.zPosition = 0
        
        clickable = SKSpriteNode(imageNamed:"blank.png")
        clickable.resizeNode(size.width, y:size.height)
        clickable.position = CGPointMake(0, 0)
        clickable.zPosition = 1
        
        super.init()
        
        self.addChild(bg)
        self.addChild(clickable)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}