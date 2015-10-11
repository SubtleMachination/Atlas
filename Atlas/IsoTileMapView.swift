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

public class IsoTileMapView : SKNode, ACTickable
{
    var tileWidth:CGFloat
    var tileHeight:CGFloat
    var viewportBounds:CGRect // The desired size of the viewport
    var bufferBounds:CGRect // How far past the viewport size a tile may be before being removed
    var staggeredBufferBounds:ACTileBoundingBox
    var staggeredWindowWidth:Int
    
    // Tile tilemap model is loaded completely into memory
    var tileMap:IsoTileMap
    var cameraPos:DiamondCoord
    var cameraVel:DiamondCoord
    
    // We store a visual buffer of tile nodes based on the viewport size
    var rows:[Int:IsoTileRowView]
    
    init(viewSize:CGSize, tileWidth:CGFloat, tileHeight:CGFloat)
    {
        //////////////////////////////////////////////////////////////////////////////////////////
        // Model
        //////////////////////////////////////////////////////////////////////////////////////////
        
        self.tileMap = IsoTileMap()
        self.cameraPos = DiamondCoord(x:2.0, y:2.0, z:0.0)
        self.cameraVel = DiamondCoord(x:0.02, y:0.01, z:0)
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // View
        //////////////////////////////////////////////////////////////////////////////////////////
        
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.viewportBounds = CGRectMake(-1*viewSize.width/2, -1*viewSize.height/2, viewSize.width, viewSize.height)
        self.staggeredWindowWidth = 0
        
        let sideBuffer = tileWidth
        let upperBuffer = tileHeight/2
        let lowerBuffer = tileHeight/2
        
        self.bufferBounds = CGRectMake(-1*(viewSize.width/2 + sideBuffer), -1*(viewSize.height/2 + (upperBuffer + lowerBuffer)/2), viewSize.width + 2*sideBuffer, viewSize.height + upperBuffer + lowerBuffer)
        self.staggeredBufferBounds = ACTileBoundingBox(left:0, right:0, up:0, down:0)
        
        self.rows = [Int:IsoTileRowView]()
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // Superclass Initialization
        super.init()
        //////////////////////////////////////////////////////////////////////////////////////////
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // Map Loading
        //////////////////////////////////////////////////////////////////////////////////////////
        self.loadMap((x:20, y:20))
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // Debugging: Observe the viewport and buffer sizes
        //////////////////////////////////////////////////////////////////////////////////////////
        let bufferSprite = SKSpriteNode(imageNamed:"square.png")
        bufferSprite.resizeNode(bufferBounds.size.width, y:bufferBounds.size.height)
        bufferSprite.position = CGPointMake(0, 0)
        bufferSprite.zPosition = 1000
        bufferSprite.alpha = 0.2
        
        self.addChild(bufferSprite)
        
        let viewPortSprite = SKSpriteNode(imageNamed:"square.png")
        viewPortSprite.resizeNode(viewportBounds.size.width, y:viewportBounds.size.height)
        viewPortSprite.position = CGPointMake(0, 0)
        viewPortSprite.zPosition = 1000
        viewPortSprite.alpha = 0.2
        
        self.addChild(viewPortSprite)
        
        let crossHairThickness = CGFloat(2)
        
        let crossHairVerticalSprite = SKSpriteNode(imageNamed:"square.png")
        crossHairVerticalSprite.resizeNode(crossHairThickness, y:bufferBounds.size.height)
        crossHairVerticalSprite.position = CGPointMake(0, 0)
        crossHairVerticalSprite.zPosition = 1000
        crossHairVerticalSprite.alpha = 0.2
        
        self.addChild(crossHairVerticalSprite)
        
        let crossHairHorizontalSprite = SKSpriteNode(imageNamed:"square.png")
        crossHairHorizontalSprite.resizeNode(bufferBounds.size.width, y:crossHairThickness)
        crossHairHorizontalSprite.position = CGPointMake(0, 0)
        crossHairHorizontalSprite.zPosition = 1000
        crossHairHorizontalSprite.alpha = 0.2
        
        self.addChild(crossHairHorizontalSprite)
        //////////////////////////////////////////////////////////////////////////////////////////
    }

