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
    var rows:Int = 0
    var cols:Int = 0
    var matrix:[T]
    
    init(rows:Int, cols:Int, filler:T)
    {
        self.rows = rows
        self.cols = cols
        matrix = Array<T>(count:rows*cols, repeatedValue:filler)
    }
    
    subscript(row:Int, col:Int) -> T
    {
        get
        {
            return matrix[cols*row + col]
        }
        set
        {
            matrix[cols*row + col] = newValue
        }
    }
    
    func isWithinBounds(row:Int, col:Int) -> Bool
    {
        return (row >= 0 && col >= 0 && row < rows && col < cols)
    }
}