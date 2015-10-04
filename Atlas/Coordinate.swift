//
//  CoordinateSystems.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/3/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation

struct ACCoord
{
    var x:Double
    var y:Double
    var z:Double
    
    func roundDown() -> ACDiscreteCoord
    {
        return ACDiscreteCoord(x:Int(floor(x)), y:Int(floor(y)), z:Int(floor(z)))
    }
    
    func roundUp() -> ACDiscreteCoord
    {
        return ACDiscreteCoord(x:Int(ceil(x)), y:Int(ceil(y)), z:Int(ceil(z)))
    }
}

struct ACDiscreteCoord
{
    var x:Int
    var y:Int
    var z:Int
    
    func makePrecise() -> ACCoord
    {
        return ACCoord(x:Double(x), y:Double(y), z:Double(z))
    }
}

struct ACPoint
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

struct ACDiscretePoint
{
    var x:Int
    var y:Int
}