    required public init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tick(interval:NSTimeInterval)
    {
        // Move the camera
        let oldCameraPos = cameraPos
        cameraPos += cameraVel
        
        let oldScreenPos = diamondToScreen(oldCameraPos)
        let newScreenPos = diamondToScreen(cameraPos)
        let screenDelta = oldScreenPos - newScreenPos
        
        moveMap(screenDelta)
    }
    
    func moveMap(screenDelta:ACPoint)
    {
        for (_, rowView) in rows
        {
            rowView.position.y += CGFloat(screenDelta.y)
            
            for (_, tile) in rowView.tiles
            {
                tile.position.x += CGFloat(screenDelta.x)
            }
        }
        
        let lowerRow_screen_y = CGFloat(screenYForStaggeredRow(staggeredBufferBounds.down))
        if (lowerRow_screen_y < bufferBounds.origin.x)
        {
            shiftDown()
        }
        
        let upperRow_screen_y = CGFloat(screenYForStaggeredRow(staggeredBufferBounds.up))
        if (upperRow_screen_y > bufferBounds.origin.y + bufferBounds.size.height)
        {
            shiftUp()
        }
        
        let leftCol_screen_x = CGFloat(screenXForStaggeredCol(staggeredBufferBounds.left))
        if (leftCol_screen_x < bufferBounds.origin.x)
        {
            shiftLeft()
        }
        
        let rightCol_screen_x = CGFloat(screenXForStaggeredCol(staggeredBufferBounds.right))
        if (rightCol_screen_x > bufferBounds.origin.x + bufferBounds.size.width)
        {
            shiftRight()
        }
    }
    
    func shiftUp()
    {
        let topRowIndex = staggeredBufferBounds.up
        // REMOVE TOP ROW
        if let topRowView = rows[topRowIndex]
        {
            topRowView.removeFromParent()
            rows.removeValueForKey(topRowIndex)
        }
        
        // ADD TO BOTTOM ROW
        let bottomRowIndex = staggeredBufferBounds.down
        let newBottomRowType = (rows[bottomRowIndex]!.type == RowType.RT_LONG) ? RowType.RT_SHORT : RowType.RT_LONG
        let newBottomRowIndex = bottomRowIndex-1
        regenerateRowView(newBottomRowIndex, rowType:newBottomRowType)
        
        // UPDATE STAGGERED BUFFER BOUNDS
        staggeredBufferBounds.down -= 1
        staggeredBufferBounds.up -= 1
    }
    
    func shiftDown()
    {
        let bottomRowIndex = staggeredBufferBounds.down
        // REMOVE BOTTOM ROW
        if let bottomRowView = rows[bottomRowIndex]
        {
            bottomRowView.removeFromParent()
            rows.removeValueForKey(bottomRowIndex)
        }
        
        // ADD TO TOP ROW
        let topRowIndex = staggeredBufferBounds.up
        let newTopRowType = (rows[topRowIndex]!.type == RowType.RT_LONG) ? RowType.RT_SHORT : RowType.RT_LONG
        let newTopRowIndex = topRowIndex+1
        regenerateRowView(newTopRowIndex, rowType:newTopRowType)
        
        // UPDATE STAGGERED BUFFER BOUNDS
        staggeredBufferBounds.down += 1
        staggeredBufferBounds.up += 1
    }
    
