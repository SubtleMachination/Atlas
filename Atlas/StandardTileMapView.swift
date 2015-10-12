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
    var viewportBounds:CGRect
    var tileViewBounds:ACTileBoundingBox
    
    var floorNode:SKNode
    var wallNode:SKNode
    
    var tileMap:StandardTileMap
    var cameraPos:StandardCoord
    var cameraVel:StandardCoord
    
    var tiles:[DiscreteStandardCoord:SKNode]
    var removedTiles:[DiscreteStandardCoord:SKNode]
    
    init(viewSize:CGSize, tileWidth:CGFloat, tileHeight:CGFloat)
    {
        //////////////////////////////////////////////////////////////////////////////////////////
        // Model
        //////////////////////////////////////////////////////////////////////////////////////////
        
        self.tileMap = StandardTileMap()
        self.cameraPos = StandardCoord(x:0.0, y:0.0)
        self.cameraVel = StandardCoord(x:0.00, y:0.00)
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // View
        //////////////////////////////////////////////////////////////////////////////////////////
        
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.viewportBounds = CGRectMake(-1*viewSize.width/2, -1*viewSize.height/2, viewSize.width, viewSize.height)
        
        self.floorNode = SKNode()
        self.wallNode = SKNode()
        wallNode.position = CGPointMake(0, 0)
        floorNode.position = CGPointMake(0, 0)
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // ViewModel
        //////////////////////////////////////////////////////////////////////////////////////////
        
        self.tiles = [DiscreteStandardCoord:SKNode]()
        self.removedTiles = [DiscreteStandardCoord:SKNode]()
        self.tileViewBounds = ACTileBoundingBox(left:0, right:0, up:0, down:0)
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // Superclass Initialization
        super.init()
        //////////////////////////////////////////////////////////////////////////////////////////
        
        self.addChild(floorNode)
        self.addChild(wallNode)
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // Map Loading
        //////////////////////////////////////////////////////////////////////////////////////////
        self.loadMap((x:30, y:30))
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // Debugging: to check viewport bounds
        //////////////////////////////////////////////////////////////////////////////////////////
        let crossHairThickness = CGFloat(2)
        
        let crossHairVerticalSprite = SKSpriteNode(imageNamed:"square.png")
        crossHairVerticalSprite.resizeNode(crossHairThickness, y:viewportBounds.size.height)
        crossHairVerticalSprite.position = CGPointMake(0, 0)
        crossHairVerticalSprite.zPosition = 1000
        crossHairVerticalSprite.alpha = 0.2
        
        self.addChild(crossHairVerticalSprite)
        
        let crossHairHorizontalSprite = SKSpriteNode(imageNamed:"square.png")
        crossHairHorizontalSprite.resizeNode(viewportBounds.size.width, y:crossHairThickness)
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
    
    func applyDragDelta(delta:CGPoint)
    {
        // Move the camera
        let standardDelta = screenDeltaToStandardDelta(delta)
        cameraPos -= standardDelta
        
        moveMap(delta)
    }
    
    func loadMap(dimensions:(x:Int, y:Int))
    {
        tileMap = StandardTileMap(x:dimensions.x, y:dimensions.y, filler:1)
        cameraPos = StandardCoord(x:Double(dimensions.x)/2, y:Double(dimensions.y)/2)
        
        updateTileViewBounds()
        
        removeAllTiles()
        regenerateTiles(false)
    }
    
    func removeAllTiles()
    {
        floorNode.removeAllChildren()
        wallNode.removeAllChildren()
        
        tiles.removeAll()
        removedTiles.removeAll()
    }
    
    func regenerateTiles(fadeIn:Bool)
    {
        for x in tileViewBounds.left...tileViewBounds.right
        {
            for y in tileViewBounds.down...tileViewBounds.up
            {
                let coord = DiscreteStandardCoord(x:x, y:y)
                
                if tiles[coord] == nil
                {
                    addTileToView(coord, fade:fadeIn)
                }
            }
        }
    }
    
    func degenerateTiles()
    {
        for (coord, tileNode) in tiles
        {
            if (!tileIsWithinViewBounds(coord))
            {
                removeTileFromView(coord, tile:tileNode)
            }
        }
    }
    
    func tileIsWithinViewBounds(coord:DiscreteStandardCoord) -> Bool
    {
        return tileIsWithinViewBounds(coord.x, y:coord.y)
    }
    
    func tileIsWithinViewBounds(x:Int, y:Int) -> Bool
    {
        return (x >= tileViewBounds.left && x <= tileViewBounds.right && y <= tileViewBounds.up && y >= tileViewBounds.down)
    }
    
    func addTileToView(coord:DiscreteStandardCoord, fade:Bool)
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
                
                let tilePosition = standardToScreen(coord)
                tileNode.position = CGPointMake(tilePosition.x + tileWidth/2, tilePosition.y + tileHeight/2)
                tileNode.addChild(tileSprite)
                
                tiles[coord] = tileNode
                floorNode.addChild(tileNode)
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
                
                let tilePosition = standardToScreen(coord)
                tileNode.position = CGPointMake(tilePosition.x + tileWidth/2, tilePosition.y + tileHeight)
                tileNode.addChild(tileSprite)
                
                tiles[coord] = tileNode
                wallNode.addChild(tileNode)
            }
            
            if (fade)
            {
                tileNode.alpha = 0.0
                let fadeAction = fadeTo(tileNode, alpha:1.0, duration:CGFloat(0.5), type:CurveType.QUADRATIC_OUT)
                tileNode.runAction(fadeAction)
            }
        }
    }
    
    func removeTileFromView(coord:DiscreteStandardCoord, tile:SKNode)
    {
        // Put tile in the "RemovedTile" buffer
        removedTiles[coord] = tile
        tiles.removeValueForKey(coord)
        
        let fadeAction = fadeTo(tile, alpha:0.0, duration:CGFloat(0.5), type:CurveType.QUADRATIC_IN)
        
        tile.runAction(fadeAction, completion: {() -> Void in
            
            tile.removeFromParent()
            self.removedTiles.removeValueForKey(coord)
        })
    }
    
    func updateTileViewBounds()
    {
        tileViewBounds.left = findLeftTileBound()
        tileViewBounds.right = findRightTileBound()
        tileViewBounds.up = findUpperTileBound()
        tileViewBounds.down = findLowerTileBound()
    }
    
    func findLeftTileBound() -> Int
    {
        var leftTileBound = cameraPos.roundDown().x
        
        while (screenXForCol(leftTileBound) + tileWidth > viewportBounds.origin.x)
        {
            leftTileBound -= 1
        }
        
        return leftTileBound+1
    }
    
    func findRightTileBound() -> Int
    {
        var rightTileBound = cameraPos.roundDown().x
        
        while (screenXForCol(rightTileBound) < viewportBounds.origin.x + viewportBounds.size.width)
        {
            rightTileBound += 1
        }
        
        return rightTileBound-1
    }
    
    func findUpperTileBound() -> Int
    {
        var upperTileBound = cameraPos.roundDown().y
        
        while (screenYForRow(upperTileBound) < viewportBounds.origin.y + viewportBounds.size.height)
        {
            upperTileBound += 1
        }
        
        return upperTileBound-1
    }
    
    func findLowerTileBound() -> Int
    {
        var lowerTileBound = cameraPos.roundDown().y
        
        while (screenYForRow(lowerTileBound) + tileHeight > viewportBounds.origin.y)
        {
            lowerTileBound -= 1
        }
        
        return lowerTileBound+1
    }
    
    
    func moveMap(delta:CGPoint)
    {
        // MOVE MAP
        for tileNode in floorNode.children
        {
            tileNode.position.x += delta.x
            tileNode.position.y += delta.y
        }
        
        for tileNode in wallNode.children
        {
            tileNode.position.x += delta.x
            tileNode.position.y += delta.y
        }
        
        updateTileViewBounds()
        
        // Remove out-of-bounds tiles
        degenerateTiles()
        
        // Regenerate in-bounds tiles
        regenerateTiles(true)
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
    
    func screenDeltaToStandardDelta(screenDelta:CGPoint) -> StandardCoord
    {
        let standard_x = Double(screenDelta.x) / Double(tileWidth)
        let standard_y = Double(screenDelta.y) / Double(tileHeight)
        
        return StandardCoord(x:standard_x, y:standard_y)
    }
}