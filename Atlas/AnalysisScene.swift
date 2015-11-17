//
//  GameScene.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/30/15.
//  Copyright (c) 2015 Runemark Studios. All rights reserved.
//

import Foundation
import SpriteKit

enum AnalysisMode
{
    case Standard, Analyze
}

class AnalysisScene: SKScene, ButtonDelegate, ACMapOpenerDelegate
{
    var window:CGSize
    var center:CGPoint
    var tileMapView:TileMapLayer
    var tileMap:StandardTileMap
    var ticker:ACTicker
    
    var ui_menuBG:SKSpriteNode
    var ui_loadButton:ACHoverButton
    var ui_analyzeButton:ACHoverButton
    var ui_openMapWindow:ACOpenMapView?
    
    var mode:AnalysisMode = AnalysisMode.Standard
    
    var dragStart:CGPoint
    
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
        
        ui_loadButton = ACHoverButton(size:hoverButtonSize, iconName:"load", identifier:"load")
        ui_loadButton.position = CGPointMake(iconSize, size.height - menuBarHeight/2)
        ui_loadButton.zPosition = 1001
        
        ui_analyzeButton = ACHoverButton(size:hoverButtonSize, iconName:"add", identifier:"analyze")
        ui_analyzeButton.position = CGPointMake(iconSize*2.25, size.height - menuBarHeight/2)
        ui_analyzeButton.zPosition = 1001
        
        tileMap = StandardTileMap()
        tileMapView = TileMapLayer(viewSize:CGSizeMake(size.width*0.7, size.height*0.7), tileWidth:CGFloat(30), tileHeight:CGFloat(30), tileMap:tileMap)
        
        self.ticker = ACTicker()
        ticker.addTickable(tileMapView)
        
        super.init(size:size)
        
//        reloadMap(nil)
        reloadRandom(20, y:15)
        
        ui_loadButton.setButtonDelegate(self)
        ui_analyzeButton.setButtonDelegate(self)
        
        self.addChild(ui_menuBG)
        
        self.addChild(ui_loadButton)
        self.addChild(ui_analyzeButton)
        
        self.backgroundColor = NSColor(red:0.043, green:0.07, blue:0.09, alpha:1.0)
        
        tileMapView.position = center
        self.addChild(tileMapView)
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
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Input
    //////////////////////////////////////////////////////////////////////////////////////////
    
    override func mouseDown(event:NSEvent)
    {
        let mapViewLocation = event.locationInNode(tileMapView)
        dragStart = mapViewLocation
        
        ui_loadButton.mouseDown(event)
        ui_analyzeButton.mouseDown(event)
        
        ui_openMapWindow?.mouseDown(event)
    }
    
    override func mouseUp(event:NSEvent)
    {
        ui_loadButton.mouseUp(event)
        ui_analyzeButton.mouseUp(event)
    }
    
    override func mouseDragged(event:NSEvent)
    {
        let mapViewLocation = event.locationInNode(tileMapView)
        let dragDelta = mapViewLocation - dragStart
        
        tileMapView.applyDragDelta(dragDelta)
        
        dragStart = mapViewLocation
    }
    
    override func mouseMoved(event:NSEvent)
    {
        ui_loadButton.mouseMoved(event)
        ui_analyzeButton.mouseMoved(event)
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Navigation Button Delegate Methods
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func trigger(identifier:String)
    {
        if (identifier == "load")
        {
            openLoadWindow()
        }
        else if (identifier == "analyze")
        {
            analyzeMap()
        }
    }
    
    func reloadRandom(x:Int, y:Int)
    {
        let plistName = (mode == .Analyze) ? "CryptAnalysisTileset" : "CryptTileset"
        let tileset = Tileset(plistName:plistName)
        
        tileMap.loadRandom(x, yMax:y)
        
        tileMapView.reloadMapWithNewTileset(tileset)
    }
    
    func reloadMap(name:String?)
    {
        let plistName = (mode == .Analyze) ? "CryptAnalysisTileset" : "CryptTileset"
        let tileset = Tileset(plistName:plistName)
        
        if let mapName = name
        {
            tileMap.loadFromFile(mapName)
        }
        else
        {
            tileMap.loadDefault()
        }
        
        tileMapView.reloadMapWithNewTileset(tileset)
        
//        for (strength, value) in tileMapView.flowMap.strengthDistribution()
//        {
//            print("\(strength): \(value)")
//        }
    }
    
    func analyzeMap()
    {
        mode = (mode == .Analyze) ? .Standard : .Analyze
        
        if (mode == .Analyze)
        {
            let tileset = Tileset(plistName:"CryptAnalysisTileset")
            tileMapView.changeTilesetAndRefresh(tileset)
        }
        else
        {
            let tileset = Tileset(plistName:"CryptTileset")
            tileMapView.changeTilesetAndRefresh(tileset)
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Map Opener Delegate Methods
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func loadMap(name:String)
    {
        print("loading map: \(name)")
        reloadMap(name)
    }
    
    func closeMapSelectionWindow()
    {
        closeLoadWindow()
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Other
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func openLoadWindow()
    {
        ui_openMapWindow = ACOpenMapView(size:CGSizeMake(window.width*0.75, window.height*0.75))
        ui_openMapWindow!.position = center
        ui_openMapWindow!.zPosition = 1002
        ui_openMapWindow!.setMapOpenerDelegate(self)
        
        self.addChild(ui_openMapWindow!)
    }
    
    func closeLoadWindow()
    {
        ui_openMapWindow?.removeFromParent()
    }
}
