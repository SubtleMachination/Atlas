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
    var updateNeeded:Bool

    // "Default" map
    convenience init()
    {
        self.init(x:5, y:5, filler:0)
    }
    
    init(x:Int, y:Int, filler:Int)
    {
        grid = Matrix2D<Int>(xMax:x, yMax:y, filler:filler)
        dimensions = DiscreteStandardCoord(x:x, y:y)
        updateNeeded = false
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
            if (value != grid[x,y])
            {
                grid[x,y] = value
                updateNeeded = true
            }
        }
    }
    
    func randomTile() -> DiscreteStandardCoord
    {
        return DiscreteStandardCoord(x:randIntBetween(0, stop:grid.xMax-1), y:randIntBetween(0, stop:grid.yMax-1))
    }
    
    func clearChanges()
    {
        updateNeeded = false
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
    
    // 0.0 = anti-symmetric, 1.0 = fully-symmetric
    func computeSymmetry() -> Double
    {
        var symmetricTileCount = 0
        var totalTileCount = 0
        
        // Because this is symmetry, we only need to compute for half of the map
        let horizontal_center = Int(floor(Double(grid.xMax)/2))
        
        for x in 0..<horizontal_center
        {
            for y in 0..<grid.yMax
            {
                let coord = DiscreteStandardCoord(x:x, y:y)
                let value = tileAt(coord)!
                let symmetricValue = tileAt(symmetricPos(coord))
                
                if (value == symmetricValue)
                {
                    symmetricTileCount++
                }
                
                totalTileCount++
            }
        }
        
        return Double(symmetricTileCount) / Double(totalTileCount)
    }
    
    func symmetricPos(origin:DiscreteStandardCoord) -> DiscreteStandardCoord
    {
        return DiscreteStandardCoord(x:(grid.xMax - 1) - origin.x, y:origin.y)
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
    
    func loadRandom(xMax:Int, yMax:Int)
    {
        grid = Matrix2D<Int>(xMax:xMax, yMax:yMax, filler:0)
        dimensions = DiscreteStandardCoord(x:xMax, y:yMax)
        
        for x in 0..<xMax
        {
            for y in 0..<yMax
            {
                grid[x, y] = randIntBetween(0, stop:2)
            }
        }
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