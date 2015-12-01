//
//  IntUtility.swift
//  Atlas
//
//  Created by Dusty Artifact on 11/5/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation

extension Int
{
    func even() -> Bool
    {
        return self % 2 == 0
    }
    
    func odd() -> Bool
    {
        return !even()
    }
}