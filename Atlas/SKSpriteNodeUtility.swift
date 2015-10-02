//
//  SKSpriteNodeUtility.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/2/15.
//  Copyright © 2015 Runemark Studios. All rights reserved.
//

import SpriteKit

extension SKSpriteNode
{
    func resizeNode(x:CGFloat, y:CGFloat)
    {
        let original_x = self.size.width/self.xScale
        let original_y = self.size.height/self.yScale
        
        self.xScale = x/original_x
        self.yScale = y/original_y
    }
}