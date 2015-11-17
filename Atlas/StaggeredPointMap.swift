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

enum PointType
{
    case MID, CORNER, INVALID
}

public class StaggeredPointMap
{
    var grid:Matrix2D<Int>
    
    // "Default" map
    convenience init()
    {
        self.init(xTileWidth:5, yTileHeight:5, filler:0)
    }
    
    init(xTileWidth:Int, yTileHeight:Int, filler:Int)
    {
        grid = Matrix2D<Int>(xMax:(xTileWidth*2)+1, yMax:(yTileHeight*2)+1, filler:filler)
    }
    
    func fill(value:Int)
    {
        for x in 0..<grid.xMax
        {
            for y in 0..<grid.yMax
            {
                grid[x,y] = value
            }
        }
    }
    
    // Checks whether the staggered coord is within bounds (also must be valid -- both even or both odd)
    func isWithinBounds(coord:DiscreteStaggeredCoord) -> Bool
    {
        let type = pointType(coord)
        
        return grid.isWithinBounds(coord.x, y:coord.y) && type != .INVALID
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
        if (grid.isWithinBounds(staggered_x, y:staggered_y))
        {
            return grid[staggered_x, staggered_y]
        }
        
        return nil
    }
    
    func setTileAt(coord:DiscreteStaggeredCoord, value:Int)
    {
        setTileAt(coord.x, staggered_y:coord.y, value:value)
    }
    
    func setTileAt(staggered_x:Int, staggered_y:Int, value:Int)
    {
        if (grid.isWithinBounds(staggered_x, y:staggered_y))
        {
            grid[staggered_x, staggered_y] = value
        }
    }
    
    func computeSkeletonFromPathMap(pathMap:Matrix2D<Bool>)
    {
        for staggered_x in 0..<grid.xMax
        {
            for staggered_y in 0..<grid.yMax
            {
                let staggeredCenter = DiscreteStaggeredCoord(x:staggered_x, y:staggered_y)
            
                let criticalInfo = pointInfo(pathMap, point:staggeredCenter)
                if (criticalInfo.isCritical)
                {
                    setPointAsCritical(staggeredCenter, radius:criticalInfo.radius)
                }
            }
        }
    }
    
    func setPointAsCritical(point:DiscreteStaggeredCoord, radius:Int)
    {
        if (grid.isWithinBounds(point.x, y:point.y))
        {
            grid[point.x, point.y] = radius
        }
    }
    
    func pointInfo(pathMap:Matrix2D<Bool>, point:DiscreteStaggeredCoord) -> (isCritical:Bool, radius:Int)
    {
        let type = pointType(point)
        var shouldCheck = false
        
        // Preprocessing (should we even check this point?)
        if (type == .MID)
        {
            // Convert to tile position
            let tile_x = Int(Double(point.x - 1) / 2)
            let tile_y = Int(Double(point.y - 1) / 2)
            if (pathMap[tile_x, tile_y])
            {
                shouldCheck = true
            }
        }
        else if (type == .CORNER)
        {
            let tileCenter_x = Int(Double(point.x) / 2)
            let tileCenter_y = Int(Double(point.y) / 2)
            let upperRight = DiscreteStandardCoord(x:tileCenter_x, y:tileCenter_y)
            let upperLeft = DiscreteStandardCoord(x:upperRight.x - 1, y:upperRight.y)
            let lowerLeft = DiscreteStandardCoord(x:upperRight.x - 1, y:upperRight.y - 1)
            let lowerRight = DiscreteStandardCoord(x:upperRight.x, y:upperRight.y - 1)
            
            let ur_path = isPathableWithinBounds(pathMap, coord:upperRight)
            let ul_path = isPathableWithinBounds(pathMap, coord:upperLeft)
            let ll_path = isPathableWithinBounds(pathMap, coord:lowerLeft)
            let lr_path = isPathableWithinBounds(pathMap, coord:lowerRight)
            
            if (ur_path && ul_path && ll_path && lr_path)
            {
                shouldCheck = true
            }
        }
        
        if (shouldCheck)
        {
            var isCritical = false
            var radius = 1
            
            var decisionReached = false
            
            while (!decisionReached)
            {
                // Start at radius 1 and keep increasing
                let status = criticalStatus(pathMap, staggeredCenter:point, radius:radius)
                
                if (status == 0)
                {
                    radius++
                }
                else if (status == 1)
                {
                    isCritical = true
                    decisionReached = true
                }
                else if (status == 2)
                {
                    isCritical = false
                    decisionReached = true
                }
            }
            
            return (isCritical:isCritical, radius:radius)
        }
        else
        {
            return (isCritical:false, radius:0)
        }
    }
    
