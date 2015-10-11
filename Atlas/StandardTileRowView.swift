//
//  StandardTileRowView.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/10/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation
import SpriteKit

public class StandardTileRowView : SKNode
{
    var rowIndex:Int
    var tiles:[Int:SKSpriteNode]
    
    init(rowIndex:Int)
    {
        self.rowIndex = rowIndex
        self.tiles = [Int:SKSpriteNode]()
        
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}