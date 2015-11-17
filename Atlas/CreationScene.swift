//
//  CreationScene.swift
//  Atlas
//
//  Created by Dusty Artifact on 11/4/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation
import SpriteKit

enum PausedState
{
    case PAUSED, UNPAUSED
}

class CreationScene: SKScene, ButtonDelegate, MapDelegate
{
    var window:CGSize
    var center:CGPoint
    var tileMapView:TileMapLayer
    var tileMap:StandardTileMap
    var ticker:ACTicker
    var tickCounter:Int = 0
    var state:PausedState = PausedState.PAUSED
    
    var ui_menuBG:SKSpriteNode
    var ui_pauseButton:ACHoverButton
    var ui_stepButton:ACHoverButton
//    var ui_trollButton:ACHoverButton
    
    var dragStart:CGPoint
    
    var atlas:Atlas
    
    override init(size:CGSize)
    {
        window = size
        center = CGPoint(x:window.width/2.0, y:window.height/2.0)
        
        self.dragStart = CGPointMake(0, 0)
        
        let menuBarHeight = CGFloat(40)
        let iconSize = menuBarHeight*0.75
        let hoverButtonSize = CGSize(width:iconSize, height:iconSize)
        
        ui_menuBG = SKSpriteNode(imageNamed:"square.png")
        ui_menuBG.resizeNode(size.width, y:menuBarHeight)
        ui_menuBG.position = CGPointMake(center.x, size.height - menuBarHeight/2)
        ui_menuBG.color = NSColor(red:0.5, green:0.55, blue:0.6, alpha:1.0)
        ui_menuBG.colorBlendFactor = 1.0
        ui_menuBG.zPosition = 1000
        
        ui_pauseButton = ACHoverButton(size:hoverButtonSize, iconName:"play", identifier:"pauseunpause")
        ui_pauseButton.position = CGPointMake(iconSize, size.height - menuBarHeight/2)
        ui_pauseButton.zPosition = 1001
        
        ui_stepButton = ACHoverButton(size:hoverButtonSize, iconName:"step", identifier:"step")
        ui_stepButton.position = CGPointMake(iconSize*2.5, size.height - menuBarHeight/2)
        ui_stepButton.zPosition = 1001
        
//        ui_trollButton = ACHoverButton(size:hoverButtonSize, iconName:""
        
        tileMap = StandardTileMap()
        tileMapView = TileMapLayer(viewSize:CGSizeMake(size.width*0.7, size.height*0.7), tileWidth:CGFloat(30), tileHeight:CGFloat(30), tileMap:tileMap)
        
        self.ticker = ACTicker()
        ticker.addTickable(tileMapView)
        
        atlas = Atlas()
        
        super.init(size:size)
        
        // LOAD THE INITIAL MAP
        let tileset = Tileset(plistName:"CryptStaticTileset")
        tileMapView.changeTileset(tileset)
        
        tileMap.loadBlank(15, yMax:10, filler:0)
        tileMapView.reloadMap()
        
        ui_pauseButton.setButtonDelegate(self)
        ui_stepButton.setButtonDelegate(self)
        
        self.addChild(ui_menuBG)
        self.addChild(ui_pauseButton)
        self.addChild(ui_stepButton)
        
        self.backgroundColor = NSColor(red:0.043, green:0.07, blue:0.09, alpha:1.0)
        
        tileMapView.position = center
        self.addChild(tileMapView)
        
        atlas.setDelegate(self)
        atlas.setupCanvas()
        atlas.assignTask()
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
        ticker.update(currentTime)

        if tileMap.updateNeeded
        {
            tileMapView.refreshVisuals()
            tileMap.clearChanges()
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // ATLAS ENGINE - SCENE CREATION
    //////////////////////////////////////////////////////////////////////////////////////////
    
//    func applyTechnique()
//    {
//        // Step 0.1: Recalucalte symmetry
//        let aestheticValue = tileMap.computeSymmetry()
//        
//        // STEP 1: Make Move
//        if (aestheticValue > 0.8)
//        {
//            randomMove()
//        }
//        else
//        {
//            moveToImproveSymmetry()
//        }
//    }
//    
//    func randomMove()
//    {
//        // Select random position on tilemap
//        let randomPosition = tileMap.randomTile()
//        // Select random tile type
//        let randomValue = randIntBetween(1, stop:2)
//        // Apply it
//        tileMap.setTileAt(randomPosition, value:randomValue)
//    }
//    
//    func moveToImproveSymmetry()
//    {
//        // Choose random position on tilemap
//        let randomPosition = tileMap.randomTile()
//        let symmetricPosition = tileMap.symmetricPos(randomPosition)
//        // Fetch the origin and symmetric value
//        let originValue = tileMap.tileAt(randomPosition)!
//        let symmetricValue = tileMap.tileAt(symmetricPosition)!
//        
//        if (originValue != symmetricValue)
//        {
//            if (coinFlip())
//            {
//                tileMap.setTileAt(randomPosition, value:symmetricValue)
//            }
//            else
//            {
//                tileMap.setTileAt(symmetricPosition, value:originValue)
//            }
//        }
//    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // MapDelegate Methods
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func mapDimensions() -> (width:Int, height:Int)
    {
        return (width:tileMap.grid.xMax, height:tileMap.grid.yMax)
    }
    
    func tileInfo() -> (min:Int, max:Int, tiles:Set<Int>)
    {
        var tileset = Set<Int>()
        
        tileset.insert(0)
        tileset.insert(1)
        tileset.insert(2)
        
        return (min:0, max:2, tiles:tileset)
    }
    
    func valueAt(x:Int, y:Int) -> Int?
    {
        return tileMap.tileAt(DiscreteStandardCoord(x:x, y:y))
    }
    
    func setTileAt(x:Int, y:Int, val:Int)
    {
        tileMap.setTileAt(x, y:y, value:val)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Input
    //////////////////////////////////////////////////////////////////////////////////////////
    
    override func mouseDown(event:NSEvent)
    {
        let mapViewLocation = event.locationInNode(tileMapView)
        dragStart = mapViewLocation
        
        ui_pauseButton.mouseDown(event)
        ui_stepButton.mouseDown(event)
    }
    
    override func mouseUp(event:NSEvent)
    {
        ui_pauseButton.mouseUp(event)
        ui_stepButton.mouseUp(event)
    }
    
    override func mouseMoved(event:NSEvent)
    {
        ui_pauseButton.mouseMoved(event)
        ui_stepButton.mouseMoved(event)
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Navigation Button Delegate Methods
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func trigger(identifier:String)
    {
        if (identifier == "pauseunpause")
        {
            state = (state == .PAUSED) ? .UNPAUSED : .PAUSED
            let newIconName = (state == .PAUSED) ? "play" : "pause"
            ui_pauseButton.switchIcon(newIconName)
            
            if (state == .PAUSED)
            {
                atlas.pause()
            }
            else
            {
                atlas.resume()
            }
        }
        else if (identifier == "step")
        {
            atlas.proceedWithTask()
        }
    }
}

