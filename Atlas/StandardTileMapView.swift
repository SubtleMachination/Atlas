//
//  StandardTileMapView.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/10/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import SpriteKit
import Foundation

public class StandardTileMapView : SKNode, ACTickable
{
    var tileWidth:CGFloat
    var tileHeight:CGFloat
    var viewportBounds:CGRect // The desired size of the viewport
    var bufferBounds:CGRect // How far past the viewport size a tile may be before being removed
    var rowWidth:Int
    var tileBoundingBox:ACTileBoundingBox
    
    // Tile tilemap model is loaded completely into memory
    var tileMap:StandardTileMap
    var cameraPos:StandardCoord
    var cameraVel:StandardCoord
    
    var floorRows:[Int:StandardTileRowView]
    var obstacleRows:[Int:StandardTileRowView]
    
    init(viewSize:CGSize, tileWidth:CGFloat, tileHeight:CGFloat)
    {
        //////////////////////////////////////////////////////////////////////////////////////////
        // Model
        //////////////////////////////////////////////////////////////////////////////////////////
        
        self.tileMap = StandardTileMap()
        self.cameraPos = StandardCoord(x:0.0, y:0.0)
        self.cameraVel = StandardCoord(x:0.01, y:0.005)
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // View
        //////////////////////////////////////////////////////////////////////////////////////////
        
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.viewportBounds = CGRectMake(-1*viewSize.width/2, -1*viewSize.height/2, viewSize.width, viewSize.height)
        
        self.bufferBounds = CGRectMake(-1*(viewSize.width + 2*tileWidth)/2, -1*(viewSize.height + 2*tileHeight)/2, viewSize.width + 2*tileWidth, viewSize.height + 2*tileHeight)
        self.rowWidth = 0
        self.tileBoundingBox = ACTileBoundingBox(left:0, right:0, up:0, down:0)
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // ViewModel
        //////////////////////////////////////////////////////////////////////////////////////////
        
        self.floorRows = [Int:StandardTileRowView]()
        self.obstacleRows = [Int:StandardTileRowView]()
        
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
//        let bufferSprite = SKSpriteNode(imageNamed:"square.png")
//        bufferSprite.resizeNode(bufferBounds.size.width, y:bufferBounds.size.height)
//        bufferSprite.position = CGPointMake(0, 0)
//        bufferSprite.zPosition = 1000
//        bufferSprite.alpha = 0.2
//        
//        self.addChild(bufferSprite)
//        
//        let viewPortSprite = SKSpriteNode(imageNamed:"square.png")
//        viewPortSprite.resizeNode(viewportBounds.size.width, y:viewportBounds.size.height)
//        viewPortSprite.position = CGPointMake(0, 0)
//        viewPortSprite.zPosition = 1000
//        viewPortSprite.alpha = 0.2
//        
//        self.addChild(viewPortSprite)
//        
//        let crossHairThickness = CGFloat(2)
//        
//        let crossHairVerticalSprite = SKSpriteNode(imageNamed:"square.png")
//        crossHairVerticalSprite.resizeNode(crossHairThickness, y:bufferBounds.size.height)
//        crossHairVerticalSprite.position = CGPointMake(0, 0)
//        crossHairVerticalSprite.zPosition = 1000
//        crossHairVerticalSprite.alpha = 0.2
//        
//        self.addChild(crossHairVerticalSprite)
//        
//        let crossHairHorizontalSprite = SKSpriteNode(imageNamed:"square.png")
//        crossHairHorizontalSprite.resizeNode(bufferBounds.size.width, y:crossHairThickness)
//        crossHairHorizontalSprite.position = CGPointMake(0, 0)
//        crossHairHorizontalSprite.zPosition = 1000
//        crossHairHorizontalSprite.alpha = 0.2
//        
//        self.addChild(crossHairHorizontalSprite)
        //////////////////////////////////////////////////////////////////////////////////////////
    }

    required public init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tick(interval:NSTimeInterval)
    {
        // Move the camera
        if (cameraVel.x > 0.0001 && cameraVel.y > 0.0001)
        {
            let oldCameraPos = cameraPos
            cameraPos += cameraVel
            
            let oldScreenPos = standardToScreen(oldCameraPos)
            let newScreenPos = standardToScreen(cameraPos)
            let screenDelta = oldScreenPos - newScreenPos
            
            moveMap(screenDelta)
        }
    }
    
