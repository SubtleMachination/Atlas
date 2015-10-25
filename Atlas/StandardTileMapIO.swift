//
//  StandardTileMapIO.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/19/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation

func mapToString(map:StandardTileMap) -> String
{
    var mapString = "\(map.grid.xMax)x\(map.grid.yMax)-"
    
    for y in 0..<map.grid.yMax
    {
        for x in 0..<map.grid.xMax
        {
            mapString += "\(map.tileAt(x, y:y)!)"
            
            if (x < map.grid.xMax-1)
            {
                mapString += "."
            }
        }
        
        if (y < map.grid.yMax-1)
        {
            mapString += ","
        }
    }
    
    return mapString
}

func stringToMap(mapString:String) -> StandardTileMap
{
    var map = StandardTileMap()
    
    let fileComponents = mapString.componentsSeparatedByString("-")
    
    if (fileComponents.count == 2)
    {
        let metaData = fileComponents[0]
        let mapData = fileComponents[1]
        
        let metaDataComponents = metaData.componentsSeparatedByString("x")
        let tileRows = mapData.componentsSeparatedByString(",")
        
        if (metaDataComponents.count == 2)
        {
            if let xMax = Int(metaDataComponents[0])
            {
                if let yMax = Int(metaDataComponents[1])
                {
                    map = StandardTileMap(x:xMax, y:yMax, filler:1)
    
                    var y = 0
                    
                    for tileRow in tileRows
                    {
                        let tileColumns = tileRow.componentsSeparatedByString(".")
                        
                        var x = 0
                        
                        for tileCol in tileColumns
                        {
                            let tileValue = Int(tileCol)!
                            map.setTileAt(x, y:y, value:tileValue)
                            
                            x++
                        }
                        
                        y++
                    }
                }
            }
        }
        else
        {
            print("MALFORMED METADATA")
        }
    }
    
    return map
}

func fileToMap(mapName:String) -> StandardTileMap
{
    let mapsURL = applicationSupportDirectory()!
    let fileURL = mapsURL.URLByAppendingPathComponent("\(mapName).map")
    
    do
    {
        let contents = try NSString(contentsOfURL:fileURL, encoding:NSUTF8StringEncoding) as String
        return stringToMap(contents)
    }
    catch
    {
        print("FILE IMPORT FAILED")
    }
    
    return StandardTileMap()
}