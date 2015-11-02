//
//  ACNewMapView.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/28/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation
import SpriteKit

protocol ACMapCreatorDelegate
{
    func createMapWithDimensions(x:Int, y:Int)
    func closeNewMapWindow()
}

class ACNewMapView : SKNode
{
    // Model
    
    // Viewmodel
    
    // View
    let bg:SKSpriteNode
    
    let createButton:ACQuickButton
    let cancelButton:ACQuickButton
    
    let x_bg:SKSpriteNode
    let y_bg:SKSpriteNode
    
    var xValue = 0
    var yValue = 0
    
    let xLabel:SKLabelNode
    let yLabel:SKLabelNode
    
    let xIncrementButton:ACQuickButton
    let xDecrementButton:ACQuickButton

    let yIncrementButton:ACQuickButton
    let yDecrementButton:ACQuickButton
    
    // Controller
    var delegate:ACMapCreatorDelegate?
    
    init(size:CGSize)
    {
        bg = SKSpriteNode(imageNamed:"square.png")
        bg.resizeNode(size.width, y:size.height)
        bg.position = CGPointMake(0, 0)
        bg.color = NSColor(red:0.8, green:0.85, blue:0.9, alpha:1.0)
        bg.colorBlendFactor = 1.0
        bg.zPosition = 0
        
        let buttonSize = CGSizeMake(75.0, 40.0)
        
        createButton = ACQuickButton(size:buttonSize, color:NSColor.greenColor())
        createButton.position = CGPointMake(size.width*(-1/4), size.height*(-5/16))
        
        cancelButton = ACQuickButton(size:buttonSize, color:NSColor.redColor())
        cancelButton.position = CGPointMake(size.width*(1/4), size.height*(-5/16))
        
        let outerBuffer = CGFloat(25)
        let dim_bg_width = size.width*(1/2) - 2*outerBuffer
        let dim_bg_height = size.height*(3/4) - 2*outerBuffer
        
        x_bg = SKSpriteNode(imageNamed:"square.png")
        x_bg.resizeNode(dim_bg_width, y:dim_bg_height)
        x_bg.position = CGPointMake(size.width*(-1/4), size.height*(1/8))
        x_bg.color = NSColor(red:0.1, green:0.15, blue:0.2, alpha:1.0)
        x_bg.colorBlendFactor = 1.0
        x_bg.zPosition = 1
        
        y_bg = SKSpriteNode(imageNamed:"square.png")
        y_bg.resizeNode(dim_bg_width, y:dim_bg_height)
        y_bg.position = CGPointMake(size.width*(1/4), size.height*(1/8))
        y_bg.color = NSColor(red:0.1, green:0.15, blue:0.2, alpha:1.0)
        y_bg.colorBlendFactor = 1.0
        y_bg.zPosition = 1
        
        xLabel = SKLabelNode(text:"\(xValue)")
        xLabel.fontColor = NSColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
        xLabel.fontSize = CGFloat(26.0)
        xLabel.fontName = "Avenir"
        xLabel.position = CGPointMake(x_bg.position.x - dim_bg_width*(1/4), x_bg.position.y)
        xLabel.zPosition = 2
        
        yLabel = SKLabelNode(text:"\(yValue)")
        yLabel.fontColor = NSColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
        yLabel.fontSize = CGFloat(26.0)
        yLabel.fontName = "Avenir"
        yLabel.position = CGPointMake(y_bg.position.x - dim_bg_width*(1/4), y_bg.position.y)
        yLabel.zPosition = 2
        
        let adjustmentButtonSize = CGSizeMake(25, 25)
        xIncrementButton = ACQuickButton(size:adjustmentButtonSize, color:NSColor.greenColor())
        xIncrementButton.position = CGPointMake(xLabel.position.x + dim_bg_width*(1/2), xLabel.position.y + dim_bg_height*(1/8))
        xIncrementButton.zPosition = 2
        
        xDecrementButton = ACQuickButton(size:adjustmentButtonSize, color:NSColor.redColor())
        xDecrementButton.position = CGPointMake(xLabel.position.x + dim_bg_width*(1/2), xLabel.position.y - dim_bg_height*(1/8))
        xDecrementButton.zPosition = 2
        
        yIncrementButton = ACQuickButton(size:adjustmentButtonSize, color:NSColor.greenColor())
        yIncrementButton.position = CGPointMake(yLabel.position.x + dim_bg_width*(1/2), yLabel.position.y + dim_bg_height*(1/8))
        yIncrementButton.zPosition = 2
        
        yDecrementButton = ACQuickButton(size:adjustmentButtonSize, color:NSColor.redColor())
        yDecrementButton.position = CGPointMake(yLabel.position.x + dim_bg_width*(1/2), yLabel.position.y - dim_bg_height*(1/8))
        yDecrementButton.zPosition = 2
        
        super.init()
        
        self.addChild(bg)
        self.addChild(x_bg)
        self.addChild(y_bg)
        self.addChild(xLabel)
        self.addChild(yLabel)
        
        self.addChild(xIncrementButton)
        self.addChild(xDecrementButton)
        self.addChild(yIncrementButton)
        self.addChild(yDecrementButton)
        
        self.addChild(createButton)
        self.addChild(cancelButton)
    }
    
    override func mouseDown(event:NSEvent)
    {
        let loc = event.locationInNode(self)
        
        if nodeAtPoint(loc) == createButton.clickable
        {
            create()
        }
        
        if nodeAtPoint(loc) == cancelButton.clickable
        {
            cancel()
        }
        
        if nodeAtPoint(loc) == xIncrementButton.clickable
        {
            xValue++
            updateLabels()
        }
        
        if nodeAtPoint(loc) == xDecrementButton.clickable
        {
            xValue--
            
            if (xValue < 0)
            {
                xValue == 0
            }
            
            updateLabels()
        }
        
        if nodeAtPoint(loc) == yIncrementButton.clickable
        {
            yValue++
            updateLabels()
        }
        
        if nodeAtPoint(loc) == yDecrementButton.clickable
        {
            yValue--
            
            if (yValue < 0)
            {
                yValue == 0
            }
            
            updateLabels()
        }
    }
    
    func updateLabels()
    {
        xLabel.text = "\(xValue)"
        yLabel.text = "\(yValue)"
    }
    
    func create()
    {
        delegate?.createMapWithDimensions(xValue, y:yValue)
    }
    
    func cancel()
    {
        delegate?.closeNewMapWindow()
    }
    
    func setNewWindowDelegate(delegate:ACMapCreatorDelegate)
    {
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}