    func loadMap(dimensions:(x:Int, y:Int))
    {
        tileMap = StandardTileMap(x:dimensions.x, y:dimensions.y, filler:1)
        cameraPos = StandardCoord(x:Double(dimensions.x)/2, y:Double(dimensions.y)/2)
        
        // Regenerate the view
        clearRowViews()
        regenerateRowViews()
    }
    
    // Removes all tile content instantly
    func clearRowViews()
    {
        for (rowIndex, rowView) in floorRows
        {
            floorRows.removeValueForKey(rowIndex)
            rowView.removeFromParent()
        }
        
        for (rowIndex, rowView) in obstacleRows
        {
            obstacleRows.removeValueForKey(rowIndex)
            rowView.removeFromParent()
        }
    }
    
    func regenerateRowViews()
    {
        let leftTileBound = findLeftViewBound()
        let rightTileBound = findRightViewBound()
        let upperTileBound = findUpperViewBound()
        let lowerTileBound = findLowerViewBound()
        
        tileBoundingBox = ACTileBoundingBox(left:leftTileBound.x, right:rightTileBound.x, up:upperTileBound.y, down:lowerTileBound.y)
        
        for rowIndex in lowerTileBound.y...upperTileBound.y
        {
            regenerateRowView(rowIndex, fade:false)
        }
    }
    
    func regenerateRowView(rowIndex:Int, fade:Bool)
    {
        let floorRowView = StandardTileRowView(rowIndex:rowIndex)
        floorRowView.position = CGPointMake(0, screenYForRow(rowIndex) + tileHeight/2)
        floorRowView.zPosition = 0
        
        // Obstacles appear 1/2 block higher than the floor
        let obstacleRowView = StandardTileRowView(rowIndex:rowIndex)
        obstacleRowView.position = CGPointMake(0, screenYForRow(rowIndex) + tileHeight)
        obstacleRowView.zPosition = 1000
        
        // Add tiles to the rowViews
        for colIndex in tileBoundingBox.left...tileBoundingBox.right
        {
            let tileCoordinate = DiscreteStandardCoord(x:colIndex, y:rowIndex)
            addTileToRowView(floorRowView, obstacleRowView:obstacleRowView, coord:tileCoordinate, fade:fade)
        }
        
        floorRows[rowIndex] = floorRowView
        self.addChild(floorRowView)
        
        obstacleRows[rowIndex] = obstacleRowView
        self.addChild(obstacleRowView)
    }
    
    func addTileToRowView(floorRowView:StandardTileRowView, obstacleRowView:StandardTileRowView, coord:DiscreteStandardCoord, fade:Bool)
    {
        if (tileMap.grid.isWithinBounds(coord.x, y:coord.y))
        {
            let tileNode = SKNode()
            let tileValue = tileMap.tileAt(coord)
            if (tileValue > 0 && tileValue < 3)
            {
                // Floor Tile
                let imageName = coinFlip() ? "floor1.png" : "floor3.png"
                let tileSprite = SKSpriteNode(imageNamed:imageName)
                tileSprite.resizeNode(tileWidth, y:tileHeight)
                tileSprite.position = CGPointMake(0, 0)
                
                let screenPosition = standardToScreen(coord)
                let x_pos = screenPosition.x + tileWidth/2
                tileNode.position = CGPointMake(x_pos, 0)
                tileNode.addChild(tileSprite)
                
                floorRowView.tiles[coord.x] = tileNode
                floorRowView.addChild(tileNode)
            }
            else
            {
                // Wall Tile
                let tileSprite = SKSpriteNode(imageNamed:"wall3d.png")
                tileSprite.resizeNode(tileWidth, y:tileHeight)
                tileSprite.position = CGPointMake(0, 0)
                
                if (!tileMap.grid.isWithinBounds(coord.x, y:coord.y-1) || tileMap.tileAt(coord.x, y:coord.y-1) < 3)
                {
                    let baseSprite = SKSpriteNode(imageNamed:"wall3d_base.png")
                    baseSprite.resizeNode(tileWidth, y:tileHeight/2)
                    baseSprite.position = CGPointMake(0, -0.75*tileHeight)
                    tileNode.addChild(baseSprite)
                }
                
                let screenPosition = standardToScreen(coord)
                let x_pos = screenPosition.x + tileWidth/2
                tileNode.position = CGPointMake(x_pos, 0)
                tileNode.addChild(tileSprite)
                
                obstacleRowView.tiles[coord.x] = tileNode
                obstacleRowView.addChild(tileNode)
            }
            
            if (fade)
            {
                tileNode.alpha = 0.0
                let fadeAction = fadeTo(tileNode, alpha:1.0, duration:CGFloat(0.5), type:CurveType.QUADRATIC_OUT)
                tileNode.runAction(fadeAction)
            }
        }
    }
    
