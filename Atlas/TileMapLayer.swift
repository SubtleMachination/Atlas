//
//  StandardTileMapView.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/10/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import SpriteKit
import Foundation

public class TileMapLayer : SKNode, ACTickable
{
    var tileWidth:CGFloat
    var tileHeight:CGFloat
    var viewportBounds:CGRect
    var tileViewBounds:ACTileBoundingBox
    var flowViewBounds:ACTileBoundingBox
    
    var tileset:Tileset
    var tilesetAtlas:SKTextureAtlas
    let commonAtlas:SKTextureAtlas
    
    var floorNode:SKNode
    var wallNode:SKNode
    
    // The tileMap exists in the Model (this is just a POINTER to it)
    var tileMap:StandardTileMap
    var cameraPos:StandardCoord
    var cameraVel:StandardCoord
    
    var tiles:[DiscreteStandardCoord:SKNode]
    var removedTiles:[DiscreteStandardCoord:SKNode]
    var flowPoints:[DiscreteStaggeredCoord:SKNode]
    
    // The flow map exists only within the view
    var flowMap:StaggeredPointMap
    var showGrid:Bool
    var flowPointNode:SKNode
    
    init(viewSize:CGSize, tileWidth:CGFloat, tileHeight:CGFloat, tileMap:StandardTileMap)
    {
        //////////////////////////////////////////////////////////////////////////////////////////
        // Model
        //////////////////////////////////////////////////////////////////////////////////////////
        
        self.tileMap = tileMap
        self.cameraPos = StandardCoord(x:Double(tileMap.fetchDimensions().x), y:Double(tileMap.fetchDimensions().y))
        self.cameraVel = StandardCoord(x:0.00, y:0.00)
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // View
        //////////////////////////////////////////////////////////////////////////////////////////
        
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.viewportBounds = CGRectMake(-1*viewSize.width/2, -1*viewSize.height/2, viewSize.width, viewSize.height)
        
        self.showGrid = false
        self.flowPointNode = SKNode()
        flowPointNode.position = CGPointMake(0, 0)
        
        self.floorNode = SKNode()
        self.wallNode = SKNode()
        wallNode.position = CGPointMake(0, 0)
        floorNode.position = CGPointMake(0, 0)
        
        self.tileset = Tileset(plistName:nil)
        self.tilesetAtlas = SKTextureAtlas()
        self.commonAtlas = SKTextureAtlas(named:"Common")
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // ViewModel
        //////////////////////////////////////////////////////////////////////////////////////////
        
        self.tiles = [DiscreteStandardCoord:SKNode]()
        self.removedTiles = [DiscreteStandardCoord:SKNode]()
        self.flowPoints = [DiscreteStaggeredCoord:SKNode]()
        self.tileViewBounds = ACTileBoundingBox(left:0, right:0, up:0, down:0)
        self.flowViewBounds = ACTileBoundingBox(left:0, right:0, up:0, down:0)
        
        self.flowMap = StaggeredPointMap(xTileWidth:tileMap.fetchDimensions().x, yTileHeight:tileMap.fetchDimensions().y, filler:0)
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // Superclass Initialization
        super.init()
        //////////////////////////////////////////////////////////////////////////////////////////
        
        self.addChild(floorNode)
        self.addChild(wallNode)
        
        self.addChild(flowPointNode)
        
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
    
    func reloadMapWithNewTileset(tileset:Tileset)
    {
        self.tileset = tileset
        self.tilesetAtlas = SKTextureAtlas(named:self.tileset.atlas)

        reloadMap()
    }
    
    func changeTilesetAndRefresh(tileset:Tileset)
    {
        changeTileset(tileset)
        refreshVisuals()
    }
    
    func changeTileset(tileset:Tileset)
    {
        self.tileset = tileset
        self.tilesetAtlas = SKTextureAtlas(named:self.tileset.atlas)
    }
    
    func reloadMap()
    {
        // Defaults to the center of the map
        cameraPos = StandardCoord(x:Double(tileMap.fetchDimensions().x)/2, y:Double(tileMap.fetchDimensions().y)/2)
        
        refreshTiles()
        
        // Regenerate flow map from current tileMap
        flowMap = StaggeredPointMap(xTileWidth:tileMap.fetchDimensions().x, yTileHeight:tileMap.fetchDimensions().y, filler:0)
        recalculateFlows()
        refreshFlows()
    }
    
    func refreshVisuals()
    {
        refreshTiles()
        refreshFlows()
    }
    
    func recalculateFlows()
    {
        flowMap.fill(0)
        flowMap.computeSkeletonFromPathMap(tileMap.binaryPaths())
    }
    
    func refreshTiles()
    {
        updateTileViewBounds()
        
        removeAllTiles()
        regenerateTiles(false)
    }
    
    func refreshFlows()
    {
        updateFlowViewBounds()
        
        removeAllPoints()
        regeneratePoints()
    }
    
    func removeAllTiles()
    {
        floorNode.removeAllChildren()
        wallNode.removeAllChildren()
        
        tiles.removeAll()
        removedTiles.removeAll()
    }
    
    func removeAllPoints()
    {
        flowPointNode.removeAllChildren()
        
        flowPoints.removeAll()
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
                removeTileFromView(coord, tile:tileNode, fade:true)
            }
        }
    }
    
    func regeneratePoints()
    {
        for staggered_x in flowViewBounds.left...flowViewBounds.right
        {
            for staggered_y in flowViewBounds.down...flowViewBounds.up
            {
                if (flowMap.isWithinBounds(staggered_x, staggered_y:staggered_y))
                {
                    let type = flowMap.pointType(staggered_x, staggered_y:staggered_y)
                    
                    if (type != .INVALID)
                    {
                        let staggered_coord = DiscreteStaggeredCoord(x:staggered_x, y:staggered_y)
                        
                        if (flowMap.tileAt(staggered_coord)! > 0)
                        {
                            if flowPoints[staggered_coord] == nil
                            {
                                addPointToView(staggered_coord)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func degeneratePoints()
    {
        for (coord, pointNode) in flowPoints
        {
            if (!viewportBounds.contains(pointNode.position))
            {
                removePointFromView(coord, point:pointNode)
            }
        }
    }
    
    func changeTileAtScreenPos(pos:CGPoint, value:Int)
    {
        let tilePos = screenToStandard(pos).roundDown()
        
        if (tileMap.isWithinBounds(tilePos))
        {
            // Check old model
            let wasWall = tileIsObstacle(tilePos)
            
            // Update the model
            tileMap.setTileAt(tilePos, value:value)
            
            // Update the viewmodel
            if let tileSprite = tiles[tilePos]
            {
                let tileValue = tileMap.tileAt(tilePos)!
                removeTileFromView(tilePos, tile:tileSprite, fade:false)
                let tileAbove = DiscreteStandardCoord(x:tilePos.x, y:tilePos.y+1)
                if ((wasWall || tileValue == 0) && tileIsObstacle(tileAbove))
                {
                    refreshTileAt(tileAbove)
                }
            }
            addTileToView(tilePos, fade:false)
        }
    }
    
    func refreshTileAt(coord:DiscreteStandardCoord)
    {
        if (tileMap.isWithinBounds(coord))
        {
            if let tileSprite = tiles[coord]
            {
                removeTileFromView(coord, tile:tileSprite, fade:false)
            }
            addTileToView(coord, fade:false)
        }
    }
    
    func tileIsObstacle(coord:DiscreteStandardCoord) -> Bool
    {
        if (tileMap.isWithinBounds(coord))
        {
            if let tileData = tileset.tiles[tileMap.tileAt(coord)!]
            {
                return tileData.wall
            }
            else
            {
                return true // Treat unknown tiles as walls
            }
        }
        else
        {
            return true // Treat out of bound tiles as walls
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
    
    func pointIsWithinViewBounds(coord:DiscreteStaggeredCoord) -> Bool
    {
        return tileIsWithinViewBounds(coord.x, y:coord.y)
    }
    
    func pointIsWithinViewBounds(x:Int, y:Int) -> Bool
    {
        return (x >= flowViewBounds.left && x <= flowViewBounds.right && y <= flowViewBounds.up && y >= flowViewBounds.down)
    }
    
    func addTileToView(coord:DiscreteStandardCoord, fade:Bool)
    {
        if (tileMap.isWithinBounds(coord.x, y:coord.y))
        {
            let tileNode = SKNode()
            let tileValue = tileMap.tileAt(coord)!
            
            // Is the tileValue in the tileset?
            if (tileValue == 0)
            {
                let voidSprite = SKSpriteNode(imageNamed:"square.png")
                voidSprite.resizeNode(tileWidth, y:tileHeight)
                voidSprite.position = CGPointMake(0, 0)
                voidSprite.color = NSColor(red:0.1, green:0.1, blue:0.1, alpha:1.0)
                voidSprite.colorBlendFactor = 1.0
                
                let tilePosition = standardToScreen(coord)
                tileNode.position = CGPointMake(tilePosition.x + tileWidth/2, tilePosition.y + tileHeight/2)
                tileNode.addChild(voidSprite)
                
                tiles[coord] = tileNode
                floorNode.addChild(tileNode)
            }
            else if let spriteOptions = tileset.tiles[tileValue]
            {
                if (spriteOptions.wall)
                {
                    // Wall Tile
                    let tileSourceSpriteNames = tileset.tiles[tileValue]!.tile
                    let tileSprite = SKSpriteNode(texture:tilesetAtlas.textureNamed(tileSourceSpriteNames.randomElement()))
                    tileSprite.resizeNode(tileWidth, y:tileHeight)
                    tileSprite.position = CGPointMake(0, 0)
                    
                    if (shouldPlaceWallBase(coord))
                    {
                        let baseSourceSpriteNames = tileset.tiles[tileValue]!.base
                        let baseSprite = SKSpriteNode(texture:tilesetAtlas.textureNamed(baseSourceSpriteNames.randomElement()))
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
                else
                {
                    // Floor Tile
                    let tileSourceSpriteNames = tileset.tiles[tileValue]!.tile
                    let tileSprite = SKSpriteNode(texture:tilesetAtlas.textureNamed(tileSourceSpriteNames.randomElement()))
                    tileSprite.resizeNode(tileWidth, y:tileHeight)
                    tileSprite.position = CGPointMake(0, 0)
                    
                    let tilePosition = standardToScreen(coord)
                    tileNode.position = CGPointMake(tilePosition.x + tileWidth/2, tilePosition.y + tileHeight/2)
                    tileNode.addChild(tileSprite)
                    
                    tiles[coord] = tileNode
                    floorNode.addChild(tileNode)
                }
            }
            else
            {
                // No tileset options defined for this value (substitute with a PLACEHOLDER TILE)
                let tileSprite = SKSpriteNode(imageNamed:"square.png")
                tileSprite.color = NSColor.whiteColor()
                tileSprite.colorBlendFactor = 1.0
                tileSprite.resizeNode(tileWidth, y:tileHeight)
                tileSprite.position = CGPointMake(0, 0)
                
                let tilePosition = standardToScreen(coord)
                tileNode.position = CGPointMake(tilePosition.x + tileWidth/2, tilePosition.y + tileHeight/2)
                tileNode.addChild(tileSprite)
                
                tiles[coord] = tileNode
                floorNode.addChild(tileNode)
            }
            
            if (fade)
            {
                tileNode.alpha = 0.0
                let fadeAction = fadeTo(tileNode, alpha:1.0, duration:CGFloat(0.5), type:CurveType.QUADRATIC_OUT)
                tileNode.runAction(fadeAction)
            }
        }
    }
    
    func addPointToView(coord:DiscreteStaggeredCoord)
    {
        if (flowMap.isWithinBounds(coord))
        {
            let strength = flowMap.tileAt(coord)!
            
            if (strength > 0)
            {
                let size = CGFloat((strength + 1) * 2)
                
                let pointSprite = SKSpriteNode(texture:commonAtlas.textureNamed("diamond_small"))
                
                pointSprite.resizeNode(size, y:size)
                pointSprite.position = staggeredToScreen(coord)
                
                flowPoints[coord] = pointSprite
                
                flowPointNode.addChild(pointSprite)
            }
            
        }
    }
    
    func shouldPlaceWallBase(coord:DiscreteStandardCoord) -> Bool
    {
        let tileBelowIsWithinBounds = tileMap.isWithinBounds(coord.x, y:coord.y-1)
        
        if (tileBelowIsWithinBounds)
        {
            // If there is NOT a wall directly below this tile
            let tileValueBelow = tileMap.tileAt(coord.x, y:coord.y-1)!
            if let tileInfo = tileset.tiles[tileValueBelow]
            {
                if (tileValueBelow == 0 || !tileInfo.wall)
                {
                    return true
                }
            }
            else
            {
                return true
            }
            
            return false
        }
        else
        {
            return true
        }
    }
    
    func removeTileFromView(coord:DiscreteStandardCoord, tile:SKNode, fade:Bool)
    {
        if (fade)
        {
            // Put tile in the "RemovedTile" buffer
            removedTiles[coord] = tile
            tiles.removeValueForKey(coord)
            
            let fadeAction = fadeTo(tile, alpha:0.0, duration:CGFloat(0.25), type:CurveType.QUADRATIC_IN)
            
            tile.runAction(fadeAction, completion: {() -> Void in
                
                tile.removeFromParent()
                self.removedTiles.removeValueForKey(coord)
            })
        }
        else
        {
            tile.removeFromParent()
            tiles.removeValueForKey(coord)
        }
    }
    
    func removePointFromView(coord:DiscreteStaggeredCoord, point:SKNode)
    {
        point.removeFromParent()
        flowPoints.removeValueForKey(coord)
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
    
    func updateFlowViewBounds()
    {
        flowViewBounds.left = findLeftFlowBound()
        flowViewBounds.right = findRightFlowBound()
        flowViewBounds.up = findUpperFlowBound()
        flowViewBounds.down = findLowerFlowBound()
    }
    
    func findLeftFlowBound() -> Int
    {
        var leftFlowBound = standardToStaggered(cameraPos).roundDown().x
        
        while (screenXForStaggeredCol(leftFlowBound) > viewportBounds.origin.x)
        {
            leftFlowBound -= 1
        }
        
        return leftFlowBound+1
    }
    
    func findRightFlowBound() -> Int
    {
        var rightFlowBound = standardToStaggered(cameraPos).roundDown().x
        
        while (screenXForStaggeredCol(rightFlowBound) < viewportBounds.origin.x + viewportBounds.size.width)
        {
            rightFlowBound += 1
        }
        
        return rightFlowBound-1
    }
    
    func findUpperFlowBound() -> Int
    {
        var upperFlowBound = standardToStaggered(cameraPos).roundDown().y
        
        while (screenYForStaggeredRow(upperFlowBound) < viewportBounds.origin.y + viewportBounds.size.height)
        {
            upperFlowBound += 1
        }
        
        return upperFlowBound-1
    }
    
    func findLowerFlowBound() -> Int
    {
        var lowerFlowBound = standardToStaggered(cameraPos).roundDown().y
        
        while (screenYForStaggeredRow(lowerFlowBound) > viewportBounds.origin.y)
        {
            lowerFlowBound -= 1
        }
        
        return lowerFlowBound+1
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
        
        for pointNode in flowPointNode.children
        {
            pointNode.position.x += delta.x
            pointNode.position.y += delta.y
        }
        
        updateTileViewBounds()
        
        // Remove out-of-bounds tiles
        degenerateTiles()

        // Regenerate in-bounds tiles
        regenerateTiles(true)
        
        
        updateFlowViewBounds()
        
        // Remove out-of-bounds points
        degeneratePoints()
        
        // Regenerate in-bounds points
        regeneratePoints()
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
    
    func screenYForStaggeredRow(row:Int) -> CGFloat
    {
        let arbitraryPointInRow = DiscreteStaggeredCoord(x:0, y:row)
        let screenPosition = staggeredToScreen(arbitraryPointInRow)
        
        return screenPosition.y
    }
    
    func screenXForStaggeredCol(col:Int) -> CGFloat
    {
        let arbitraryPointInCol = DiscreteStaggeredCoord(x:col, y:0)
        let screenPositon = staggeredToScreen(arbitraryPointInCol)
        
        return screenPositon.x
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
        
        let standard_x = (Double(screenDelta.x) / Double(tileWidth)) + cameraPos.x
        let standard_y = (Double(screenDelta.y) / Double(tileHeight)) + cameraPos.y
        
        return StandardCoord(x:standard_x, y:standard_y)
    }
    
    func screenDeltaToStandardDelta(screenDelta:CGPoint) -> StandardCoord
    {
        let standard_x = Double(screenDelta.x) / Double(tileWidth)
        let standard_y = Double(screenDelta.y) / Double(tileHeight)
        
        return StandardCoord(x:standard_x, y:standard_y)
    }
    
    
    
    func staggeredToStandard(coord:StaggeredCoord) -> StandardCoord
    {
        let standard_x = coord.x / 2
        let standard_y = coord.y / 2
        
        return StandardCoord(x:standard_x, y:standard_y)
    }
    
    func standardToStaggered(coord:StandardCoord) -> StaggeredCoord
    {
        let staggered_x = coord.x * 2
        let staggered_y = coord.y * 2
        
        return StaggeredCoord(x:staggered_x, y:staggered_y)
    }
    
    func staggeredToScreen(coord:DiscreteStaggeredCoord) -> CGPoint
    {
        return staggeredToScreen(coord.makePrecise())
    }
    
    func staggeredToScreen(coord:StaggeredCoord) -> CGPoint
    {
        let standardPosition = staggeredToStandard(coord)
        return standardToScreen(standardPosition)
    }
}