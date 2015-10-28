//
//  GameScene.swift
//  Atlas
//
//  Created by Dusty Artifact on 9/30/15.
//  Copyright (c) 2015 Runemark Studios. All rights reserved.
//

import Foundation
import SpriteKit

enum TileSelection
{
    case WALL, FLOOR, STONE, GOLD, VOID, MOVE
}

class EditorScene: SKScene, ButtonDelegate
{
    var window:CGSize
    var center:CGPoint
    var tileMapView:StandardTileMapView
    var ticker:ACTicker
    
    var ui_menuBG:SKSpriteNode
    var ui_loadButton:ACHoverButton
    var ui_saveButton:ACHoverButton
    var ui_openMapWindow:ACOpenMapView
    
    var tileSelection:TileSelection = .MOVE
    var selectionRect:SKSpriteNode
    
    var dragStart:CGPoint
    
    override init(size:CGSize)
    {
        window = size
        center = CGPoint(x:window.width/2.0, y:window.height/2.0)
        
        tileMapView = StandardTileMapView(viewSize:CGSizeMake(size.width*0.7, size.height*0.7), tileWidth:CGFloat(35), tileHeight:CGFloat(35))
        
        self.ticker = ACTicker()
        ticker.addTickable(tileMapView)
        
        self.dragStart = CGPointMake(0, 0)

        selectionRect = SKSpriteNode(imageNamed:"square.png")
        
        ui_menuBG = SKSpriteNode(imageNamed:"square.png")
        
        let menuBarHeight = CGFloat(40)
        let iconSize = menuBarHeight*0.75
        
        ui_loadButton = ACHoverButton(size:CGSize(width:iconSize, height:iconSize), iconName:"load", identifier:"load")
        ui_loadButton.position = CGPointMake(iconSize, size.height - menuBarHeight/2)
        ui_loadButton.zPosition = 1001
            
        ui_saveButton = ACHoverButton(size:CGSize(width:iconSize, height:iconSize), iconName:"save", identifier:"save")
        ui_saveButton.position = CGPointMake(iconSize*2.25, size.height - menuBarHeight/2)
        ui_saveButton.zPosition = 1001
        
        ui_openMapWindow = ACOpenMapView(size:CGSizeMake(window.width*0.75, window.height*0.75))
        ui_openMapWindow.position = center
        ui_openMapWindow.zPosition = 1002
        
        super.init(size:size)
        
        ui_loadButton.setButtonDelegate(self)
        ui_saveButton.setButtonDelegate(self)
        
        ui_menuBG.resizeNode(size.width, y:menuBarHeight)
        ui_menuBG.position = CGPointMake(center.x, size.height - menuBarHeight/2)
        ui_menuBG.color = NSColor(red:0.5, green:0.55, blue:0.6, alpha:1.0)
        ui_menuBG.colorBlendFactor = 1.0
        ui_menuBG.zPosition = 1000
        self.addChild(ui_menuBG)
    
        self.addChild(ui_loadButton)
        self.addChild(ui_saveButton)
        self.addChild(ui_openMapWindow)
        
        let tileset = Tileset(plistName:"CryptTileset")
//        tileMapView.loadMap((x:30, y:31), tileset:tileset)
//        tileMapView.loadMap(tileset)
        
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
    
    func saveMap()
    {
        print("SAVING TO DISK...")
        
        //        let mapsURL = applicationSupportDirectory()!
        //        let fileURL = mapsURL.URLByAppendingPathComponent("crypt1.map")
        //
        //        do
        //        {
        //            let mapString = mapToString(tileMapView.tileMap)
        //            try mapString.writeToURL(fileURL, atomically:true, encoding:NSUTF8StringEncoding)
        //        }
        //        catch
        //        {
        //            print("SAVE FAILED...")
        //        }
        //
        //        let fadeOutAction = fadeTo(1.0, finish:0.0, duration:0.5, type:CurveType.QUADRATIC_OUT)
        //        let fadeInAction = fadeTo(0.0, finish:1.0, duration:0.5, type:CurveType.QUADRATIC_IN)
        //        
        //        saveButton.runAction(SKAction.sequence([fadeOutAction, fadeInAction]))
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Input
    //////////////////////////////////////////////////////////////////////////////////////////
    
    override func mouseDown(event:NSEvent)
    {
        let mapViewLocation = event.locationInNode(tileMapView)
        dragStart = mapViewLocation
        
        ui_loadButton.mouseDown(event)
        ui_saveButton.mouseDown(event)
    }
    
    override func mouseUp(event:NSEvent)
    {
        ui_loadButton.mouseUp(event)
        ui_saveButton.mouseUp(event)
    }
    
    override func mouseDragged(event:NSEvent)
    {
        let mapViewLocation = event.locationInNode(tileMapView)
        let dragDelta = mapViewLocation - dragStart
        
        if (tileSelection == TileSelection.MOVE)
        {
            tileMapView.applyDragDelta(dragDelta)
        }
        
        dragStart = mapViewLocation
    }
    
    override func mouseMoved(event:NSEvent)
    {
        ui_loadButton.mouseMoved(event)
        ui_saveButton.mouseMoved(event)
    }
    
    func changeSelection(selection:TileSelection)
    {
        tileSelection = selection
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Button Delegate Methods
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func trigger(identifier:String)
    {
        print("Button Triggered in Scene: \(identifier)")
        if (identifier == "load")
        {
            openLoadWindow()
        }
    }
    
    func openLoadWindow()
    {
        
    }
    
    func closeLoadWindow()
    {
        
    }
    
    func swapTile(mapViewLocation:CGPoint)
    {
        var tileValue = 0
        
        switch (tileSelection)
        {
            case .GOLD:
                tileValue = 4
                break
            case .STONE:
                tileValue = 3
                break
            case .WALL:
                tileValue = 2
                break
            case .FLOOR:
                tileValue = 1
                break
            case .VOID:
                tileValue = 0
                break
            case .MOVE:
                tileValue = -1
                break
        }
        
        if (tileValue > -1)
        {
            // Update the model and viewmodel
            tileMapView.changeTileAtScreenPos(mapViewLocation, value:tileValue)
        }
    }
}
