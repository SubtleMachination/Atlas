//
//  MapView.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/2/15.
//  Copyright © 2015 Runemark Studios. All rights reserved.
//

import Foundation
import SpriteKit

////////////////////////////////////////////////////////////
// ----------------------
// |       buffer       |
// |    ------------    |
// |    | viewport |    |
// |    |  (0,0)   |    |
// |    |          |    |
// |    ------------    |
// |                    |
// ----------------------
////////////////////////////////////////////////////////////

class ACTileMapView : SKNode
{
    var tileWidth:CGFloat
    var tileHeight:CGFloat
    var viewportBounds:CGRect // The desired size of the viewport
    var bufferBounds:CGRect // How far past the viewport size a tile may be before being removed
    
    // Tile tilemap model is loaded completely into memory
    var tileMap:ACTileMap
    var cameraPos:DiamondCoord
    
    var tiles:[String:SKSpriteNode]
    
    // We store a visual buffer of tile nodes based on the viewport size
    var rows:[ACTileRowView]
    
    init(viewSize:CGSize, tileWidth:CGFloat, tileHeight:CGFloat)
    {
        //////////////////////////////////////////////////////////////////////////////////////////
        // Model
        //////////////////////////////////////////////////////////////////////////////////////////
        
        self.tileMap = ACTileMap() // Generate a default tile map
        self.cameraPos = DiamondCoord(x:8.0, y:8.0, z:0.0)
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // View
        //////////////////////////////////////////////////////////////////////////////////////////
        
        self.tiles = [String:SKSpriteNode]()
        
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.viewportBounds = CGRectMake(-1*viewSize.width/2, -1*viewSize.height/2, viewSize.width, viewSize.height)
        
        let x_buffer = tileWidth
        let y_buffer = tileHeight/2
        
        self.bufferBounds = CGRectMake(-1*(viewSize.width/2 + x_buffer), -1*(viewSize.height/2 + y_buffer), viewSize.width + 2*x_buffer, viewSize.height + 2*y_buffer)
        
        self.rows = [ACTileRowView]()
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // Superclass Initialization
        super.init()
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // Debugging: DRAW SOME TILES UNDERNEATH
        //////////////////////////////////////////////////////////////////////////////////////////
        
        drawMap()
        
        //////////////////////////////////////////////////////////////////////////////////////////
        
        
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // Debugging: Observe the viewport and buffer sizes
        //////////////////////////////////////////////////////////////////////////////////////////
        let bufferSprite = SKSpriteNode(imageNamed:"square.png")
        bufferSprite.resizeNode(bufferBounds.size.width, y:bufferBounds.size.height)
        bufferSprite.position = CGPointMake(0, 0)
        bufferSprite.alpha = 0.2
        
        self.addChild(bufferSprite)
        
        let viewPortSprite = SKSpriteNode(imageNamed:"square.png")
        viewPortSprite.resizeNode(viewportBounds.size.width, y:viewportBounds.size.height)
        viewPortSprite.position = CGPointMake(0, 0)
        viewPortSprite.alpha = 0.2
        
        self.addChild(viewPortSprite)
        
        let crossHairThickness = CGFloat(2)
        
        let crossHairVerticalSprite = SKSpriteNode(imageNamed:"square.png")
        crossHairVerticalSprite.resizeNode(crossHairThickness, y:bufferBounds.size.height)
        crossHairVerticalSprite.position = CGPointMake(0, 0)
        crossHairVerticalSprite.alpha = 0.2
        
        self.addChild(crossHairVerticalSprite)
        
        let crossHairHorizontalSprite = SKSpriteNode(imageNamed:"square.png")
        crossHairHorizontalSprite.resizeNode(bufferBounds.size.width, y:crossHairThickness)
        crossHairHorizontalSprite.position = CGPointMake(0, 0)
        crossHairHorizontalSprite.alpha = 0.2
        
        self.addChild(crossHairHorizontalSprite)
        //////////////////////////////////////////////////////////////////////////////////////////
        
        regenerateRowViews()
    }
    