    func shiftLeft()
    {
        let leftColIndex = staggeredBufferBounds.left
        let rightColIndex = staggeredBufferBounds.right
        
        for (_, rowView) in rows
        {
            if (rowView.type == RowType.RT_LONG)
            {
                // REMOVE LEFT COL
                if let tile = rowView.tiles[leftColIndex]
                {
                    rowView.tiles.removeValueForKey(leftColIndex)
                    tile.removeFromParent()
                }
            }
            else
            {
                // ADD TO RIGHT COL
                addTileToRowView(rowView, staggeredTile:StaggeredCoord(x:rightColIndex+1, y:rowView.rowIndex, z:0), slideIn:true)
            }
        }
        
        toggleShortAndLongRows()
        
        // Update staggered bounds
        staggeredBufferBounds.left += 1
        staggeredBufferBounds.right += 1
    }
    
    func shiftRight()
    {
        let rightColIndex = staggeredBufferBounds.right
        let leftColIndex = staggeredBufferBounds.left
        
        for (_, rowView) in rows
        {
            if (rowView.type == RowType.RT_LONG)
            {
                // REMOVE RIGHT COL
                if let tile = rowView.tiles[rightColIndex]
                {
                    rowView.tiles.removeValueForKey(rightColIndex)
                    tile.removeFromParent()
                }
            }
            else
            {
                // ADD TO LEFT COL
                addTileToRowView(rowView, staggeredTile:StaggeredCoord(x:leftColIndex-1, y:rowView.rowIndex, z:0), slideIn:true)
            }
        }
        
        toggleShortAndLongRows()
        
        // Update staggered bounds
        staggeredBufferBounds.left -= 1
        staggeredBufferBounds.right -= 1
    }
    
    func toggleShortAndLongRows()
    {
        // LONG rows are now SHORT, SHORT rows are now LONG
        for (_, rowView) in rows
        {
            rowView.type = (rowView.type == RowType.RT_LONG) ? RowType.RT_SHORT : RowType.RT_LONG
        }
    }
    
    func loadMap(dimensions:(x:Int, y:Int))
    {
        tileMap = IsoTileMap(x:dimensions.x, y:dimensions.y, z:1, filler:1)
        cameraPos = DiamondCoord(x:Double(dimensions.x)/2, y:Double(dimensions.y)/2, z:0.0)
        
        // Regenerate the view
        clearRowViews()
        regenerateRowViews()
    }
    
    func clearRowViews()
    {
        for (rowIndex, rowView) in rows
        {
            rows.removeValueForKey(rowIndex)
            rowView.removeFromParent()
        }
    }
    
    func regenerateRowViews()
    {
        let leftTileBound = findLeftViewBound()
        let rightTileBound = findRightViewBound()
        let upperTileBound = findUpperViewBound()
        let lowerTileBound = findLowerViewBound()
        
        let leftStaggeredBound = diamondToStaggered(leftTileBound)
        let rightStaggeredBound = diamondToStaggered(rightTileBound)
        let upperStaggeredBound = diamondToStaggered(upperTileBound)
        let lowerStaggeredBound = diamondToStaggered(lowerTileBound)
        staggeredWindowWidth = rightStaggeredBound.x - leftStaggeredBound.x + 1
        
        staggeredBufferBounds = ACTileBoundingBox(left:leftStaggeredBound.x, right:rightStaggeredBound.x, up:upperStaggeredBound.y, down:lowerStaggeredBound.y)
        
        var rowType = RowType.RT_LONG
        // From the top to bottom, generate rows
        for rowIndex in (lowerStaggeredBound.y...upperStaggeredBound.y).reverse()
        {
            regenerateRowView(rowIndex, rowType:rowType)
            
            // Alternate row types
            rowType = (rowType == RowType.RT_LONG) ? RowType.RT_SHORT : RowType.RT_LONG
        }
    }
    
