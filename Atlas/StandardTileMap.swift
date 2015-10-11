//
//  StandardTileMap.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/10/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation

////////////////////////////////////////////////////////////////////////////////
// ACTileMap
////////////////////////////////////////////////////////////////////////////////

public class StandardTileMap
{
    var grid:Matrix2D<Int>
    var dimensions:DiscreteStandardCoord
    
    // "Default" map
    convenience init()
    {
        self.init(x:5, y:5, filler:1)
    }
    
    init(x:Int, y:Int, filler:Int)
    {
        grid = Matrix2D<Int>(xMax:x, yMax:y, filler:filler)
        dimensions = DiscreteStandardCoord(x:x, y:y)
    }
    
    func isWithinBounds(coord:DiscreteDiamondCoord) -> Bool
    {
        return isWithinBounds(coord.x, y:coord.y)
    }
    
    func isWithinBounds(x:Int, y:Int) -> Bool
    {
        return grid.isWithinBounds(x, y:y)
    }
    
    func tileAt(coord:DiscreteDiamondCoord) -> Int?
    {
        return tileAt(coord.x, y:coord.y)
    }
    
    func tileAt(x:Int, y:Int) -> Int?
    {
        if (grid.isWithinBounds(x, y:y))
        {
            return grid[x,y]
        }
        else
        {
            return nil
        }
    }
    
    func setTileAt(coord:DiscreteDiamondCoord, value:Int)
    {
        setTileAt(coord.x, y:coord.y, z:coord.z, value:value)
    }
    
    func setTileAt(x:Int, y:Int, z:Int, value:Int)
    {
        if (grid.isWithinBounds(x, y:y))
        {
            grid[x,y] = value
        }
    }
}