    func moveMap(delta:CGPoint)
    {
        // Move all the tiles
        for (_, rowView) in floorRows
        {
            rowView.position.y += delta.y
            
            for (_, tile) in rowView.tiles
            {
                tile.position.x += delta.x
            }
        }
        
        for (_, rowView) in obstacleRows
        {
            rowView.position.y += delta.y
            
            for (_, tile) in rowView.tiles
            {
                tile.position.x += delta.x
            }
        }
        
        // Check for tiles outside of the view bounaries
        let lowerRow_screen_y = CGFloat(screenYForRow(tileBoundingBox.down))
        if (lowerRow_screen_y < bufferBounds.origin.y)
        {
            shiftUp()
        }

        let upperRow_screen_y = CGFloat(screenYForRow(tileBoundingBox.up))
        if (upperRow_screen_y > bufferBounds.origin.y + bufferBounds.size.height)
        {
            shiftDown()
        }

        let leftCol_screen_x = CGFloat(screenXForCol(tileBoundingBox.left))
        if (leftCol_screen_x < bufferBounds.origin.x)
        {
            shiftLeft()
        }
        
        let rightCol_screen_x = CGFloat(screenXForCol(tileBoundingBox.right))
        if (rightCol_screen_x > bufferBounds.origin.x + bufferBounds.size.width)
        {
            shiftRight()
        }
    }
    
    func shiftDown()
    {
        // Remove top row
        removeRow(tileBoundingBox.up)
        
        // Add bottom row
        addRow(tileBoundingBox.down-1)
        
        // Update tile bounds
        tileBoundingBox.down -= 1
        tileBoundingBox.up -= 1
    }
    
    func shiftUp()
    {
        // Remove bottom row
        removeRow(tileBoundingBox.down)
        
        // Add top row
        addRow(tileBoundingBox.up+1)
        
        // Update tile bounds
        tileBoundingBox.down += 1
        tileBoundingBox.up += 1
    }
    
    func shiftLeft()
    {
        removeCol(tileBoundingBox.left)
        addCol(tileBoundingBox.right+1)
        
        // Update staggered bounds
        tileBoundingBox.left += 1
        tileBoundingBox.right += 1
    }
    
    func shiftRight()
    {
        removeCol(tileBoundingBox.right)
        addCol(tileBoundingBox.left-1)
        
        // Update staggered bounds
        tileBoundingBox.left -= 1
        tileBoundingBox.right -= 1
    }
    
    func removeRow(rowIndex:Int)
    {
        if let rowView = floorRows[rowIndex]
        {
            let fadeAction = fadeTo(rowView, alpha:0.0, duration:CGFloat(0.4), type:CurveType.QUADRATIC_IN)
            
            rowView.runAction(fadeAction, completion: {() -> Void in
                
                rowView.removeFromParent()
                self.floorRows.removeValueForKey(rowIndex)
                
            })
        }
        
        if let rowView = obstacleRows[rowIndex]
        {
            let fadeAction = fadeTo(rowView, alpha:0.0, duration:CGFloat(0.4), type:CurveType.QUADRATIC_IN)
            
            rowView.runAction(fadeAction, completion: {() -> Void in
                
                rowView.removeFromParent()
                self.obstacleRows.removeValueForKey(rowIndex)
                
            })
        }
    }
    
    func addRow(rowIndex:Int)
    {
        regenerateRowView(rowIndex, fade:true)
    }
    
