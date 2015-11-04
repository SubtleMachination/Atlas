//
//  StandardTileMap.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/10/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation

////////////////////////////////////////////////////////////////////////////////
// ACTileMap
////////////////////////////////////////////////////////////////////////////////

public class StandardTileMap
{
    var grid:Matrix2D<Int>
    var dimensions:DiscreteStandardCoord

    // "Default" map
    convenience init()
    {
        self.init(x:5, y:5, filler:0)
    }
    
    init(x:Int, y:Int, filler:Int)
    {
        grid = Matrix2D<Int>(xMax:x, yMax:y, filler:filler)
        dimensions = DiscreteStandardCoord(x:x, y:y)
    }
    
    func fetchDimensions() -> DiscreteStandardCoord
    {
        return dimensions
    }
    
    func isWithinBounds(coord:DiscreteStandardCoord) -> Bool
    {
        return isWithinBounds(coord.x, y:coord.y)
    }
    
    func isWithinBounds(x:Int, y:Int) -> Bool
    {
        return grid.isWithinBounds(x, y:y)
    }
    
    func tileAt(coord:DiscreteStandardCoord) -> Int?
    {
        return tileAt(coord.x, y:coord.y)
    }
    
    func tileAt(x:Int, y:Int) -> Int?
    {
        if (grid.isWithinBounds(x, y:y))
        {
            return grid[x,y]
        }
        else
        {
            return nil
        }
    }
    
    func setTileAt(coord:DiscreteStandardCoord, value:Int)
    {
        setTileAt(coord.x, y:coord.y, value:value)
    }
    
    func setTileAt(x:Int, y:Int, value:Int)
    {
        if (grid.isWithinBounds(x, y:y))
        {
            grid[x,y] = value
        }
    }
    
    // 0: unpathable, 1: pathable
    func binaryPaths() -> Matrix2D<Bool>
    {
        let paths = Matrix2D<Bool>(xMax:grid.xMax, yMax:grid.yMax, filler:false)
        
        for x in 0..<grid.xMax
        {
            for y in 0..<grid.yMax
            {
                if grid[x,y] == 1
                {
                    paths[x,y] = true
                }
            }
        }
        
        return paths
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Load TileMap from File
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func loadDefault()
    {
        grid = Matrix2D<Int>(xMax:5, yMax:5, filler:1)
        dimensions = DiscreteStandardCoord(x:5, y:5)
    }
    
    func loadBlank(xMax:Int, yMax:Int, filler:Int)
    {
        grid = Matrix2D<Int>(xMax:xMax, yMax:yMax, filler:filler)
        dimensions = DiscreteStandardCoord(x:xMax, y:yMax)
    }
    
    func loadFromFile(mapName:String)
    {
        let mapsURL = applicationSupportDirectory()!.URLByAppendingPathComponent("maps")
        let fileURL = mapsURL.URLByAppendingPathComponent("\(mapName).map")
        
        do
        {
            let contents = try NSString(contentsOfURL:fileURL, encoding:NSUTF8StringEncoding) as String
            stringToMap(contents)
        }
        catch
        {
            print("FILE IMPORT FAILED")
        }
    }
    
    func stringToMap(mapString:String)
    {
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
                        grid = Matrix2D<Int>(xMax:xMax, yMax:yMax, filler:1)
                        dimensions = DiscreteStandardCoord(x:xMax, y:yMax)
                        
                        var y = 0
                        
                        for tileRow in tileRows
                        {
                            let tileColumns = tileRow.componentsSeparatedByString(".")
                            
                            var x = 0
                            
                            for tileCol in tileColumns
                            {
                                let tileValue = Int(tileCol)!
                                setTileAt(x, y:y, value:tileValue)
                                
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
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Save TileMap from String
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func toString() -> String
    {
        var mapString = "\(grid.xMax)x\(grid.yMax)-"
        
        for y in 0..<grid.yMax
        {
            for x in 0..<grid.xMax
            {
                mapString += "\(tileAt(x, y:y)!)"
                
                if (x < grid.xMax-1)
                {
                    mapString += "."
                }
            }
            
            if (y < grid.yMax-1)
            {
                mapString += ","
            }
        }
        
        return mapString
    }
}