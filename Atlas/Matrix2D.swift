//
//  Array2D.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/2/15.
//  Copyright © 2015 Runemark Studios. All rights reserved.
//

import Foundation

////////////////////////////////////////////////////////////////////////////////
// Matrix2D
////////////////////////////////////////////////////////////////////////////////

public class Matrix2D<T>
{
    var xMax:Int = 0
    var yMax:Int = 0
    var matrix:[T]
    
    init(xMax:Int, yMax:Int, filler:T)
    {
        self.xMax = xMax
        self.yMax = yMax
        matrix = Array<T>(count:xMax*yMax, repeatedValue:filler)
    }
    
    subscript(x:Int, y:Int) -> T
    {
        get
        {
            return matrix[(xMax * y) + x]
        }
        set
        {
            matrix[(xMax * y) + x] = newValue
        }
    }
    
    func isWithinBounds(x:Int, y:Int) -> Bool
    {
        return (x >= 0 && y >= 0 && x < xMax && y < yMax)
    }
}