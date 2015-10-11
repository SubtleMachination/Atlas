//
//  RandomExtensions.swift
//  DeepGeneration
//
//  Created by Dusty Artifact on 3/28/15.
//  Copyright (c) 2015 Runemark Studios. All rights reserved.

import Foundation

// Returns a random bool with 50/50 chance of getting true/false
func coinFlip() -> Bool
{
    return weightedCoinFlip(0.5)
}

// Returns with a (trueProb) probability of returning true, and a (1-trueProb) probability of returning false
func weightedCoinFlip(trueProb:Double) -> Bool
{
    return (trueProb > randNormalDouble())
}

// Returns a random int between the specified ranges (inclusive)
func randIntBetween(start:Int, stop:Int) -> Int
{
    var offset = 0
    
    if start < 0
    {
        offset = abs(start)
    }
    
    let mini = UInt32(start + offset)
    let maxi = UInt32(stop + offset)
    
    return Int(mini + arc4random_uniform(maxi + 1 - mini)) - offset
}

// Returns a random float between 0 and 1
func randNormalFloat() -> Float
{
    return Float(arc4random()) / Float(UINT32_MAX)
}

// Returns a random double between 0 and 1
func randNormalDouble() -> Double
{
    return Double(arc4random()) / Double(UINT32_MAX)
}

func randDoubleBetween(start:Double, stop:Double) -> Double
{
    let difference = abs(start - stop)
    return start + randNormalDouble()*difference
}