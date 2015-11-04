//
//  StaggeredPointMap.swift
//  Atlas
//
//  Created by Dusty Artifact on 11/2/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation

////////////////////////////////////////////////////////////////////////////////
// StaggeredPointMap
////////////////////////////////////////////////////////////////////////////////

public class StaggeredPointMap
{
    var cornerGrid:Matrix2D<Int>
    var midpointGrid:Matrix2D<Int>
    
    // "Default" map
    convenience init()
    {
        self.init(xTileWidth:5, yTileHeight:5, filler:0)
    }
    
    init(xTileWidth:Int, yTileHeight:Int, filler:Int)
    {
        cornerGrid = Matrix2D<Int>(xMax:xTileWidth+1, yMax:yTileHeight+1, filler:filler)
        midpointGrid = Matrix2D<Int>(xMax:xTileWidth, yMax:yTileHeight, filler:filler)
    }
    
    func isWithinBounds(coord:DiscreteStaggeredCoord) -> Bool
    {
        let specificCoord = generalToSpecific(coord)
        
        var withinBounds = false
        
        if (specificCoord.corner)
        {
            withinBounds = cornerGrid.isWithinBounds(specificCoord.x, y:specificCoord.y)
        }
        else
        {
            withinBounds = midpointGrid.isWithinBounds(specificCoord.x, y: specificCoord.y)
        }
        
        return withinBounds
    }
    
    func isWithinBounds(staggered_x:Int, staggered_y:Int) -> Bool
    {
        return isWithinBounds(DiscreteStaggeredCoord(x:staggered_x, y:staggered_y))
    }
    
    func tileAt(coord:DiscreteStaggeredCoord) -> Int?
    {
        return tileAt(coord.x, staggered_y:coord.y)
    }
    
    func tileAt(staggered_x:Int, staggered_y:Int) -> Int?
    {
        let specifics = generalToSpecific(staggered_x, staggered_y:staggered_y)
        
        if (specifics.corner)
        {
            if (cornerGrid.isWithinBounds(specifics.x, y:specifics.y))
            {
                return cornerGrid[specifics.x, specifics.y]
            }
        }
        else
        {
            if (midpointGrid.isWithinBounds(specifics.x, y:specifics.y))
            {
                return midpointGrid[specifics.x, specifics.y]
            }
        }
        
        return nil
    }
    
    func setTileAt(coord:DiscreteStaggeredCoord, value:Int)
    {
        setTileAt(coord.x, staggered_y:coord.y, value:value)
    }
    
    func setTileAt(staggered_x:Int, staggered_y:Int, value:Int)
    {
        let specifics = generalToSpecific(staggered_x, staggered_y:staggered_y)
        
        if (specifics.corner)
        {
            if (cornerGrid.isWithinBounds(specifics.x, y:specifics.y))
            {
                cornerGrid[specifics.x, specifics.y] = value
            }
        }
        else
        {
            if (midpointGrid.isWithinBounds(specifics.x, y:specifics.y))
            {
                midpointGrid[specifics.x, specifics.y] = value
            }
        }
    }
    
    func generalToSpecific(coord:DiscreteStaggeredCoord) -> (x:Int, y:Int, corner:Bool)
    {
        return generalToSpecific(coord.x, staggered_y:coord.y)
    }
    
    func generalToSpecific(staggered_x:Int, staggered_y:Int) -> (x:Int, y:Int, corner:Bool)
    {
        let corner = (staggered_y % 2 == 0) ? true : false
        
        let temp_x = (corner) ? staggered_x : staggered_x - 1
        let temp_y = (corner) ? staggered_y : staggered_y - 1
        
        let x = Int(Double(temp_x) / 2)
        let y = Int(Double(temp_y) / 2)
        
        return (x:x, y:y, corner:corner)
    }
    
    func computeSkeletonFromPathMap(pathMap:Matrix2D<Bool>)
    {
        let staggered_x_max = (cornerGrid.xMax - 1)*2
        let staggered_y_max = (cornerGrid.yMax - 1)*2
        
        for staggered_x in 0..<staggered_x_max
        {
            for staggered_y in 0..<staggered_y_max
            {
                let staggeredCenter = DiscreteStaggeredCoord(x:staggered_x, y:staggered_y)
                
                let specifics = generalToSpecific(staggeredCenter)
                
                if (staggeredCenter.x == 7 && staggeredCenter.y == 7)
                {
                    print("derp")
                }
                
                if (!specifics.corner)
                {
                    if (pathMap[specifics.x, specifics.y])
                    {
                        // Mid Cases
                        let criticalInfo = midPointIsCritical(pathMap, midPoint:staggeredCenter)
                        if (criticalInfo.isCritical)
                        {
                            setMidPointAsCritical(staggeredCenter, radius:criticalInfo.radius)
                        }
                    }
                }
//                else if (!x_even && !y_even)
//                {
//                    // Corner Case
//                }
            }
        }
    }
    
    func setMidPointAsCritical(midPoint:DiscreteStaggeredCoord, radius:Int)
    {
        let specifics = generalToSpecific(midPoint)
        midpointGrid[specifics.x, specifics.y] = radius
    }
    