    func surroundInfoForCorner(pathMap:Matrix2D<Bool>, staggeredCorner:DiscreteStaggeredCoord, radius:Int) -> ACTileSurround
    {
        var leftBounded = false
        var rightBounded = false
        var upperBounded = false
        var lowerBounded = false
        
        let tileCenter_x = Int(Double(staggeredCorner.x) / 2)
        let tileCenter_y = Int(Double(staggeredCorner.y) / 2)
        let upperRight = DiscreteStandardCoord(x:tileCenter_x + radius-1, y:tileCenter_y + radius-1)
        let sideDelta = (2*radius) - 1
        
        // Check the diagonals
        let upperLeft = DiscreteStandardCoord(x:upperRight.x - sideDelta, y:upperRight.y)
        let lowerRight = DiscreteStandardCoord(x:upperRight.x, y:upperRight.y - sideDelta)
        let lowerLeft = DiscreteStandardCoord(x:upperRight.x - sideDelta, y:upperRight.y - sideDelta)
        
        let upperLeftBounded = (!pathMap.isWithinBounds(upperLeft.x, y:upperLeft.y) || !pathMap[upperLeft.x, upperLeft.y])
        let upperRightBounded = (!pathMap.isWithinBounds(upperRight.x, y:upperRight.y) || !pathMap[upperRight.x, upperRight.y])
        let lowerRightBounded = (!pathMap.isWithinBounds(lowerRight.x, y:lowerRight.y) || !pathMap[lowerRight.x, lowerRight.y])
        let lowerLeftBounded = (!pathMap.isWithinBounds(lowerLeft.x, y:lowerLeft.y) || !pathMap[lowerLeft.x, lowerLeft.y])
        
        var cornerBoundCount = 0
        
        if (upperLeftBounded) { cornerBoundCount++ }
        if (upperRightBounded) { cornerBoundCount++ }
        if (lowerRightBounded) { cornerBoundCount++ }
        if (lowerLeftBounded) { cornerBoundCount++ }
        
        if (radius > 1)
        {
            // Check all the elements of the left bound
            for y in (lowerLeft.y + 1)...(upperLeft.y - 1)
            {
                if (!pathMap.isWithinBounds(lowerLeft.x, y:y) || !pathMap[lowerLeft.x, y])
                {
                    leftBounded = true
                    break
                }
            }
            
            // Check all the elements of the right bound
            for y in (lowerRight.y + 1)...(upperRight.y - 1)
            {
                if (!pathMap.isWithinBounds(lowerRight.x, y:y) || !pathMap[lowerRight.x, y])
                {
                    rightBounded = true
                    break
                }
            }
            
            // Check all the elements of the upper bound
            for x in (upperLeft.x + 1)...(upperRight.x - 1)
            {
                if (!pathMap.isWithinBounds(x, y:upperLeft.y) || !pathMap[x, upperLeft.y])
                {
                    upperBounded = true
                    break
                }
            }
            
            // Check all the elements of the upper bound
            for x in (lowerLeft.x + 1)...(lowerRight.x - 1)
            {
                if (!pathMap.isWithinBounds(x, y:lowerLeft.y) || !pathMap[x, lowerLeft.y])
                {
                    lowerBounded = true
                    break
                }
            }
        }
        
        var sideBoundCount = 0
        
        if (upperBounded) { sideBoundCount++ }
        if (lowerBounded) { sideBoundCount++ }
        if (leftBounded) { sideBoundCount++ }
        if (rightBounded) { sideBoundCount++ }
        
        return ACTileSurround(left:leftBounded, right:rightBounded, up:upperBounded, down:lowerBounded, upperLeft:upperLeftBounded, upperRight:upperRightBounded, lowerRight:lowerRightBounded, lowerLeft:lowerLeftBounded, sides:sideBoundCount, corners:cornerBoundCount)
    }
    
