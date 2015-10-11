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
    var tileMapView:StandardTileMapView
    var ticker:ACTicker
    
    override init(size:CGSize)
    {
        window = size
        center = CGPoint(x:window.width/2.0, y:window.height/2.0)
        tileMapView = StandardTileMapView(viewSize:CGSizeMake(size.width*0.6, size.height*0.6), tileWidth:CGFloat(45), tileHeight:CGFloat(45))
        
        self.ticker = ACTicker()
        ticker.addTickable(tileMapView)
        
        super.init(size:size)
        
        tileMapView.position = center
        self.addChild(tileMapView)
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
    
    override func update(currentTime:CFTimeInterval)
    {
        ticker.update(currentTime)
    }
}
