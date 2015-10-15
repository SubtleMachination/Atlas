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
    
    var dragStart:CGPoint
    
    override init(size:CGSize)
    {
        window = size
        center = CGPoint(x:window.width/2.0, y:window.height/2.0)
        
        tileMapView = StandardTileMapView(viewSize:CGSizeMake(size.width*0.7, size.height*0.7), tileWidth:CGFloat(48), tileHeight:CGFloat(48))
        
        self.ticker = ACTicker()
        ticker.addTickable(tileMapView)
        
        self.dragStart = CGPointMake(0, 0)
        
        super.init(size:size)
        
        tileMapView.loadMap((x:30, y:30), tileset:importTileset())
        
        
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
        dragStart = event.locationInNode(tileMapView)
    }
    
    override func mouseDragged(event:NSEvent)
    {
        let newLocation = event.locationInNode(tileMapView)
        let dragDelta = newLocation - dragStart
        tileMapView.applyDragDelta(dragDelta)
        
        dragStart = newLocation
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Tileset Import
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func importTileset() -> Tileset
    {
        let tileset = Tileset()
        
        if let path = NSBundle.mainBundle().pathForResource("CryptTileset", ofType: "plist")
        {
            let contents = NSDictionary(contentsOfFile:path)!
            
            tileset.name = String(contents.valueForKey("name") as! NSString)
            tileset.atlas = String(contents.valueForKey("atlas") as! NSString)
            
            let tileContents = contents.valueForKey("tiles") as! NSDictionary
            
            for key in tileContents.allKeys
            {
                let tileIDString = key as! String
                let tileID = NSNumberFormatter().numberFromString(tileIDString)!.integerValue
                let tileDictionary = tileContents.valueForKey(tileIDString) as! NSDictionary
                
                let wall = tileDictionary.valueForKey("wall") as! Bool
                let tileSourceInfo = tileDictionary.valueForKey("tile") as! NSArray
                let baseSourceInfo = tileDictionary.valueForKey("base") as! NSArray
                
                let tileOptions = TileOptions(wall:wall)
                
                for index in 0..<tileSourceInfo.count
                {
                    let sourceImageName = String(tileSourceInfo[index] as! NSString)
                    tileOptions.tile.append(sourceImageName)
                }
                
                for index in 0..<baseSourceInfo.count
                {
                    let sourceImageName = String(baseSourceInfo[index] as! NSString)
                    tileOptions.base.append(sourceImageName)
                }
                
                tileset.tiles[tileID] = tileOptions
            }
            
            print("derp")
        }
        else
        {
            print("CRYPT FILE MISSING")
        }
        
        return tileset
    }
}
