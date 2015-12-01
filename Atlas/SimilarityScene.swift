//
//  SimilarityComparisonScene.swift
//  Atlas
//
//  Created by Dusty Artifact on 11/11/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation
import SpriteKit

enum InteractionState
{
    case Paused, Playing
}

class SimilarityScene: SKScene, ButtonDelegate
{
    var window:CGSize
    var center:CGPoint
    
    var ui_menuBG:SKSpriteNode
    var ui_pauseButton:ACHoverButton
    var ui_openMapWindow:ACOpenMapView?
    
    var flowMapA:StaggeredPointMap
    var flowMapB:StaggeredPointMap
    
    var state:InteractionState = InteractionState.Paused
    
    override init(size:CGSize)
    {
        window = size
        center = CGPoint(x:window.width/2.0, y:window.height/2.0)
        
        let menuBarHeight = CGFloat(40)
        let iconSize = menuBarHeight*0.75
        let hoverButtonSize = CGSize(width:iconSize, height:iconSize)
        
        ui_menuBG = SKSpriteNode(imageNamed:"square.png")
        ui_menuBG.resizeNode(size.width, y:menuBarHeight)
        ui_menuBG.position = CGPointMake(center.x, size.height - menuBarHeight/2)
        ui_menuBG.color = NSColor(red:0.5, green:0.55, blue:0.6, alpha:1.0)
        ui_menuBG.colorBlendFactor = 1.0
        ui_menuBG.zPosition = 1000
        
        ui_pauseButton = ACHoverButton(size:hoverButtonSize, iconName:"pause", identifier:"load")
        ui_pauseButton.position = CGPointMake(iconSize, size.height - menuBarHeight/2)
        ui_pauseButton.zPosition = 1001
        
        let tileMapA = StandardTileMap()
        tileMapA.loadFromFile("1-1")
        flowMapA = StaggeredPointMap(xTileWidth:tileMapA.grid.xMax, yTileHeight:tileMapA.grid.yMax, filler:0)
        flowMapA.computeSkeletonFromPathMap(tileMapA.binaryPaths())
        
        let tileMapB = StandardTileMap()
        tileMapB.loadFromFile("1-2")
        flowMapB = StaggeredPointMap(xTileWidth:tileMapB.grid.xMax, yTileHeight:tileMapB.grid.yMax, filler:0)
        flowMapB.computeSkeletonFromPathMap(tileMapB.binaryPaths())
        
        super.init(size:size)
        
        ui_pauseButton.setButtonDelegate(self)
        
        self.addChild(ui_menuBG)
        
        self.addChild(ui_pauseButton)
        
        self.backgroundColor = NSColor(red:0.043, green:0.07, blue:0.09, alpha:1.0)
    }
    
    required init?(coder aDecoder:NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view:SKView)
    {
        let trackingArea = NSTrackingArea(rect:view.frame, options:[.MouseMoved, .ActiveInKeyWindow], owner:self, userInfo:nil)
        view.addTrackingArea(trackingArea)
    }
    
    override func update(currentTime:CFTimeInterval)
    {

    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Input
    //////////////////////////////////////////////////////////////////////////////////////////
    
    override func mouseDown(event:NSEvent)
    {
        ui_pauseButton.mouseDown(event)
    }
    
    override func mouseUp(event:NSEvent)
    {
        ui_pauseButton.mouseUp(event)
    }
    
    override func mouseMoved(event:NSEvent)
    {
        ui_pauseButton.mouseMoved(event)
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Navigation Button Delegate Methods
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func trigger(identifier:String)
    {
        if (identifier == "pause")
        {
            state = (state == InteractionState.Paused) ? .Playing : .Paused
        }
    }
}