//
//  ACEase.swift
//  ACFramework
//
//  Created by Martin Mumford on 7/13/15.
//  Copyright © 2015 Runemark Studios. All rights reserved.
//

import Foundation
import SpriteKit

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Curve Types
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

public enum CurveType
{
    case LINEAR, QUADRATIC_IN, QUADRATIC_OUT, QUADRATIC_INOUT, CUBIC_IN, CUBIC_OUT, CUBIC_INOUT, QUARTIC_IN, QUARTIC_OUT, QUARTIC_INOUT, QUINTIC_IN, QUINTIC_OUT, QUINTIC_INOUT, SINE_IN, SINE_OUT, SINE_INOUT, CIRCULAR_IN, CIRCULAR_OUT, CIRCULAR_INOUT, EXPONENTIAL_IN, EXPONENTIAL_OUT, EXPONENTIAL_INOUT, ELASTIC_IN, ELASTIC_OUT, ELASTIC_INOUT, BACK_IN, BACK_OUT, BACK_INOUT
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// SKAction Generators
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

func scaleToProportion(node:SKNode, scale:CGFloat, duration:CGFloat, type:CurveType) -> SKAction
{
    let initialScale = node.xScale
    let actionBlock = {(node:SKNode, elapsedTime:CGFloat) -> Void in
        let t = elapsedTime/duration
        let d = applyCurve(t, type:type)
        let s = initialScale*(1-d) + scale * d
        node.setScale(s)}
    
    return SKAction.customActionWithDuration(NSTimeInterval(duration), actionBlock:actionBlock)
}

// Only applies to SKSPriteNode
func scaleToSize(node:SKSpriteNode, size:CGSize, duration:CGFloat, type:CurveType) -> SKAction
{
    // CURRENT image size
    let initial_x = node.size.width
    let initial_y = node.size.height
    
    // ORIGINAL image dimensions
    let original_x = initial_x/node.xScale
    let original_y = initial_y/node.yScale
    
    let actionBlock = {(node:SKNode, elapsedTime:CGFloat) -> Void in
        let t = elapsedTime/duration
        let d = applyCurve(t, type:type)
        let new_x = initial_x*(1-d) + size.width * d
        let new_y = initial_y*(1-d) + size.height * d
        
        node.xScale = new_x/original_x
        node.yScale = new_y/original_y}
    
    return SKAction.customActionWithDuration(NSTimeInterval(duration), actionBlock:actionBlock)
}

func fadeTo(node:SKNode, alpha:CGFloat, duration:CGFloat, type:CurveType) -> SKAction
{
    let initialAlpha = node.alpha
    
    let actionBlock = {(node:SKNode, elapsedTime:CGFloat) -> Void in
        let t = elapsedTime/duration
        let d = applyCurve(t, type:type)
        let newAlpha = initialAlpha*(1-d) + alpha * d
        node.alpha = newAlpha}
    
    return SKAction.customActionWithDuration(NSTimeInterval(duration), actionBlock:actionBlock)
}

func fadeTo(start:CGFloat, finish:CGFloat, duration:CGFloat, type:CurveType) -> SKAction
{
    let actionBlock = {(node:SKNode, elapsedTime:CGFloat) -> Void in
        let t = elapsedTime/duration
        let d = applyCurve(t, type:type)
        let newAlpha = start*(1-d) + finish * d
        node.alpha = newAlpha
    }
    
    return SKAction.customActionWithDuration(NSTimeInterval(duration), actionBlock:actionBlock)
}

func rotateTo(start:CGFloat, finish:CGFloat, duration:CGFloat, type:CurveType) -> SKAction
{
    let actionBlock = {(node:SKNode, elapsedTime:CGFloat) -> Void in
        let t = elapsedTime/duration
        let d = applyCurve(t, type:type)
        let newRotation = start*(1-d) + finish * d
        node.zRotation = newRotation
    }
    
    return SKAction.customActionWithDuration(NSTimeInterval(duration), actionBlock:actionBlock)
}

func rotateBy(node:SKNode, delta:CGFloat, duration:CGFloat, type:CurveType) -> SKAction
{
    let initialRotation = node.zRotation
    
    let actionBlock = {(node:SKNode, elapsedTime:CGFloat) -> Void in
        let t = elapsedTime/duration
        let d = applyCurve(t, type:type)
        let newRotation = initialRotation + (delta * d)
        node.zRotation = newRotation
    }
    
    return SKAction.customActionWithDuration(NSTimeInterval(duration), actionBlock:actionBlock)
}

public func idle(duration:CGFloat) -> SKAction
{
    let actionBlock = {(node:SKNode, elapsedTime:CGFloat) -> Void in
        // Does nothing for the specified duration
    }
    
    return SKAction.customActionWithDuration(NSTimeInterval(duration), actionBlock:actionBlock)
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Curves
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

func applyCurve(p:CGFloat, type:CurveType) -> CGFloat
{
    var result = CGFloat(0.0)
    
    switch (type) {
    case .LINEAR:
        result = curveLinear(p)
        break
    case .QUADRATIC_IN:
        result = curveQuadraticEaseIn(p)
        break
    case .QUADRATIC_OUT:
        result = curveQuadraticEaseOut(p)
        break
    case .QUADRATIC_INOUT:
        result = curveQuadraticEaseInOut(p)
        break
    case .CUBIC_IN:
        result = curveCubicEaseIn(p)
        break
    case .CUBIC_OUT:
        result = curveCubicEaseOut(p)
        break
    case .CUBIC_INOUT:
        result = curveCubicEaseInOut(p)
        break
    case .QUARTIC_IN:
        result = curveQuarticEaseIn(p)
        break
    case .QUARTIC_OUT:
        result = curveQuarticEaseOut(p)
        break
    case .QUARTIC_INOUT:
        result = curveQuarticEaseInOut(p)
        break
    case .QUINTIC_IN:
        result = curveQuinticEaseIn(p)
        break
    case .QUINTIC_OUT:
        result = curveQuinticEaseOut(p)
        break
    case .QUINTIC_INOUT:
        result = curveQuinticEaseInOut(p)
        break
    case .SINE_IN:
        result = curveSineEaseIn(p)
        break
    case .SINE_OUT:
        result = curveSineEaseOut(p)
        break
    case .SINE_INOUT:
        result = curveSineEaseInOut(p)
        break
    case .CIRCULAR_IN:
        result = curveCircularEaseIn(p)
        break
    case .CIRCULAR_OUT:
        result = curveCircularEaseOut(p)
        break
    case .CIRCULAR_INOUT:
        result = curveCircularEaseInOut(p)
        break
    case .EXPONENTIAL_IN:
        result = curveExponentialEaseIn(p)
        break
    case .EXPONENTIAL_OUT:
        result = curveExponentialEaseOut(p)
        break
    case .EXPONENTIAL_INOUT:
        result = curveExponentialEaseInOut(p)
        break
    case .ELASTIC_IN:
        result = curveElasticEaseIn(p)
        break
    case .ELASTIC_OUT:
        result = curveElasticEaseOut(p)
        break
    case .ELASTIC_INOUT:
        result = curveElasticEaseInOut(p)
        break
    case .BACK_IN:
        result = curveBackEaseIn(p)
        break
    case .BACK_OUT:
        result = curveBackEaseOut(p)
        break
    case .BACK_INOUT:
        result = curveBackEaseInOut(p)
        break
    }
    
    return result
}

// y = x
func curveLinear(p:CGFloat) -> CGFloat
{
    return p
}

// y = x^2
func curveQuadraticEaseIn(p:CGFloat) -> CGFloat
{
    return p * p
}

// y = -x^2 + 2x
func curveQuadraticEaseOut(p:CGFloat) -> CGFloat
{
    return -(p * (p - 2))
}

// y = (1/2)((2x)^2)             | [0, 0.5)
// y = -(1/2)((2x-1)*(2x-3) - 1) | [0.5, 1]
func curveQuadraticEaseInOut(p:CGFloat) -> CGFloat
{
    if (p < 0.5)
    {
        return 2 * p * p;
    }
    else
    {
        return (-2 * p * p) + (4 * p) - 1;
    }
}

// y = x^3
func curveCubicEaseIn(p:CGFloat) -> CGFloat
{
    return p * p * p
}

// y = (x - 1)^3 + 1
func curveCubicEaseOut(p:CGFloat) -> CGFloat
{
    let f = p - 1
    return f * f * f + 1
}

// y = (1/2)((2x)^3)       | [0, 0.5)
// y = (1/2)((2x-2)^3 + 2) | [0.5, 1]
func curveCubicEaseInOut(p:CGFloat) -> CGFloat
{
    if(p < 0.5)
    {
        return 4 * p * p * p
    }
    else
    {
        let f = ((2 * p) - 2)
        return 0.5 * f * f * f + 1
    }
}

// y = x^4
func curveQuarticEaseIn(p:CGFloat) -> CGFloat
{
    return p * p * p * p
}

// y = 1 - (x - 1)^4
func curveQuarticEaseOut(p:CGFloat) -> CGFloat
{
    let f = p - 1
    return f * f * f * (1 - p) + 1
}


// y = (1/2)((2x)^4)        | [0, 0.5)
// y = -(1/2)((2x-2)^4 - 2) | [0.5, 1]
func curveQuarticEaseInOut(p:CGFloat) -> CGFloat
{
    if (p < 0.5)
    {
        return 8 * p * p * p * p
    }
    else
    {
        let f = p - 1
        return -8 * f * f * f * f + 1
    }
}

// y = x^5
func curveQuinticEaseIn(p:CGFloat) -> CGFloat
{
    return p * p * p * p * p
}

// y = (x - 1)^5 + 1
func curveQuinticEaseOut(p:CGFloat) -> CGFloat
{
    let f = p - 1
    return f * f * f * f * f + 1
}

// y = (1/2)((2x)^5)       | [0, 0.5)
// y = (1/2)((2x-2)^5 + 2) | [0.5, 1]
func curveQuinticEaseInOut(p:CGFloat) -> CGFloat
{
    if (p < 0.5)
    {
        return 16 * p * p * p * p * p
    }
    else
    {
        let f = (2 * p) - 2
        return  0.5 * f * f * f * f * f + 1
    }
}

func curveSineEaseIn(p:CGFloat) -> CGFloat
{
    return sin((p - 1) * CGFloat(M_PI_2)) + 1
}

func curveSineEaseOut(p:CGFloat) -> CGFloat
{
    return sin(p * CGFloat(M_PI_2))
}

func curveSineEaseInOut(p:CGFloat) -> CGFloat
{
    return 0.5 * (1 - cos(p * CGFloat(M_PI)))
}

func curveCircularEaseIn(p:CGFloat) -> CGFloat
{
    return 1 - sqrt(1 - (p * p))
}

func curveCircularEaseOut(p:CGFloat) -> CGFloat
{
    return sqrt((2 - p) * p)
}

// y = (1/2)(1 - sqrt(1 - 4x^2))           | [0, 0.5)
// y = (1/2)(sqrt(-(2x - 3)*(2x - 1)) + 1) | [0.5, 1]
func curveCircularEaseInOut(p:CGFloat) -> CGFloat
{
    if (p < 0.5)
    {
        return 0.5 * (1 - sqrt(1 - 4 * (p * p)))
    }
    else
    {
        return 0.5 * (sqrt(-((2 * p) - 3) * ((2 * p) - 1)) + 1)
    }
}

// y = -2^(-10x) + 1
func curveExponentialEaseIn(p:CGFloat) -> CGFloat
{
    return (p == 1.0) ? p : 1 - pow(2, -10 * p)
}

// y = -2^(-10x) + 1
func curveExponentialEaseOut(p:CGFloat) -> CGFloat
{
    return (p == 1.0) ? p : 1 - pow(2, -10 * p)
}

// y = (1/2)2^(10(2x - 1))         | [0,0.5)
// y = -(1/2)*2^(-10(2x - 1))) + 1 | [0.5,1]
func curveExponentialEaseInOut(p:CGFloat) -> CGFloat
{
    if (p == 0.0 || p == 1.0)
    {
        return p
    }
    
    if (p < 0.5)
    {
        return 0.5 * pow(2, (20 * p) - 10);
    }
    else
    {
        return -0.5 * pow(2, (-20 * p) + 10) + 1;
    }
}

// y = sin(13pi/2*x)*pow(2, 10 * (x - 1))
func curveElasticEaseIn(p:CGFloat) -> CGFloat
{
    return sin(13 * CGFloat(M_PI_2) * p) * pow(2, 10 * (p - 1))
}

// y = sin(-13pi/2*(x + 1))*pow(2, -10x) + 1
func curveElasticEaseOut(p:CGFloat) -> CGFloat
{
    return sin(-13 * CGFloat(M_PI_2) * (p + 1)) * pow(2, -10 * p) + 1
}

// y = (1/2)*sin(13pi/2*(2*x))*pow(2, 10 * ((2*x) - 1))      | [0,0.5)
// y = (1/2)*(sin(-13pi/2*((2x-1)+1))*pow(2,-10(2*x-1)) + 2) | [0.5, 1]
func curveElasticEaseInOut(p:CGFloat) -> CGFloat
{
    if (p < 0.5)
    {
        return 0.5 * sin(13 * CGFloat(M_PI_2) * (2 * p)) * pow(2, 10 * ((2 * p) - 1))
    }
    else
    {
        return 0.5 * (sin(-13 * CGFloat(M_PI_2) * ((2 * p - 1) + 1)) * pow(2, -10 * (2 * p - 1)) + 2)
    }
}

// y = x^3-x*sin(x*pi)
func curveBackEaseIn(p:CGFloat) -> CGFloat
{
    return p * p * p - p * sin(p * CGFloat(M_PI))
}

// y = 1-((1-x)^3-(1-x)*sin((1-x)*pi))
func curveBackEaseOut(p:CGFloat) -> CGFloat
{
    let f = 1 - p
    return 1 - (f * f * f - f * sin(f * CGFloat(M_PI)))
}

// y = (1/2)*((2x)^3-(2x)*sin(2*x*pi))           | [0, 0.5)
// y = (1/2)*(1-((1-x)^3-(1-x)*sin((1-x)*pi))+1) | [0.5, 1]
func curveBackEaseInOut(p:CGFloat) -> CGFloat
{
    if (p < 0.5)
    {
        let f = 2 * p
        return 0.5 * (f * f * f - f * sin(f * CGFloat(M_PI)))
    }
    else
    {
        let f = (1 - (2 * p - 1))
        let sinePortion = sin(f * CGFloat(M_PI))
        return 0.5 * (1 - (f * f * f - f * sinePortion)) + 0.5
    }
}