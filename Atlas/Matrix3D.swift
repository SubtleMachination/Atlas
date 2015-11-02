//
//  Array2D.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/2/15.
//  Copyright © 2015 Runemark Studios. All rights reserved.
//

import Foundation

////////////////////////////////////////////////////////////////////////////////
// Matrix3D
////////////////////////////////////////////////////////////////////////////////

public class Matrix3D<T>
{
    var xMax:Int = 0
    var yMax:Int = 0
    var zMax:Int = 0
    var matrix:[T]
    
    init(xMax:Int, yMax:Int, zMax:Int, filler:T)
    {
        self.xMax = xMax
        self.yMax = yMax
        self.zMax = zMax
        matrix = Array<T>(count:xMax*yMax*zMax, repeatedValue:filler)
    }
    
    subscript(x:Int, y:Int, z:Int) -> T
    {
        get
        {
            return matrix[yMax*xMax*z + xMax*y + x]
        }
        set
        {
            matrix[yMax*xMax*z + xMax*y + x] = newValue
        }
    }
    
    func isWithinBounds(x:Int, y:Int, z:Int) -> Bool
    {
        return (x < xMax && y < yMax && z < zMax && x >= 0 && y >= 0 && z >= 0)
    }
}