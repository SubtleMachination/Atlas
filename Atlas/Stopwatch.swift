//
//  StopwatchUtility.swift
//  Atlas
//
//  Created by Dusty Artifact on 11/4/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation

class Stopwatch
{
    var startTime:CFAbsoluteTime
    
    init()
    {
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func start()
    {
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func mark() -> CFAbsoluteTime
    {
        return CFAbsoluteTimeGetCurrent() - startTime
    }
}