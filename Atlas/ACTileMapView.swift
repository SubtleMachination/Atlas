//
//  MapView.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/2/15.
//  Copyright © 2015 Runemark Studios. All rights reserved.
//

import Foundation
import SpriteKit

class ACTileMapView : SKNode
{
    var tileWidth:CGFloat
    var tileHeight:CGFloat
    var viewSize:CGSize
    
    var currentMap:ACTileMap?
//    var cameraPos:
    
    init(viewSize:CGSize, tileWidth:CGFloat, tileHeight:CGFloat)
    {
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.viewSize = viewSize
        
        super.init()
        
        
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadMap()
    {
        currentMap = ACTileMap(x:10, y:10)
    }
    
    func isoToScreen(x:Int, y:Int)
    {
        
    }
}