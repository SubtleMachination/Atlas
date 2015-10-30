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
    case MOVE, VOID, DIRT, DIRTWALL, STONEWALL, GOLD, PALE
}

class EditorScene: SKScene, ButtonDelegate, ACMapOpenerDelegate, ACMapCreatorDelegate, ACMapSaverDelegate, NSTextFieldDelegate
{
    var window:CGSize
    var center:CGPoint
    var tileMapView:StandardTileMapView
    var ticker:ACTicker
    
    var ui_menuBG:SKSpriteNode
    var ui_loadButton:ACHoverButton
    var ui_saveButton:ACHoverButton
    var ui_newButton:ACHoverButton
    var ui_openMapWindow:ACOpenMapView?
    var ui_newMapWindow:ACNewMapView?
    var ui_saveMapWindow:ACSaveMapView?
    
    var mapName:String
    var unsavedChanges:Bool
    
    var tileSelection:TileSelection
    var selectionRect:SKSpriteNode
    
    var moveButton:SKSpriteNode
    var voidButton:SKSpriteNode
    var dirtButton:SKSpriteNode
    var dirtWallButton:SKSpriteNode
    var stoneWallButton:SKSpriteNode
    var goldButton:SKSpriteNode
    var paleButton:SKSpriteNode
    
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
            
        ui_saveButton = ACHoverButton(size:hoverButtonSize, iconName:"save", identifier:"save")
        ui_saveButton.position = CGPointMake(iconSize*2.25, size.height - menuBarHeight/2)
        ui_saveButton.zPosition = 1001
        
        ui_newButton = ACHoverButton(size:hoverButtonSize, iconName:"add", identifier:"new")
        ui_newButton.position = CGPointMake(iconSize*3.5, size.height - menuBarHeight/2)
        ui_newButton.zPosition = 1001
        
        tileMapView = StandardTileMapView(viewSize:CGSizeMake(size.width*0.7, size.height*0.7), tileWidth:CGFloat(35), tileHeight:CGFloat(35))
        
        self.ticker = ACTicker()
        ticker.addTickable(tileMapView)
        
        mapName = ""
        unsavedChanges = true
        
        tileSelection = .MOVE
        
        moveButton = SKSpriteNode(imageNamed:"square.png")
        moveButton.resizeNode(25, y:25)
        moveButton.color = NSColor(red:0.1, green:0.15, blue:0.2, alpha:1.0)
        moveButton.colorBlendFactor = 1.0
        moveButton.position = CGPointMake(150, ui_menuBG.position.y)
        moveButton.zPosition = 1005
        
        voidButton = SKSpriteNode(imageNamed:"square.png")
        voidButton.resizeNode(25, y:25)
        voidButton.color = NSColor.blackColor()
        voidButton.colorBlendFactor = 1.0
        voidButton.position = CGPointMake(200, ui_menuBG.position.y)
        voidButton.zPosition = 1005
        
        dirtButton = SKSpriteNode(imageNamed:"dirt_1.png")
        dirtButton.resizeNode(25, y:25)
        dirtButton.position = CGPointMake(250, ui_menuBG.position.y)
        dirtButton.zPosition = 1005
        
        dirtWallButton = SKSpriteNode(imageNamed:"dirtwall_1.png")
        dirtWallButton.resizeNode(25, y:25)
        dirtWallButton.position = CGPointMake(300, ui_menuBG.position.y)
        dirtWallButton.zPosition = 1005
        
        stoneWallButton = SKSpriteNode(imageNamed:"stonewall_1.png")
        stoneWallButton.resizeNode(25, y:25)
        stoneWallButton.position = CGPointMake(350, ui_menuBG.position.y)
        stoneWallButton.zPosition = 1005
        
        goldButton = SKSpriteNode(imageNamed:"goldwall_1.png")
        goldButton.resizeNode(25, y:25)
        goldButton.position = CGPointMake(400, ui_menuBG.position.y)
        goldButton.zPosition = 1005
        
        paleButton = SKSpriteNode(imageNamed:"palewall_1.png")
        paleButton.resizeNode(25, y:25)
        paleButton.position = CGPointMake(450, ui_menuBG.position.y)
        paleButton.zPosition = 1005
        
        selectionRect = SKSpriteNode(imageNamed:"square.png")
        selectionRect.resizeNode(30, y:30)
        selectionRect.position = CGPointMake(0, 0)
        selectionRect.zPosition = 1004
        
        super.init(size:size)
        
        reloadMap(nil)
        
        ui_loadButton.setButtonDelegate(self)
        ui_saveButton.setButtonDelegate(self)
        ui_newButton.setButtonDelegate(self)
    
        self.addChild(ui_menuBG)
    
        self.addChild(ui_loadButton)
        self.addChild(ui_saveButton)
        self.addChild(ui_newButton)
        
        self.backgroundColor = NSColor(red:0.043, green:0.07, blue:0.09, alpha:1.0)
        
        tileMapView.position = center
        self.addChild(tileMapView)
        
        self.addChild(selectionRect)
        self.addChild(moveButton)
        self.addChild(voidButton)
        self.addChild(dirtButton)
        self.addChild(dirtWallButton)
        self.addChild(stoneWallButton)
        self.addChild(goldButton)
        self.addChild(paleButton)
        
        changeSelection(.MOVE)
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
        let appSupportURL = applicationSupportDirectory()!
        let mapsURL = appSupportURL.URLByAppendingPathComponent("maps")
        let fileURL = mapsURL.URLByAppendingPathComponent("\(mapName).map")