    func drawMap()
    {
        for x in 0..<tileMap.grid.xMax
        {
            for y in (0..<tileMap.grid.yMax).reverse()
            {
                for z in 0..<tileMap.grid.zMax
                {
                    let coord = DiscreteDiamondCoord(x:x, y:y, z:z)
                    if (tileMap.tileAt(coord)! > 0)
                    {
                        let sprite = SKSpriteNode(imageNamed:"tile.png")
                        sprite.resizeNode(tileWidth, y:tileHeight)
                        var basePosition = diamondToScreen(coord.makePrecise())
                        basePosition.x = basePosition.x + 0.5*Double(tileHeight)
                        basePosition.y = basePosition.y + 0.25*Double(tileHeight)
                        sprite.position = basePosition.toCGPoint()
                        self.addChild(sprite)
                        
                        tiles[tileSpriteStringAt(coord)] = sprite
                    }
                }
            }
        }
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadMap()
    {
        tileMap = ACTileMap()
        cameraPos = DiamondCoord(x:5.0, y:5.0, z:0.0)
    }
    
    func regenerateRowViews()
    {
        // Determine the screen coordinates of the corners of the buffer bounds
        let bottom = Double(bufferBounds.origin.y)
        let top = bottom + Double(bufferBounds.size.height)
        let left = Double(bufferBounds.origin.x)
        let right = left + Double(bufferBounds.size.width)
        
        // We already have the diamond camera coordinates
        let cameraTile = cameraPos.roundDown()
        
        // Travel horizontally until the tile position exceeds the bounds
        var leftTileBound = cameraTile
        var rightTileBound = cameraTile
        var upperTileBound = cameraTile
        var lowerTileBound = cameraTile

        // Find the left tile bound
        while (diamondToScreen(leftTileBound).x + 0.5*Double(tileWidth) > left)
        {
            leftTileBound.x = leftTileBound.x-1
            leftTileBound.y = leftTileBound.y-1
        }
        
        leftTileBound.x = leftTileBound.x+1
        leftTileBound.y = leftTileBound.y+1
        
        // Find the right tile bound
        while (diamondToScreen(rightTileBound).x + 0.5*Double(tileWidth) < right)
        {
            rightTileBound.x = rightTileBound.x+1
            rightTileBound.y = rightTileBound.y+1
        }
        
        rightTileBound.x = rightTileBound.x-1
        rightTileBound.y = rightTileBound.y-1
        
        // Find the upper tile bound
        while (diamondToScreen(upperTileBound).y + 0.25*Double(tileHeight) < top)
        {
            upperTileBound.x = upperTileBound.x-1
            upperTileBound.y = upperTileBound.y+1
        }
        
        upperTileBound.x = upperTileBound.x+1
        upperTileBound.y = upperTileBound.y-1
        
        // Find the lower tile bound
        while (diamondToScreen(lowerTileBound).y + 0.25*Double(tileHeight) > bottom)
        {
            lowerTileBound.x = lowerTileBound.x+1
            lowerTileBound.y = lowerTileBound.y-1
        }
        
        lowerTileBound.x = lowerTileBound.x-1
        lowerTileBound.y = lowerTileBound.y+1
        
        let bounds = [leftTileBound, rightTileBound, upperTileBound, lowerTileBound]
        for bound in bounds
        {
            if let sprite = tiles[tileSpriteStringAt(bound)]
            {
                sprite.color = NSColor.blueColor()
                sprite.colorBlendFactor = 1.0
            }
        }
    }
    
    func tileSpriteStringAt(coord:DiscreteDiamondCoord) -> String
    {
        return "(\(coord.x),\(coord.y),\(coord.z))"
    }
    
    ////////////////////////////////////////////////////////////
    // Coordinate System Conversions
    // (1) Diamond - 3D coordinates in the model
    // (2) Stagger - Layers of staggered 2D coordinates
    // (3) Screen - 2D-flattened coordinates on the screen
    ////////////////////////////////////////////////////////////
    
    func diamondToStaggered(coord:DiamondCoord, dimensions:DiscreteDiamondCoord) -> StaggeredCoord
    {
        let staggered_x = coord.y + coord.x
        let staggered_y = (coord.y - coord.x) + Double(dimensions.x) - 1.0
        
        // WARXING: does not take z into account
        return StaggeredCoord(x:Int(floor(staggered_x)), y:Int(floor(staggered_y)), z:Int(floor(coord.z)))
    }
    
    func diamondToStaggered(coord:DiscreteDiamondCoord, dimensions:DiscreteDiamondCoord) -> StaggeredCoord
    {
        let staggered_x = coord.y + coord.x
        let staggered_y = (coord.y - coord.x) + dimensions.x - 1
        
        // WARXING: does not take z into account
        return StaggeredCoord(x:staggered_x, y:staggered_y, z:coord.z)
    }
    
    func staggeredToDiamond(coord:StaggeredCoord, dimensions:DiscreteDiamondCoord) -> DiscreteDiamondCoord
    {
        let diamond_x = (dimensions.x - 1 - (coord.y - coord.x)) / 2
        let diamond_y = ((coord.x + coord.y - 1) / 2) - 1
        
        // WARXING: does not take z into account
        return DiscreteDiamondCoord(x:diamond_x, y:diamond_y, z:coord.z)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // NEEDS EMERGENCY RE-WORKING FOR NEW COORDINATE SYSTEM!!!
    //////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func screenToDiamond(point:ACPoint) -> DiamondCoord
    {
        let cameraScreenPos = CGPointMake(0, 0) // For now, the camera is locked to the center
        // WARXING: does not take z into account
        let screenDelta_x = point.x - Double(cameraScreenPos.x)
        let screenDelta_y = point.y - Double(cameraScreenPos.y)
        
        let width = Double(tileWidth)
        let height = Double(tileHeight)
        
        let tileDelta_x = (screenDelta_x/width) - 2*(screenDelta_y/height)
        let tileDelta_y = (screenDelta_x/width) + 2*(screenDelta_y/height)
        
        let tile_x = tileDelta_x + cameraPos.x
        let tile_y = tileDelta_y + cameraPos.y
        
        return DiamondCoord(x:tile_x, y:tile_y, z:cameraPos.z) // For now, locked to the SAME Z-PLANE AS CAMERA
    }
    
    func screenToNearestDiamond(point:ACPoint) -> DiscreteDiamondCoord
    {
        // WARXING: does not take z into account
        let exactDiamondLoc = screenToDiamond(point)
        return DiscreteDiamondCoord(x:Int(floor(exactDiamondLoc.x)), y:Int(floor(exactDiamondLoc.y)), z:Int(floor(exactDiamondLoc.z)))
    }
    
    func diamondToScreen(coord:DiscreteDiamondCoord) -> ACPoint
    {
        return diamondToScreen(coord.makePrecise())
    }

    // The screen position of the CENTER of this tile (also represents the 0,0,0 corner of this tile)
    func diamondToScreen(coord:DiamondCoord) -> ACPoint
    {
        let tileDelta_x = coord.x - cameraPos.x
        let tileDelta_y = coord.y - cameraPos.y
        let tileDelta_z = coord.z - cameraPos.z
        
        let width = Double(tileWidth)
        let height = Double(tileHeight)
        
        let screen_x = (tileDelta_x*(0.5*width)) + (tileDelta_y*(0.5*width))
        let screen_y = (tileDelta_x*(-0.25*height)) + (tileDelta_y*(0.25*height)) + (tileDelta_z*(0.5*height))

        return ACPoint(x:screen_x, y:screen_y)
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////
    
    ////////////////////////////////////////////////////////////
    // Retrieving model data using different coordinate systems
    ////////////////////////////////////////////////////////////
    
    func tileAtDiamondPoint(coord:DiscreteDiamondCoord) -> Int?
    {
        return tileMap.tileAt(coord)
    }
    
    func tileAtStaggeredPoint(coord:StaggeredCoord) -> Int?
    {
        return tileAtDiamondPoint(staggeredToDiamond(coord, dimensions:tileMap.dimensions))
    }
}