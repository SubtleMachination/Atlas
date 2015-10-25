//
//  GameScene.swift
//  Atlas
//
//  Created by Dusty Artifact on 9/30/15.
//  Copyright (c) 2015 Runemark Studios. All rights reserved.
//

import SpriteKit

enum TileSelection
{
    case WALL, FLOOR, STONE, GOLD, VOID, MOVE
}

class EditorScene: SKScene
{
    var window:CGSize
    var center:CGPoint
    var tileMapView:StandardTileMapView
    var ticker:ACTicker
    
    var ui_menuBG:SKSpriteNode
    var ui_loadButton:SKSpriteNode
    var ui_saveButton:SKSpriteNode
    
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
        ui_loadButton = SKSpriteNode(imageNamed:"smooth_square.png")
        ui_saveButton = SKSpriteNode(imageNamed:"smooth_square.png")
        
        super.init(size:size)
        
        let menuBarHeight = CGFloat(40)
        
        ui_menuBG.resizeNode(size.width, y:menuBarHeight)
        ui_menuBG.position = CGPointMake(center.x, size.height - menuBarHeight/2)
        ui_menuBG.color = NSColor.darkGrayColor()
        ui_menuBG.colorBlendFactor = 1.0
        ui_menuBG.zPosition = 1000
        self.addChild(ui_menuBG)
        
        let iconSize = menuBarHeight*0.75
        let buttonBgColor = NSColor(red:0.15, green:0.15, blue:0.15, alpha:1.0)
        
        ui_loadButton.resizeNode(iconSize, y:iconSize)
        ui_loadButton.position = CGPointMake(menuBarHeight/2, size.height - menuBarHeight/2)
        ui_loadButton.color = buttonBgColor
        ui_loadButton.colorBlendFactor = 1.0
        ui_loadButton.zPosition = 1000
        self.addChild(ui_loadButton)
        
        let ui_loadIcon = SKSpriteNode(imageNamed:"load.png")
        ui_loadIcon.resizeNode(iconSize, y:iconSize)
        ui_loadIcon.position = CGPointMake(0, 0)
        ui_loadButton.addChild(ui_loadIcon)
        
        ui_saveButton.resizeNode(iconSize, y:iconSize)
        ui_saveButton.position = CGPointMake(iconSize*2, size.height - menuBarHeight/2)
        ui_saveButton.color = buttonBgColor
        ui_saveButton.colorBlendFactor = 1.0
        ui_saveButton.zPosition = 1000
        self.addChild(ui_saveButton)
        
        let ui_saveIcon = SKSpriteNode(imageNamed:"save.png")
        ui_saveIcon.resizeNode(iconSize, y:iconSize)
        ui_saveIcon.position = CGPointMake(0, 0)
        ui_saveButton.addChild(ui_saveIcon)
        
        
        
//        wallButton.resizeNode(25, y:25)
//        wallButton.position = CGPointMake(25, size.height - 25)
//        wallButton.zPosition = 1000
//        self.addChild(wallButton)
//        
//        floorButton.resizeNode(25, y:25)
//        floorButton.position = CGPointMake(60, size.height - 25)
//        floorButton.zPosition = 1000
//        self.addChild(floorButton)
//        
//        stoneButton.resizeNode(25, y:25)
//        stoneButton.position = CGPointMake(60, size.height - 60)
//        stoneButton.zPosition = 1000
//        self.addChild(stoneButton)
//        
//        goldButton.resizeNode(25, y:25)
//        goldButton.position = CGPointMake(25, size.height - 95)
//        goldButton.zPosition = 1000
//        self.addChild(goldButton)
//        
//        voidButton.resizeNode(25, y:25)
//        voidButton.position = CGPointMake(95, size.height - 25)
//        moveButton.color = NSColor.darkGrayColor()
//        moveButton.colorBlendFactor = 1.0
//        voidButton.zPosition = 1000
//        self.addChild(voidButton)
//        
//        moveButton.resizeNode(25, y:25)
//        moveButton.position = CGPointMake(25, size.height - 60)
//        moveButton.color = NSColor.greenColor()
//        moveButton.colorBlendFactor = 1.0
//        moveButton.zPosition = 1000
//        self.addChild(moveButton)
//        
//        saveButton.resizeNode(25, y:25)
//        saveButton.position = CGPointMake(95, size.height - 95)
//        saveButton.color = NSColor.orangeColor()
//        saveButton.colorBlendFactor = 1.0
//        saveButton.zPosition = 1000
//        self.addChild(saveButton)
//        
//        selectionRect.resizeNode(30, y:30)
//        selectionRect.position = voidButton.position
//        selectionRect.zPosition = 999
//        self.addChild(selectionRect)
//        
//        changeSelection(tileSelection)
        
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
        
//        let editorViewLocation = event.locationInNode(self)
        
//        if (tileSelection != .MOVE && tileMapView.viewportBounds.contains(mapViewLocation))
//        {
//            swapTile(mapViewLocation)
//        }
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
    
    func changeSelection(selection:TileSelection)
    {
        tileSelection = selection
        
//        switch (selection)
//        {
//            case .WALL:
//                selectionRect.position = wallButton.position
//                break
//            case .FLOOR:
//                selectionRect.position = floorButton.position
//                break
//            case .VOID:
//                selectionRect.position = voidButton.position
//                break
//            case .MOVE:
//                selectionRect.position = moveButton.position
//                break
//            case .STONE:
//                selectionRect.position = stoneButton.position
//                break
//            case .GOLD:
//                selectionRect.position = goldButton.position
//                break
//        }
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
