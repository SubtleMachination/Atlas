//
//  CoordinateSystems.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/3/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation

//////////////////////////////////////////////////////////////////////////////////////////
// STANDARD COORDINATE (RECTANGULAR TILES)
// Used for standard top-down or sidescrolling tile-based maps
//////////////////////////////////////////////////////////////////////////////////////////

public struct StandardCoord
{
    var x:Double
    var y:Double
    
    func roundDown() -> DiscreteStandardCoord
    {
        return DiscreteStandardCoord(x:Int(floor(x)), y:Int(floor(y)))
    }
    
    func roundUp() -> DiscreteStandardCoord
    {
        return DiscreteStandardCoord(x:Int(ceil(x)), y:Int(ceil(y)))
    }
    
    
}

public struct DiscreteStandardCoord : Hashable
{
    var x:Int
    var y:Int
    
    func makePrecise() -> StandardCoord
    {
        return StandardCoord(x:Double(x), y:Double(y))
    }
    
    public var hashValue: Int
    {
        return "(\(x), \(y))".hashValue
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
// DIAMOND COORDINATE (ISOMETRIC TILES)
// Used for isometric-view
//////////////////////////////////////////////////////////////////////////////////////////

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

public struct DiscreteDiamondCoord
{
    var x:Int
    var y:Int
    var z:Int
    
    func makePrecise() -> DiamondCoord
    {
        return DiamondCoord(x:Double(x), y:Double(y), z:Double(z))
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
// STAGGERED COORDINATE (ISOMETRIC TILES)
// Used for isometric-view
//
//         C0 C1 C2 C3 C4 C5 C6
// ROW 3: <0,3> <2,3> <4,3> <6,3>
// ROW 2:    <1,2> <3,2> <5,2>
// ROW 1: <0,1> <2,1> <4,1> <6,1>
// ROW 0:    <1,0> <3,0> <5,0>
//////////////////////////////////////////////////////////////////////////////////////////

public struct StaggeredCoord
{
    var x:Int
    var y:Int
    var z:Int
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

public struct ACDiscretePoint
{
    var x:Int
    var y:Int
}

public struct ACTileBoundingBox
{
    var left:Int
    var right:Int
    var up:Int
    var down:Int
}

//////////////////////////////////////////////////////////////////////////////////////////
// OPERATORS ON STANDARD COORDINATES
//////////////////////////////////////////////////////////////////////////////////////////

public func +=(inout lhs:StandardCoord, rhs:StandardCoord)
{
    lhs.x += rhs.x
    lhs.y += rhs.y
}

public func -=(inout lhs:StandardCoord, rhs:StandardCoord)
{
    lhs.x -= rhs.x
    lhs.y -= rhs.y
}

public func +(lhs:StandardCoord, rhs:StandardCoord) -> StandardCoord
{
    return StandardCoord(x:lhs.x + rhs.x, y:lhs.y + rhs.y)
}

public func -(lhs:StandardCoord, rhs:StandardCoord) -> StandardCoord
{
    return StandardCoord(x:lhs.x - rhs.x, y:lhs.y - rhs.y)
}

public func +=(inout lhs:DiscreteStandardCoord, rhs:DiscreteStandardCoord)
{
    lhs.x += rhs.x
    lhs.y += rhs.y
}

public func +(lhs:DiscreteStandardCoord, rhs:DiscreteStandardCoord) -> DiscreteStandardCoord
{
    return DiscreteStandardCoord(x:lhs.x + rhs.x, y:lhs.y + rhs.y)
}

public func -(lhs:DiscreteStandardCoord, rhs:DiscreteStandardCoord) -> DiscreteStandardCoord
{
    return DiscreteStandardCoord(x:lhs.x - rhs.x, y:lhs.y - rhs.y)
}

public func ==(lhs:DiscreteStandardCoord, rhs:DiscreteStandardCoord) -> Bool
{
    return (lhs.x == rhs.x && lhs.y == rhs.y)
}

//////////////////////////////////////////////////////////////////////////////////////////
// OPERATORS ON STAGGERED COORDINATES
//////////////////////////////////////////////////////////////////////////////////////////

public func +(lhs:StaggeredCoord, rhs:StaggeredCoord) -> StaggeredCoord
{
    return StaggeredCoord(x:lhs.x + rhs.x, y:lhs.y + rhs.y, z:lhs.z + rhs.z)
}

public func -(lhs:StaggeredCoord, rhs:StaggeredCoord) -> StaggeredCoord
{
    return StaggeredCoord(x:lhs.x - rhs.x, y:lhs.y - rhs.y, z:lhs.z - rhs.z)
}

public func +=(inout lhs:StaggeredCoord, rhs:StaggeredCoord)
{
    lhs.x += rhs.x
    lhs.y += rhs.y
    lhs.z += rhs.z
}

public func -=(inout lhs:StaggeredCoord, rhs:StaggeredCoord)
{
    lhs.x -= rhs.x
    lhs.y -= rhs.y
    lhs.z -= rhs.z
}

//////////////////////////////////////////////////////////////////////////////////////////
// OPERATORS ON DIAMOND COORDINATES
//////////////////////////////////////////////////////////////////////////////////////////

public func +(lhs:DiamondCoord, rhs:DiamondCoord) -> DiamondCoord
{
    return DiamondCoord(x:lhs.x + rhs.x, y:lhs.y + rhs.y, z:lhs.z + rhs.z)
}

public func -(lhs:DiamondCoord, rhs:DiamondCoord) -> DiamondCoord
{
    return DiamondCoord(x:lhs.x - rhs.x, y:lhs.y - rhs.y, z:lhs.z - rhs.z)
}

public func +=(inout lhs:DiamondCoord, rhs:DiamondCoord)
{
    lhs.x += rhs.x
    lhs.y += rhs.y
    lhs.z += rhs.z
}

public func -=(inout lhs:DiamondCoord, rhs:DiamondCoord)
{
    lhs.x -= rhs.x
    lhs.y -= rhs.y
    lhs.z -= rhs.z
}

public func +(lhs:DiscreteDiamondCoord, rhs:DiscreteDiamondCoord) -> DiscreteDiamondCoord
{
    return DiscreteDiamondCoord(x:lhs.x + rhs.x, y:lhs.y + rhs.y, z:lhs.z + rhs.z)
}

public func -(lhs:DiscreteDiamondCoord, rhs:DiscreteDiamondCoord) -> DiscreteDiamondCoord
{
    return DiscreteDiamondCoord(x:lhs.x - rhs.x, y:lhs.y - rhs.y, z:lhs.z - rhs.z)
}

public func +=(inout lhs:DiscreteDiamondCoord, rhs:DiscreteDiamondCoord)
{
    lhs.x += rhs.x
    lhs.y += rhs.y
    lhs.z += rhs.z
}

public func -=(inout lhs:DiscreteDiamondCoord, rhs:DiscreteDiamondCoord)
{
    lhs.x -= rhs.x
    lhs.y -= rhs.y
    lhs.z -= rhs.z
}

//////////////////////////////////////////////////////////////////////////////////////////
// OPERATORS ON ACPOINTS
//////////////////////////////////////////////////////////////////////////////////////////

public func +(lhs:ACPoint, rhs:ACPoint) -> ACPoint
{
    return ACPoint(x:lhs.x + rhs.x, y:lhs.y + rhs.y)
}

public func -(lhs:ACPoint, rhs:ACPoint) -> ACPoint
{
    return ACPoint(x:lhs.x - rhs.x, y:lhs.y - rhs.y)
}

//////////////////////////////////////////////////////////////////////////////////////////
// OPERATORS ON CGPOINTS
//////////////////////////////////////////////////////////////////////////////////////////

public func +(lhs:CGPoint, rhs:CGPoint) -> CGPoint
{
    return CGPoint(x:lhs.x + rhs.x, y:lhs.y + rhs.y)
}

public func -(lhs:CGPoint, rhs:CGPoint) -> CGPoint
{
    return CGPoint(x:lhs.x - rhs.x, y:lhs.y - rhs.y)
}

public func +=(inout lhs:CGPoint, rhs:CGPoint)
{
    lhs.x += rhs.x
    lhs.y += rhs.y
}

public func -=(inout lhs:CGPoint, rhs:CGPoint)
{
    lhs.x -= rhs.x
    lhs.y -= rhs.y
}