    func midPointIsCritical(pathMap:Matrix2D<Bool>, midPoint:DiscreteStaggeredCoord) -> (isCritical:Bool, radius:Int)
    {
        var isCritical = false
        var decisionReached = false
        var radius = 1
        
        while (!decisionReached)
        {
            // Start at radius 1 and keep increasing
            let returnValue = sidesSurrounded(pathMap, staggeredCenter:midPoint, radius:radius)
            
            if (returnValue == 0)
            {
                radius++
            }
            else if (returnValue == 1)
            {
                isCritical = true
                decisionReached = true
            }
            else if (returnValue == 2)
            {
                isCritical = false
                decisionReached = true
            }
        }
        
        return (isCritical:isCritical, radius:radius)
    }
    
    // 0: keep expanding, 1: critical point found, 2: cancel
    func sidesSurrounded(pathMap:Matrix2D<Bool>, staggeredCenter:DiscreteStaggeredCoord, radius:Int) -> Int
    {
        var leftBounded = false
        var rightBounded = false
        var upperBounded = false
        var lowerBounded = false
        
        let tileCenter_x = Int(Double(staggeredCenter.x - 1) / 2)
        let tileCenter_y = Int(Double(staggeredCenter.y - 1) / 2)
        let tileCenter = DiscreteStandardCoord(x:tileCenter_x, y:tileCenter_y)
        
        // Check the diagonals
        let upperLeft = DiscreteStandardCoord(x:tileCenter.x - radius, y:tileCenter.y + radius)
        let upperRight = DiscreteStandardCoord(x:tileCenter.x + radius, y:tileCenter.y + radius)
        let lowerRight = DiscreteStandardCoord(x:tileCenter.x + radius, y:tileCenter.y - radius)
        let lowerLeft = DiscreteStandardCoord(x:tileCenter.x - radius, y:tileCenter.y - radius)
        
        let upperLeftBounded = (!pathMap.isWithinBounds(upperLeft.x, y:upperLeft.y) || !pathMap[upperLeft.x, upperLeft.y])
        let upperRightBounded = (!pathMap.isWithinBounds(upperRight.x, y:upperRight.y) || !pathMap[upperRight.x, upperRight.y])
        let lowerRightBounded = (!pathMap.isWithinBounds(lowerRight.x, y:lowerRight.y) || !pathMap[lowerRight.x, lowerRight.y])
        let lowerLeftBounded = (!pathMap.isWithinBounds(lowerLeft.x, y:lowerLeft.y) || !pathMap[lowerLeft.x, lowerLeft.y])
        
        var cornerBoundCount = 0
        
        if (upperLeftBounded) { cornerBoundCount++ }
        if (upperRightBounded) { cornerBoundCount++ }
        if (lowerRightBounded) { cornerBoundCount++ }
        if (lowerLeftBounded) { cornerBoundCount++ }
        
        // Check all the elements of the left bound
        for y in (tileCenter.y - (radius-1))...(tileCenter.y + (radius-1))
        {
            if (!pathMap.isWithinBounds(tileCenter.x - radius, y:y) || !pathMap[tileCenter.x - radius, y])
            {
                leftBounded = true
                break
            }
        }
        
        // Check all the elements of the right bound
        for y in (tileCenter.y - (radius-1))...(tileCenter.y + (radius-1))
        {
            if (!pathMap.isWithinBounds(tileCenter.x + radius, y:y) || !pathMap[tileCenter.x + radius, y])
            {
                rightBounded = true
                break
            }
        }
        
        // Check all the elements of the upper bound
        for x in (tileCenter.x - (radius-1))...(tileCenter.x + (radius-1))
        {
            if (!pathMap.isWithinBounds(x, y:tileCenter.y + radius) || !pathMap[x, tileCenter.y + radius])
            {
                upperBounded = true
                break
            }
        }
        
        // Check all the elements of the lower bound
        for x in (tileCenter.x - (radius-1))...(tileCenter.x + (radius-1))
        {
            if (!pathMap.isWithinBounds(x, y:tileCenter.y - radius) || !pathMap[x, tileCenter.y - radius])
            {
                lowerBounded = true
                break
            }
        }
        
        var sideBoundCount = 0
        
        if (upperBounded) { sideBoundCount++ }
        if (lowerBounded) { sideBoundCount++ }
        if (leftBounded) { sideBoundCount++ }
        if (rightBounded) { sideBoundCount++ }
        
        let info = ACTileSurround(left:leftBounded, right:rightBounded, up:upperBounded, down:lowerBounded, upperLeft:upperLeftBounded, upperRight:upperRightBounded, lowerRight:lowerRightBounded, lowerLeft:lowerLeftBounded, sides:sideBoundCount, corners:cornerBoundCount)
        
        var returnValue = 0
        
        if (info.corners == 0 && info.sides == 0)
        {
            // Keep expanding
            returnValue = 0
        }
        else if (info.corners == 4 || info.sides > 2)
        {
            // Critical point
            returnValue = 1
        }
        else if (info.oppositeCorners() && info.sidesBetweenCorners() < info.sides)
        {
            // Critical point
            returnValue = 1
        }
        else if (info.oppositeSides())
        {
            // Critical point
            returnValue = 1
        }
        else
        {
            // Cancel
            returnValue = 2
        }
        
        return returnValue
    }
}