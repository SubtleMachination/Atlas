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
    var cameraPos:ACCoord
    
    // We store a visual buffer of tile nodes based on the viewport size
    var rows:[ACTileRowView]
    
    init(viewSize:CGSize, tileWidth:CGFloat, tileHeight:CGFloat)
    {
        //////////////////////////////////////////////////////////////////////////////////////////
        // Model
        //////////////////////////////////////////////////////////////////////////////////////////
        
        self.tileMap = ACTileMap() // Generate a default tile map
        self.cameraPos = ACCoord(x:5.0, y:5.0, z:0.0)
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // View
        //////////////////////////////////////////////////////////////////////////////////////////
        
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.viewportBounds = CGRectMake(-1*viewSize.width/2, -1*viewSize.height/2, viewSize.width, viewSize.height)
        
        let x_buffer = tileWidth/2
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
        bufferSprite.alpha = 0.25
        
        self.addChild(bufferSprite)
        
        let viewPortSprite = SKSpriteNode(imageNamed:"square.png")
        viewPortSprite.resizeNode(viewportBounds.size.width, y:viewportBounds.size.height)
        viewPortSprite.position = CGPointMake(0, 0)
        viewPortSprite.alpha = 0.25
        
        self.addChild(viewPortSprite)
        //////////////////////////////////////////////////////////////////////////////////////////
        
        regenerateRowViews()
    }
    
    func drawMap()
    {
        for x in 0..<tileMap.grid.xMax
        {
            for y in 0..<tileMap.grid.yMax
            {
                for z in 0..<tileMap.grid.zMax
                {
                    let coord = ACDiscreteCoord(x:x, y:y, z:z)
                    if (tileMap.tileAt(coord)! > 0)
                    {
                        let sprite = SKSpriteNode(imageNamed:"tile.png")
                        sprite.resizeNode(tileWidth, y:tileHeight)
                        sprite.position = diamondToScreen(coord.makePrecise()).toCGPoint()
                        self.addChild(sprite)
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
        cameraPos = ACCoord(x:5.0, y:5.0, z:0.0)
    }
    
    func regenerateRowViews()
    {
        // STEP 1: Determine the screen coordinates of the corners of the buffer bounds
        let bottom = Double(bufferBounds.origin.y)
        let top = bottom + Double(bufferBounds.size.height)
        let left = Double(bufferBounds.origin.x)
        let right = left + Double(bufferBounds.size.width)
        
        let bottomLeftCorner = ACPoint(x:left, y:bottom)
        let bottomRightCorner = ACPoint(x:right, y:bottom)
        let topLeftCorner = ACPoint(x:left, y:top)
        let topRightCorner = ACPoint(x:right, y:top)
        
        // STEP 2: Determine the diamond tiles at these corners
        let bottomLeftDiamondTile = screenToNearestDiamond(bottomLeftCorner)
        let bottomRightDiamondTile = screenToNearestDiamond(bottomRightCorner)
        let topLeftDiamondTile = screenToNearestDiamond(topLeftCorner)
        let topRightDiamondTile = screenToNearestDiamond(topRightCorner)
        
        let dimensions = tileMap.dimensions
        
        // STEP 3: Determine the staggered coordiantes of these tiles
        let bottomLeftStaggeredTile = diamondToStaggered(bottomLeftDiamondTile, dimensions:dimensions)
        let bottomRightStaggeredTile = diamondToStaggered(bottomRightDiamondTile, dimensions:dimensions)
        let topLeftStaggeredTile = diamondToStaggered(topLeftDiamondTile, dimensions:dimensions)
        let topRightStaggeredTile = diamondToStaggered(topRightDiamondTile, dimensions:dimensions)
        
        // STEP 4: Determine the staggered bounds (width and height)
        let minStaggeredX = (bottomLeftStaggeredTile.x < topLeftStaggeredTile.x) ? bottomLeftStaggeredTile.x : topLeftStaggeredTile.x
        let maxStaggeredX = (bottomRightStaggeredTile.x > topRightStaggeredTile.x) ? bottomRightStaggeredTile.x : topRightStaggeredTile.x
        let minStaggeredY = (bottomLeftStaggeredTile.y < bottomRightStaggeredTile.y) ? bottomLeftStaggeredTile.y : bottomRightStaggeredTile.y
        let maxStaggeredY = (topLeftStaggeredTile.y > topRightStaggeredTile.y) ? topLeftStaggeredTile.y : topRightStaggeredTile.y
        
        let staggeredWidth = maxStaggeredX - minStaggeredX
        let staggeredHeight = maxStaggeredY - minStaggeredY
        
        print("\(staggeredWidth), \(staggeredHeight)")
        
        // STEP 5: Determine whether the first row is short or long
        
        // STEP 6: Generate alternating short and long rows (position relative to camera)
        
        // STEP 7: FILL the rows with tiles from the tileMap
        
        
    }
    
    ////////////////////////////////////////////////////////////
    // Coordinate System Conversions
    // (1) Diamond - 3D coordinates in the model
    // (2) Stagger - Layers of staggered 2D coordinates
    // (3) Screen - 2D-flattened coordinates on the screen
    ////////////////////////////////////////////////////////////
    
    func diamondToStaggered(coord:ACCoord, dimensions:ACDiscreteCoord) -> ACCoord
    {
        let staggered_x = coord.y + coord.x
        let staggered_y = (coord.y - coord.x) + Double(dimensions.x) - 1.0
        
        // WARXING: does not take z into account
        return ACCoord(x:staggered_x, y:staggered_y, z:coord.z)
    }
    
    func diamondToStaggered(coord:ACDiscreteCoord, dimensions:ACDiscreteCoord) -> ACDiscreteCoord
    {
        let staggered_x = coord.y + coord.x
        let staggered_y = (coord.y - coord.x) + dimensions.x - 1
        
        // WARXING: does not take z into account
        return ACDiscreteCoord(x:staggered_x, y:staggered_y, z:coord.z)
    }
    
    func staggeredToDiamond(coord:ACCoord, dimensions:ACDiscreteCoord) -> ACCoord
    {
        let diamond_x = (Double(dimensions.x) - 1.0 - (coord.y - coord.x)) / 2.0
        let diamond_y = ((coord.x + coord.y - 1.0) / 2.0) - 1.0
        
        // WARXING: does not take z into account
        return ACCoord(x:diamond_x, y:diamond_y, z:coord.z)
    }
    
    func staggeredToDiamond(coord:ACDiscreteCoord, dimensions:ACDiscreteCoord) -> ACDiscreteCoord
    {
        let diamond_x = (dimensions.x - 1 - (coord.y - coord.x)) / 2
        let diamond_y = ((coord.x + coord.y - 1) / 2) - 1
        
        // WARXING: does not take z into account
        return ACDiscreteCoord(x:diamond_x, y:diamond_y, z:coord.z)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // NEEDS EMERGENCY RE-WORKING FOR NEW COORDINATE SYSTEM!!!
    //////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func screenToDiamond(point:ACPoint) -> ACCoord
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
        
        return ACCoord(x:tile_x, y:tile_y, z:cameraPos.z) // For now, locked to the SAME Z-PLANE AS CAMERA
    }
    
    func screenToNearestDiamond(point:ACPoint) -> ACDiscreteCoord
    {
        // WARXING: does not take z into account
        let exactDiamondLoc = screenToDiamond(point)
        return ACDiscreteCoord(x:Int(floor(exactDiamondLoc.x)), y:Int(floor(exactDiamondLoc.y)), z:Int(floor(exactDiamondLoc.z)))
    }

    // STILL REQUIRES RE-WRITE
    // The screen position of the CENTER of this tile (also represents the 0,0,0 corner of this tile)
    func diamondToScreen(coord:ACCoord) -> ACPoint
    {
        let tileDelta_x = coord.x - cameraPos.x
        let tileDelta_y = coord.y - cameraPos.y
        let tileDelta_z = coord.z - cameraPos.z
        
        let width = Double(tileWidth)
        let height = Double(tileHeight)
        
        let screen_x = (tileDelta_x*(0.5*width)) + (tileDelta_y*(-0.5*width))
        let screen_y = (tileDelta_x*(-0.25*height)) + (tileDelta_y*(-0.25*height)) + (tileDelta_z*(0.5*height))

        return ACPoint(x:screen_x, y:screen_y)
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////
    
    ////////////////////////////////////////////////////////////
    // Retrieving model data using different coordinate systems
    ////////////////////////////////////////////////////////////
    
    func tileAtDiamondPoint(coord:ACDiscreteCoord) -> Int?
    {
        return tileMap.tileAt(coord)
    }
    
    func tileAtStaggeredPoint(coord:ACDiscreteCoord) -> Int?
    {
        return tileAtDiamondPoint(staggeredToDiamond(coord, dimensions:tileMap.dimensions))
    }
}