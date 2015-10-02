//
//  ACTileMap.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/2/15.
//  Copyright © 2015 Runemark Studios. All rights reserved.
//

import Foundation

class ACTileMap
{
    var grid:Matrix2D<Int>
    
    // Defaults to a full grid of basic tiles
    init(x:Int, y:Int)
    {
        grid = Matrix2D<Int>(rows:x, cols:y, filler:1)
    }
}