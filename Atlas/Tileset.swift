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
    
    init(plistName:String?)
    {
        self.name = "Default"
        self.atlas = "Default.png"
        self.tiles = [Int:TileOptions]()
        
        if let fileName = plistName
        {
            self.importTileset(fileName)
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Tileset Import
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func importTileset(plistName:String)
    {
        if let path = NSBundle.mainBundle().pathForResource(plistName, ofType: "plist")
        {
            let contents = NSDictionary(contentsOfFile:path)!
            
            name = String(contents.valueForKey("name") as! NSString)
            atlas = String(contents.valueForKey("atlas") as! NSString)
            
            let tileContents = contents.valueForKey("tiles") as! NSDictionary
            
            for key in tileContents.allKeys
            {
                let tileIDString = key as! String
                let tileID = NSNumberFormatter().numberFromString(tileIDString)!.integerValue
                let tileDictionary = tileContents.valueForKey(tileIDString) as! NSDictionary
                
                let wall = tileDictionary.valueForKey("wall") as! Bool
                let tileSourceInfo = tileDictionary.valueForKey("tile") as! NSArray
                let baseSourceInfo = tileDictionary.valueForKey("base") as! NSArray
                
                let tileOptions = TileOptions(wall:wall)
                
                for index in 0..<tileSourceInfo.count
                {
                    let sourceImageName = String(tileSourceInfo[index] as! NSString)
                    tileOptions.tile.append(sourceImageName)
                }
                
                for index in 0..<baseSourceInfo.count
                {
                    let sourceImageName = String(baseSourceInfo[index] as! NSString)
                    tileOptions.base.append(sourceImageName)
                }
                
                tiles[tileID] = tileOptions
            }
        }
        else
        {
            print("PLIST MISSING")
        }
    }
}