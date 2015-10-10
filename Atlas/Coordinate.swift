//
//  CoordinateSystems.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/3/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation

public struct StaggeredCoord
{
    var x:Int
    var y:Int
    var z:Int
}

public struct DiamondCoord
{
    var x:Double
    var y:Double
    var z:Double
    
    func roundDown() -> DiscreteDiamondCoord
    {
        return DiscreteDiamondCoord(x:Int(floor(x)), y:Int(floor(y)), z:Int(floor(z)))
    }
    
    func roundUp() -> DiscreteDiamondCoord
    {
        return DiscreteDiamondCoord(x:Int(ceil(x)), y:Int(ceil(y)), z:Int(ceil(z)))
    }
}

public func +=(inout lhs:DiamondCoord, rhs:DiamondCoord)
{
    lhs.x += rhs.x
    lhs.y += rhs.y
    lhs.z += rhs.z
}

public struct DiscreteDiamondCoord
{
    var x:Int
    var y:Int
    var z:Int
    
    func makePrecise() -> DiamondCoord
    {
        return DiamondCoord(x:Double(x), y:Double(y), z:Double(z))
    }
    
    mutating func moveNorth()
    {
        y += 1
    }
    
    mutating func moveSouth()
    {
        y -= 1
    }
    
    mutating func moveEast()
    {
        x += 1
    }
    
    mutating func moveWest()
    {
        x -= 1
    }
    
    mutating func moveUp()
    {
        z += 1
    }
    
    mutating func moveDown()
    {
        z -= 1
    }
    
    func north() -> DiscreteDiamondCoord
    {
        return DiscreteDiamondCoord(x:x, y:y+1, z:z)
    }
    
    func south() -> DiscreteDiamondCoord
    {
        return DiscreteDiamondCoord(x:x, y:y-1, z:z)
    }
    
    func east() -> DiscreteDiamondCoord
    {
        return DiscreteDiamondCoord(x:x+1, y:y, z:z)
    }
    
    func west() -> DiscreteDiamondCoord
    {
        return DiscreteDiamondCoord(x:x-1, y:y, z:z)
    }
    
    func up() -> DiscreteDiamondCoord
    {
        return DiscreteDiamondCoord(x:x, y:y, z:z+1)
    }
    
    func down() -> DiscreteDiamondCoord
    {
        return DiscreteDiamondCoord(x:x, y:y, z:z-1)
    }
}

public struct ACPoint
{
    var x:Double
    var y:Double
    
    func roundDown() -> ACDiscretePoint
    {
        return ACDiscretePoint(x:Int(floor(x)), y:Int(floor(y)))
    }
    
    func roundUp() -> ACDiscretePoint
    {
        return ACDiscretePoint(x:Int(ceil(x)), y:Int(ceil(y)))
    }
    
    func toCGPoint() -> CGPoint
    {
        return CGPointMake(CGFloat(x), CGFloat(y))
    }
}

public func -(lhs:ACPoint, rhs:ACPoint) -> ACPoint
{
    return ACPoint(x:lhs.x - rhs.x, y:lhs.y - rhs.y)
}

public struct ACDiscretePoint
{
    var x:Int
    var y:Int
}

public struct ACBoundingBox
{
    var left:Int
    var right:Int
    var up:Int
    var down:Int
}

public func +(lhs:CGPoint, rhs:CGPoint) -> CGPoint
{
    return CGPoint(x:lhs.x + rhs.x, y:lhs.y + rhs.y)
}

public func -(lhs:CGPoint, rhs:CGPoint) -> CGPoint
{
    return CGPoint(x:lhs.x - rhs.x, y:lhs.y - rhs.y)
}