    func surroundInfoForMidpoint(pathMap:Matrix2D<Bool>, staggeredMidpoint:DiscreteStaggeredCoord, radius:Int) -> ACTileSurround
    {
        var leftBounded = false
        var rightBounded = false
        var upperBounded = false
        var lowerBounded = false
        
        let tileCenter_x = Int(Double(staggeredMidpoint.x - 1) / 2)
        let tileCenter_y = Int(Double(staggeredMidpoint.y - 1) / 2)
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
        
        return ACTileSurround(left:leftBounded, right:rightBounded, up:upperBounded, down:lowerBounded, upperLeft:upperLeftBounded, upperRight:upperRightBounded, lowerRight:lowerRightBounded, lowerLeft:lowerLeftBounded, sides:sideBoundCount, corners:cornerBoundCount)
    }
    
    // 0: keep expanding, 1: critical point found, 2: cancel
    func criticalStatus(pathMap:Matrix2D<Bool>, staggeredCenter:DiscreteStaggeredCoord, radius:Int) -> Int
    {
        let type = pointType(staggeredCenter)
        
        var info:ACTileSurround
        
        if (type == .CORNER)
        {
            info = surroundInfoForCorner(pathMap, staggeredCorner:staggeredCenter, radius:radius)
            return returnValueForInfo(info)
        }
        else if (type == .MID)
        {
            info = surroundInfoForMidpoint(pathMap, staggeredMidpoint:staggeredCenter, radius:radius)
            return returnValueForInfo(info)
        }
        else
        {
            return 2
        }
    }
    
    func returnValueForInfo(info:ACTileSurround) -> Int
    {
        var returnValue = 0
        
        if (info.corners == 0 && info.sides == 0)
        {
            // Keep expanding
            returnValue = 0
        }
        else if (info.hasEmptyCornerWithOccupiedSide())
        {
            // Critical point
            returnValue = 1
        }
        else if (info.corners == 4 || info.sides > 2)
        {
            // Critical point
            returnValue = 1
        }
//        else if (info.oppositeCorners() && info.sidesBetweenCorners() < info.sides)
//        {
//            // Critical point
//            returnValue = 1
//        }
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
    
    func pointType(point:DiscreteStaggeredCoord) -> PointType
    {
        return pointType(point.x, staggered_y:point.y)
    }
    
    func pointType(staggered_x:Int, staggered_y:Int) -> PointType
    {
        let even_x = staggered_x % 2 == 0
        let even_y = staggered_y % 2 == 0
        
        if (even_x && even_y)
        {
            return PointType.CORNER
        }
        else if (!even_x && !even_y)
        {
            return PointType.MID
        }
        else
        {
            return PointType.INVALID
        }
    }
    
    func isPathableWithinBounds(pathMap:Matrix2D<Bool>, coord:DiscreteStandardCoord) -> Bool
    {
        return pathMap.isWithinBounds(coord.x, y:coord.y) && pathMap[coord.x, coord.y]
    }
    
    func strengthDistribution() -> [Int:Double]
    {
        var distribution = [Int:Double]()
        var totalNonZeroPoints = 0.0
        
        for staggered_x in 0..<grid.xMax
        {
            for staggered_y in 0..<grid.yMax
            {
                let type = pointType(staggered_x, staggered_y:staggered_y)
                
                if (type != .INVALID)
                {
                    let strength = grid[staggered_x, staggered_y]
                    
                    if (strength > 0)
                    {
                        totalNonZeroPoints++
                        
                        // If it exists in our distribution
                        if let currentCount = distribution[strength]
                        {
                            distribution[strength] = currentCount + 1
                        }
                        else
                        {
                            distribution[strength] = 1
                        }
                    }
                }
            }
        }
        
        for (strength, value) in distribution
        {
            distribution[strength] = value / totalNonZeroPoints
        }
        
        return distribution
    }
}