        do
        {
            let mapString = mapToString(tileMapView.tileMap)
            try mapString.writeToURL(fileURL, atomically:true, encoding:NSUTF8StringEncoding)
        }
        catch
        {
            print("SAVE FAILED...")
        }
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
        ui_newButton.mouseDown(event)
        
        ui_openMapWindow?.mouseDown(event)
        ui_newMapWindow?.mouseDown(event)
        ui_saveMapWindow?.mouseDown(event)
        
        let editorLocation = event.locationInNode(self)
        
        if (nodeAtPoint(editorLocation) == moveButton) { changeSelection(TileSelection.MOVE) }
        else if (nodeAtPoint(editorLocation) == voidButton) { changeSelection(TileSelection.VOID) }
        else if (nodeAtPoint(editorLocation) == dirtButton) { changeSelection(TileSelection.DIRT) }
        else if (nodeAtPoint(editorLocation) == dirtWallButton) { changeSelection(TileSelection.DIRTWALL) }
        else if (nodeAtPoint(editorLocation) == stoneWallButton) { changeSelection(TileSelection.STONEWALL) }
        else if (nodeAtPoint(editorLocation) == goldButton) { changeSelection(TileSelection.GOLD) }
        else if (nodeAtPoint(editorLocation) == paleButton) { changeSelection(TileSelection.PALE) }
        else if (tileSelection != .MOVE)
        {
            // Apply tile change to map
            swapTile(mapViewLocation)
        }
    }
    
    override func mouseUp(event:NSEvent)
    {
        ui_loadButton.mouseUp(event)
        ui_saveButton.mouseUp(event)
        ui_newButton.mouseUp(event)
    }
    
    override func mouseDragged(event:NSEvent)
    {
        let mapViewLocation = event.locationInNode(tileMapView)
        let dragDelta = mapViewLocation - dragStart
        
        if (tileSelection == .MOVE)
        {
            tileMapView.applyDragDelta(dragDelta)
        }
        
        dragStart = mapViewLocation
    }
    
    override func mouseMoved(event:NSEvent)
    {
        ui_loadButton.mouseMoved(event)
        ui_saveButton.mouseMoved(event)
        ui_newButton.mouseMoved(event)
    }
    
    func changeSelection(selection:TileSelection)
    {
        tileSelection = selection
        
        // Move the selection rectangle
        switch selection
        {
            case .MOVE:
                selectionRect.position = moveButton.position
                break
            case .VOID:
                selectionRect.position = voidButton.position
                break
            case .DIRT:
                selectionRect.position = dirtButton.position
                break
            case .DIRTWALL:
                selectionRect.position = dirtWallButton.position
                break
            case .STONEWALL:
                selectionRect.position = stoneWallButton.position
                break
            case .GOLD:
                selectionRect.position = goldButton.position
                break
            case .PALE:
                selectionRect.position = paleButton.position
                break
        }
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
        else if (identifier == "new")
        {
            openNewWindow()
        }
        else if (identifier == "save")
        {
            if (mapName == "")
            {
                openSaveWindow()
            }
            else
            {
                saveMap()
            }
        }
    }
    
    func reloadMap(name:String?)
    {
        let tileset = Tileset(plistName:"CryptTileset")
        tileMapView.loadMap(name, tileset:tileset)
        
        // PERFORM ANALYSIS
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Map Opener Delegate Methods
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func loadMap(name:String)
    {
        print("loading map: \(name)")
        reloadMap(name)
        
        mapName = name
        unsavedChanges = false
    }
    
    func closeMapSelectionWindow()
    {
        closeLoadWindow()
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Map Creator Delegate Methods
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func createMapWithDimensions(x:Int, y:Int)
    {
        let tileset = Tileset(plistName:"CryptTileset")
        tileMapView.loadBlankMap(x, y:y, tileset:tileset)
        
        closeNewMapWindow()
    }
    
    func closeNewMapWindow()
    {
        closeNewWindow()
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Map Saver Delegate Methods
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func saveMapWithName(name:String)
    {
        mapName = (name.isEmpty) ? "Default" : name
        saveMap()
    }
    
    func closeSaveMapWindow()
    {
        closeSaveWindow()
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
    
    func openNewWindow()
    {
        ui_newMapWindow = ACNewMapView(size:CGSizeMake(window.width*0.5, window.height*0.5))
        ui_newMapWindow!.position = center
        ui_newMapWindow!.zPosition = 1002
        ui_newMapWindow!.setNewWindowDelegate(self)
        
        self.addChild(ui_newMapWindow!)
    }
    
    func openSaveWindow()
    {
        ui_saveMapWindow = ACSaveMapView(size:CGSizeMake(window.width*0.5, window.height*0.5))
        ui_saveMapWindow!.position = center
        ui_saveMapWindow!.zPosition = 1002
        ui_saveMapWindow!.setSaveWindowDelegate(self)
        
        self.addChild(ui_saveMapWindow!)
    }
    
    func closeLoadWindow()
    {
        ui_openMapWindow?.removeFromParent()
    }
    
    func closeNewWindow()
    {
        ui_newMapWindow?.removeFromParent()
    }
    
    func closeSaveWindow()
    {
        ui_saveMapWindow?.removeFromParent()
    }
    
    func swapTile(mapViewLocation:CGPoint)
    {
        var tileValue = 0
        
        switch (tileSelection)
        {
            case .PALE:
                tileValue = 5
                break
            case .GOLD:
                tileValue = 4
                break
            case .STONEWALL:
                tileValue = 3
                break
            case .DIRTWALL:
                tileValue = 2
                break
            case .DIRT:
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
