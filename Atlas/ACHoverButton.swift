//
//  ACHoverButton.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/24/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation
import SpriteKit

class ACHoverButton : SKNode
{
    let bg:SKSpriteNode
    let icon:SKSpriteNode
    
    init(size:CGSize, iconName:String)
    {
        bg = SKSpriteNode(imageNamed:"smooth_square.png")
        icon = SKSpriteNode(imageNamed:iconName)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}