//
//  TileSet.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/13/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation

class TileOptions
{
    var wall:Bool
    var tile:[String]
    var base:[String]
    
    init(wall:Bool)
    {
        self.wall = wall
        self.tile = [String]()
        self.base = [String]()
    }
}

class Tileset
{
    var name:String
    var atlas:String
    var tiles:[Int:TileOptions]
    
    init()
    {
        self.name = "Default"
        self.atlas = "Default.png"
        self.tiles = [Int:TileOptions]()
    }
}