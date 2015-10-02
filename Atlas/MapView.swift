//
//  MapView.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/2/15.
//  Copyright © 2015 Runemark Studios. All rights reserved.
//

import Foundation
import SpriteKit

class MapView : SKNode
{
    var tileWidth:CGFloat
    var tileHeight:CGFloat
    var viewSize:CGSize
    
    init(viewSize:CGSize, tileWidth:CGFloat, tileHeight:CGFloat)
    {
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.viewSize = viewSize
        
        super.init()
        
        // Simply create a grid of tiles
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}