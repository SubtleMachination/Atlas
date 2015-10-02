//
//  ACTileMap.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/2/15.
//  Copyright © 2015 Runemark Studios. All rights reserved.
//

import Foundation

struct ACPoint
{
    var x:Double
    var y:Double
    var z:Double
    
    func roundDown() -> ACDiscretePoint
    {
        return ACDiscretePoint(x:Int(floor(x)), y:Int(floor(y)), z:Int(floor(z)))
    }
    
    func roundUp() -> ACDiscretePoint
    {
        return ACDiscretePoint(x:Int(ceil(x)), y:Int(ceil(y)), z:Int(ceil(z)))
    }
}

struct ACDiscretePoint
{
    var x:Int
    var y:Int
    var z:Int
}

////////////////////////////////////////////////////////////////////////////////
// ACTileMap
////////////////////////////////////////////////////////////////////////////////

class ACTileMap
{
    var grid:Matrix3D<Int>
    
    init(x:Int, y:Int, z:Int)
    {
        grid = Matrix3D<Int>(xMax:x, yMax:y, zMax:z, filler:1)
    }
    
    func isWithinBounds(point:ACDiscretePoint) -> Bool
    {
        return isWithinBounds(point.x, y:point.y, z:point.z)
    }
    
    func isWithinBounds(x:Int, y:Int, z:Int) -> Bool
    {
        return grid.isWithinBounds(x, y:y, z:z)
    }
    
    func tileAt(point:ACDiscretePoint) -> Int?
    {
        return tileAt(point.x, y:point.y, z:point.z)
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
    
    func setTileAt(point:ACDiscretePoint, value:Int)
    {
        setTileAt(point.x, y:point.y, z:point.z, value:value)
    }
    
    func setTileAt(x:Int, y:Int, z:Int, value:Int)
    {
        if (grid.isWithinBounds(x, y:y, z:z))
        {
            grid[x,y,z] = value
        }
    }
}