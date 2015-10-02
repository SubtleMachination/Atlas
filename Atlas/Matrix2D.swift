//
//  Array2D.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/2/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation

////////////////////////////////////////////////////////////////////////////////
// Matrix2D
////////////////////////////////////////////////////////////////////////////////

class Matrix2D<T>
{
    var rows:Int = 0
    var cols:Int = 0
    var matrix:[T]
    
    var fillerValue:T
    
    init(rows:Int, cols:Int, filler:T) {
        
        self.rows = rows
        self.cols = cols
        self.fillerValue = filler
        matrix = Array<T>(count:rows*cols, repeatedValue:filler)
    }
    
    subscript(row:Int, col:Int) -> T {
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
    
    func isOnEdge(row:Int, col:Int) -> Bool
    {
        return (row == 0 || col == 0 || row == rows-1 || col == cols-1)
    }
}