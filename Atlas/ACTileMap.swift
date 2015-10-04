//
//  ACTileMap.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/2/15.
//  Copyright © 2015 Runemark Studios. All rights reserved.
//

import Foundation

////////////////////////////////////////////////////////////////////////////////
// ACTileMap
////////////////////////////////////////////////////////////////////////////////

class ACTileMap
{
    var grid:Matrix3D<Int>
    var dimensions:DiscreteDiamondCoord
    
    // "Default" map is a 10x10x1 empty grid
    convenience init()
    {
        self.init(x:15, y:15, z:1, filler:1)
    }
    
    init(x:Int, y:Int, z:Int, filler:Int)
    {
        grid = Matrix3D<Int>(xMax:x, yMax:y, zMax:z, filler:filler)
        dimensions = DiscreteDiamondCoord(x:x, y:y, z:z)
    }
    
    func isWithinBounds(coord:DiscreteDiamondCoord) -> Bool
    {
        return isWithinBounds(coord.x, y:coord.y, z:coord.z)
    }
    
    func isWithinBounds(x:Int, y:Int, z:Int) -> Bool
    {
        return grid.isWithinBounds(x, y:y, z:z)
    }
    
    func tileAt(coord:DiscreteDiamondCoord) -> Int?
    {
        return tileAt(coord.x, y:coord.y, z:coord.z)
    }
    
    func tileAt(x:Int, y:Int, z:Int) -> Int?
    {
        if (grid.isWithinBounds(x, y:y, z:z))
        {
            return grid[x,y,z]
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
        if (grid.isWithinBounds(x, y:y, z:z))
        {
            grid[x,y,z] = value
        }
    }
}