    func regenerateRowView(rowIndex:Int, rowType:RowType)
    {
        let rowView = IsoTileRowView(rowIndex:rowIndex, width:staggeredWindowWidth, type:rowType)
        rowView.position = CGPointMake(0, CGFloat(screenYForStaggeredRow(rowIndex)))
        rowView.zPosition = CGFloat(screenDepthForStaggeredRow(rowIndex))
        
        // Add tiles to the rowView
        let currentColMin = (rowType == RowType.RT_LONG) ? staggeredBufferBounds.left : staggeredBufferBounds.left+1
        let colCount = (rowType == RowType.RT_LONG) ? ((staggeredWindowWidth-1)/2)+1 : ((staggeredWindowWidth-1)/2)
        
        var colIndex = currentColMin
        for _ in 0..<colCount
        {
            addTileToRowView(rowView, staggeredTile:StaggeredCoord(x:colIndex, y:rowIndex, z:0), slideIn:false)
            colIndex += 2
        }
        
        rows[rowIndex] = rowView
        self.addChild(rowView)
    }
    
    func addTileToRowView(rowView:IsoTileRowView, staggeredTile:StaggeredCoord, slideIn:Bool)
    {
        let diamond = staggeredToDiamond(staggeredTile)
        let fadeInDuration = CGFloat(0.25)
    
        if (tileMap.grid.isWithinBounds(diamond.x, y:diamond.y, z:diamond.z))
        {
            let tileSprite = SKSpriteNode(imageNamed:"blank.png")
            tileSprite.texture = SKTexture(imageNamed:"tile.png")
            tileSprite.resizeNode(tileWidth, y:tileHeight)
            let screen_x = diamondToScreen(staggeredToDiamond(staggeredTile)).toCGPoint().x
            let screen_y = CGFloat(0.0)
            
            tileSprite.position = CGPointMake(CGFloat(screen_x + tileWidth/2), CGFloat(screen_y + tileHeight/4))
            
            if (slideIn)
            {
                tileSprite.alpha = 0.0
            }
            
            rowView.tiles[staggeredTile.x] = tileSprite
            rowView.addChild(tileSprite)
            
            if (slideIn)
            {
                let fadeAction = fadeTo(tileSprite, alpha:1.0, duration:fadeInDuration, type:CurveType.QUADRATIC_OUT)
                tileSprite.runAction(fadeAction)
            }
        }
    }
    
    func topStaggeredRow() -> Int
    {
        let topDiamondTile = DiscreteDiamondCoord(x:tileMap.dimensions.x-1, y:tileMap.dimensions.y-1, z:0)
        let topStaggeredTile = diamondToStaggered(topDiamondTile)
        
        return topStaggeredTile.y
    }
    
    func findLeftViewBound() -> DiscreteDiamondCoord
    {
        var leftTileBound = cameraPos.roundDown()
        
        while (diamondToScreen(leftTileBound).x + 0.5*Double(tileWidth) > Double(bufferBounds.origin.x))
        {
            leftTileBound.x = leftTileBound.x-1
            leftTileBound.y = leftTileBound.y-1
        }
        
        leftTileBound.x = leftTileBound.x+1
        leftTileBound.y = leftTileBound.y+1
        
        return leftTileBound
    }
    
    func findRightViewBound() -> DiscreteDiamondCoord
    {
        var rightTileBound = cameraPos.roundDown()
        
        while (diamondToScreen(rightTileBound).x + 0.5*Double(tileWidth) < Double(bufferBounds.origin.x) + Double(bufferBounds.size.width))
        {
            rightTileBound.x = rightTileBound.x+1
            rightTileBound.y = rightTileBound.y+1
        }
        
        rightTileBound.x = rightTileBound.x-1
        rightTileBound.y = rightTileBound.y-1
        
        return rightTileBound
    }
    
    func findLowerViewBound() -> DiscreteDiamondCoord
    {
        var lowerTileBound = cameraPos.roundDown()
        
        while (diamondToScreen(lowerTileBound).y + 0.25*Double(tileHeight) > Double(bufferBounds.origin.y))
        {
            lowerTileBound.x = lowerTileBound.x+1
            lowerTileBound.y = lowerTileBound.y-1
        }
        
        lowerTileBound.x = lowerTileBound.x-1
        lowerTileBound.y = lowerTileBound.y+1
        
        return lowerTileBound
    }
    
