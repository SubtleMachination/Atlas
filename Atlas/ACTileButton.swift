//
//  ACQuickButton.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/27/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation
import SpriteKit

class ACTileButton : SKNode
{
    let clickable:SKSpriteNode
    let index:Int
    
    init(size:CGSize, imageName:String, index:Int)
    {
        let image = SKSpriteNode(imageNamed:imageName)
        image.resizeNode(size.width, y:size.height)
        image.position = CGPointMake(0, 0)
        
        if (index < 1)
        {
            if (index == -1)
            {
                image.color = NSColor.purpleColor()
                
            }
            else if (index == 0)
            {
                image.color = NSColor.darkGrayColor()
            }
            
            image.colorBlendFactor = 1.0
        }
        
        image.zPosition = 0
        
        self.index = index
        
        clickable = SKSpriteNode(imageNamed:"blank.png")
        clickable.resizeNode(size.width, y:size.height)
        clickable.position = CGPointMake(0, 0)
        clickable.zPosition = 1
        
        super.init()
        
        self.addChild(image)
        self.addChild(clickable)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}