    func removeCol(colIndex:Int)
    {
        for (_, rowView) in floorRows
        {
            if let tile = rowView.tiles[colIndex]
            {
                let fadeAction = fadeTo(rowView, alpha:0.0, duration:CGFloat(0.4), type:CurveType.QUADRATIC_IN)
                
                tile.runAction(fadeAction, completion: {() -> Void in
                    
                    tile.removeFromParent()
                    rowView.tiles.removeValueForKey(colIndex)
                    
                })
            }
        }
        
        for (_, rowView) in obstacleRows
        {
            if let tile = rowView.tiles[colIndex]
            {
                let fadeAction = fadeTo(rowView, alpha:0.0, duration:CGFloat(0.4), type:CurveType.QUADRATIC_IN)
                
                tile.runAction(fadeAction, completion: {() -> Void in
                    
                    tile.removeFromParent()
                    rowView.tiles.removeValueForKey(colIndex)
                    
                })
            }
        }
    }
    
    func addCol(colIndex:Int)
    {
        for (rowIndex, floorRowView) in floorRows
        {
            let obstacleRowView = obstacleRows[rowIndex]!
            addTileToRowView(floorRowView, obstacleRowView:obstacleRowView, coord:DiscreteStandardCoord(x:colIndex, y:rowIndex), fade:true)
        }
    }
    
    func screenYForRow(row:Int) -> CGFloat
    {
        let arbitraryTileOnRow = DiscreteStandardCoord(x:0, y:row)
        let screenPosition = standardToScreen(arbitraryTileOnRow)
        
        return screenPosition.y
    }
    
    func screenXForCol(col:Int) -> CGFloat
    {
        let arbitraryTileInCol = DiscreteStandardCoord(x:col, y:0)
        let screenPosition = standardToScreen(arbitraryTileInCol)
        
        return screenPosition.x
    }
    
    func tileExceedsLeftBound(coord:DiscreteStandardCoord) -> Bool
    {
        return standardToScreen(coord).x < bufferBounds.origin.x
    }
    
    func tileExceedsRightBound(coord:DiscreteStandardCoord) -> Bool
    {
        return standardToScreen(coord).x + tileWidth > bufferBounds.origin.x + bufferBounds.size.width
    }
    
    func tileExceedsUpperBound(coord:DiscreteStandardCoord) -> Bool
    {
        return standardToScreen(coord).y + tileHeight > bufferBounds.origin.y + bufferBounds.size.height
    }
    
    func tileExceedsLowerBound(coord:DiscreteStandardCoord) -> Bool
    {
        return standardToScreen(coord).y < bufferBounds.origin.y
    }
    
    func findLeftViewBound() -> DiscreteStandardCoord
    {
        var leftTileBound = cameraPos.roundDown()
        
        while (!tileExceedsLeftBound(leftTileBound))
        {
            leftTileBound.x -= 1
        }
        
        leftTileBound.x += 1
        
        return leftTileBound
    }
    
    func findRightViewBound() -> DiscreteStandardCoord
    {
        var rightTileBound = cameraPos.roundDown()
        
        while (!tileExceedsRightBound(rightTileBound))
        {
            rightTileBound.x += 1
        }
        
        rightTileBound.x -= 1
        
        return rightTileBound
    }
    
    func findUpperViewBound() -> DiscreteStandardCoord
    {
        var upperTileBound = cameraPos.roundDown()
        
        while (!tileExceedsUpperBound(upperTileBound))
        {
            upperTileBound.y += 1
        }
        
        upperTileBound.y -= 1
        
        return upperTileBound
    }
    
    func findLowerViewBound() -> DiscreteStandardCoord
    {
        var lowerTileBound = cameraPos.roundDown()
        
        while (!tileExceedsLowerBound(lowerTileBound))
        {
            lowerTileBound.y -= 1
        }
        
        lowerTileBound.y += 1
        
        return lowerTileBound
    }
    
    // WARXING: UNPROVEN
    func standardToScreen(coord:StandardCoord) -> CGPoint
    {
        let standardDelta = coord - cameraPos
        
        let screen_x = CGFloat(standardDelta.x) * tileWidth
        let screen_y = CGFloat(standardDelta.y) * tileHeight
        
        return CGPointMake(screen_x, screen_y)
    }
    
    func standardToScreen(coord:DiscreteStandardCoord) -> CGPoint
    {
        return standardToScreen(coord.makePrecise())
    }
    
    func screenToStandard(coord:CGPoint) -> StandardCoord
    {
        let cameraScreenPos = CGPointMake(0, 0)
        let screenDelta = coord - cameraScreenPos
        
        let standard_x = Double(screenDelta.x) / Double(tileWidth)
        let standard_y = Double(screenDelta.y) / Double(tileHeight)
        
        return StandardCoord(x:standard_x, y:standard_y)
    }
}