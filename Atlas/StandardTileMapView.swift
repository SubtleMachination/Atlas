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
    
    var rows:[Int:StandardTileRowView]
    
    init(viewSize:CGSize, tileWidth:CGFloat, tileHeight:CGFloat)
    {
        //////////////////////////////////////////////////////////////////////////////////////////
        // Model
        //////////////////////////////////////////////////////////////////////////////////////////
        
        self.tileMap = StandardTileMap()
        self.cameraPos = StandardCoord(x:0.0, y:0.0)
        self.cameraVel = StandardCoord(x:0.02, y:0.01)
        
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
        
        self.rows = [Int:StandardTileRowView]()
        
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
        
    }
    
    func loadMap(dimensions:(x:Int, y:Int))
    {
        tileMap = StandardTileMap(x:dimensions.x, y:dimensions.y, filler:1)
        cameraPos = StandardCoord(x:Double(dimensions.x)/2, y:Double(dimensions.y)/2)
        
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
        
        tileBoundingBox = ACTileBoundingBox(left:leftTileBound.x, right:rightTileBound.x, up:upperTileBound.y, down:lowerTileBound.y)
        
        for rowIndex in lowerTileBound.y...upperTileBound.y
        {
            regenerateRowView(rowIndex)
        }
    }
    
    func regenerateRowView(rowIndex:Int)
    {
        let rowView = StandardTileRowView(rowIndex:rowIndex)
        rowView.position = CGPointMake(0, screenYForRow(rowIndex) + tileWidth/2)
        
        // Add tiles to the rowView
        for colIndex in tileBoundingBox.left...tileBoundingBox.right
        {
            addTileToRowView(rowView, coord:DiscreteStandardCoord(x:colIndex, y:rowIndex))
        }
        
        rows[rowIndex] = rowView
        self.addChild(rowView)
    }
    
    func addTileToRowView(rowView:StandardTileRowView, coord:DiscreteStandardCoord)
    {
        if (tileMap.grid.isWithinBounds(coord.x, y:coord.y))
        {
            let tileSprite = SKSpriteNode(imageNamed:"square.png")
            tileSprite.resizeNode(tileWidth, y:tileHeight)
            
            let screenPosition = standardToScreen(coord)
            let x_pos = screenPosition.x + tileWidth/2
            
            tileSprite.position = CGPointMake(x_pos, 0)
            tileSprite.color = randomColor()
            tileSprite.colorBlendFactor = 1.0
            
            rowView.tiles[coord.x] = tileSprite
            rowView.addChild(tileSprite)
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
        return standardToScreen(coord).y < bufferBounds.origin.x
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