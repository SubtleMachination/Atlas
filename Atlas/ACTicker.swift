//
//  Tickable.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/8/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation

protocol ACTickable
{
    func tick(interval:NSTimeInterval)
}

class ACTicker
{
    var previous:NSTimeInterval = 0
    var tickables:[ACTickable]
    
    init()
    {
        tickables = [ACTickable]()
    }
    
    func addTickable(tickable:ACTickable)
    {
        tickables.append(tickable)
    }
    
    func update(current:NSTimeInterval)
    {
        if (previous == 0)
        {
            previous = current
        }
        
        let delta = current - previous
        
        for tickable in tickables
        {
            tickable.tick(delta)
        }
    }
}