    func findUpperViewBound() -> DiscreteDiamondCoord
    {
        var upperTileBound = cameraPos.roundDown()
        
        while (diamondToScreen(upperTileBound).y + 0.25*Double(tileHeight) < Double(bufferBounds.origin.y) + Double(bufferBounds.size.height))
        {
            upperTileBound.x = upperTileBound.x-1
            upperTileBound.y = upperTileBound.y+1
        }
        
        upperTileBound.x = upperTileBound.x+1
        upperTileBound.y = upperTileBound.y-1
        
        return upperTileBound
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
    
    func rowTypeForRow(rowIndex:Int) -> RowType
    {
        let dimensions = tileMap.dimensions
        var rowType = RowType.RT_LONG
        
        if (dimensions.x % 2 == 0)
        {
            rowType = (rowIndex % 2 == 0) ? RowType.RT_SHORT : RowType.RT_LONG
        }
        else
        {
            rowType = (rowIndex % 2 == 0) ? RowType.RT_LONG : RowType.RT_SHORT
        }
        
        return rowType
    }
    
    func diamondToStaggered(coord:DiscreteDiamondCoord) -> StaggeredCoord
    {
        let staggered_x = coord.y + coord.x
        let staggered_y = (coord.y - coord.x) + tileMap.dimensions.x - 1
        
        // WARXING: does not take z into account
        return StaggeredCoord(x:staggered_x, y:staggered_y, z:coord.z)
    }
    
    func staggeredToDiamond(coord:StaggeredCoord) -> DiscreteDiamondCoord
    {
        let diamond_x = (tileMap.dimensions.x - 1 - (coord.y - coord.x)) / 2
        let diamond_y = ((coord.x + coord.y) - (tileMap.dimensions.x-1)) / 2
        
        // WARXING: does not take z into account
        return DiscreteDiamondCoord(x:diamond_x, y:diamond_y, z:coord.z)
    }
    
    func screenXForStaggeredCol(col:Int) -> Double
    {
        let dimensions = tileMap.dimensions
        
        // Pick an arbitrary tile on the specified staggered col
        var staggeredY = 0
        if (dimensions.y % 2 == 0)
        {
            staggeredY = (col % 2 == 0) ? 1 : 0
        }
        else
        {
            staggeredY = (col % 2 == 0) ? 0 : 1
        }
        
        let staggeredTile = StaggeredCoord(x:col, y:staggeredY, z:0)
        let diamondTile = staggeredToDiamond(staggeredTile)
        let screenPosition = diamondToScreen(diamondTile)
        
        return screenPosition.x
    }
    
    func screenYForStaggeredRow(row:Int) -> Double
    {
        let dimensions = tileMap.dimensions
        
        // Pick an arbitrary tile on the specified staggered row
        var staggeredX = 0
        if (dimensions.x % 2 == 0)
        {
            staggeredX = (row % 2 == 0) ? 1 : 0
        }
        else
        {
            staggeredX = (row % 2 == 0) ? 0 : 1
        }
        
        let staggeredTile = StaggeredCoord(x:staggeredX, y:row, z:0)
        let diamondTile = staggeredToDiamond(staggeredTile)
        let screenPosition = diamondToScreen(diamondTile)
    
        return screenPosition.y
    }
    
    func screenDepthForStaggeredRow(row:Int) -> Double
    {
        // Rows closer to 0 are the deepest,
        // Rows closer to maxRow are the shallowest
        return Double(topStaggeredRow() - row)
    }
    
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
    
    ////////////////////////////////////////////////////////////
    // Retrieving model data using different coordinate systems
    ////////////////////////////////////////////////////////////
    
    func tileAtDiamondPoint(coord:DiscreteDiamondCoord) -> Int?
    {
        return tileMap.tileAt(coord)
    }
    
    func tileAtStaggeredPoint(coord:StaggeredCoord) -> Int?
    {
        return tileAtDiamondPoint(staggeredToDiamond(coord))
    }
}