//
//  DirectoryUtility.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/19/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation

func applicationSupportDirectory() -> NSURL?
{
    let bundleID = NSBundle.mainBundle().bundleIdentifier!
    let fm = NSFileManager.defaultManager()
    var dirPath:NSURL? = nil
    
    let appSupportDir = fm.URLsForDirectory(NSSearchPathDirectory.ApplicationSupportDirectory, inDomains:NSSearchPathDomainMask.UserDomainMask)
    
    if (appSupportDir.count > 0)
    {
        dirPath = appSupportDir[0].URLByAppendingPathComponent(bundleID)
        
        if (!fm.fileExistsAtPath(dirPath!.path!))
        {
            do
            {
                try fm.createDirectoryAtURL(dirPath!, withIntermediateDirectories:true, attributes:nil)
            }
            catch
            {
                
            }
        }
    }
    
    return dirPath
}

func savedMaps() -> [String]
{
    var maps = [String]()
    
    if let appSupport = applicationSupportDirectory()
    {
        let fm = NSFileManager.defaultManager()
        let mapDirectory = appSupport.URLByAppendingPathComponent("maps")
        
        if (!fm.fileExistsAtPath(mapDirectory.path!))
        {
            do
            {
                try fm.createDirectoryAtURL(mapDirectory, withIntermediateDirectories:true, attributes:nil)
            }
            catch
            {
                
            }
        }
        else
        {
            do
            {
                // Retrieve all of the saved maps
                maps += try fm.contentsOfDirectoryAtPath(mapDirectory.path!)
            }
            catch
            {
                
            }
        }
    }
    
    return maps
}