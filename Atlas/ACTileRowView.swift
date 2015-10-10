//
//  ACTileRowView.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/3/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation
import SpriteKit

// In a staggered grid, rows alternate between having x (long) and x-1 (short) tiles
// We need to keep track of which type in order to render this row with the proper x-offset
enum RowType
{
    case RT_LONG, RT_SHORT
}

////////////////////////////////////////////////////////////
// Indexing Example:
//
// ROW 3: <0,3> <2,3> <4,3> <6,3>  (long: 4 tiles)
// ROW 2:    <1,2> <3,2> <5,2>     (short: 3 tiles)
// ROW 1: <0,1> <2,1> <4,1> <6,1>  (long: 4 tiles)
// ROW 0:    <1,0> <3,0> <5,0>     (short: 3 tiles)
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// Positioning Example:
// if tileWidth = 25:
// ROW Y: |<0> <25> <50> <75> <100> ...
////////////////////////////////////////////////////////////

public class ACTileRowView : SKNode
{
    var rowIndex:Int
    var width:Int
    var type:RowType = RowType.RT_LONG
    var tiles:[Int:SKSpriteNode]
    
    init(rowIndex:Int, width:Int, type:RowType)
    {
        self.rowIndex = rowIndex
        self.width = width
        self.type = type
        
        self.tiles = [Int:SKSpriteNode]()
        
        super.init()
    }

    required public init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}