//
//  ACSaveMapView.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/29/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation
import SpriteKit

protocol ACMapSaverDelegate
{
    func saveMapWithName(name:String)
    func closeSaveMapWindow()
}

class ACSaveMapView : SKNode
{
    // Model
    var newName:String
    
    // Viewmodel
    
    // View
    let bg:SKSpriteNode
    
    let saveButton:ACQuickButton
    let cancelButton:ACQuickButton
    
    let nameLabel:SKLabelNode
    
    // Controller
    var delegate:ACMapSaverDelegate?
    
    init(size:CGSize)
    {
        newName = "Default"
        
        bg = SKSpriteNode(imageNamed:"square.png")
        bg.resizeNode(size.width, y:size.height)
        bg.position = CGPointMake(0, 0)
        bg.color = NSColor(red:0.8, green:0.85, blue:0.9, alpha:1.0)
        bg.colorBlendFactor = 1.0
        bg.zPosition = 0
        
        let buttonSize = CGSizeMake(75.0, 40.0)
        
        saveButton = ACQuickButton(size:buttonSize, color:NSColor.greenColor())
        saveButton.position = CGPointMake(size.width*(-1/4), size.height*(-5/16))
        
        cancelButton = ACQuickButton(size:buttonSize, color:NSColor.redColor())
        cancelButton.position = CGPointMake(size.width*(1/4), size.height*(-5/16))
        
        nameLabel = SKLabelNode(text:newName)
        nameLabel.position = CGPointMake(size.width/2, size.height/2)
        
        super.init()
        
        self.addChild(bg)
        self.addChild(saveButton)
        self.addChild(cancelButton)
    }
    
    func setSaveWindowDelegate(delegate:ACMapSaverDelegate)
    {
        self.delegate = delegate
    }
    
    override func mouseDown(event:NSEvent)
    {
        let loc = event.locationInNode(self)
        
        if nodeAtPoint(loc) == saveButton.clickable
        {
            delegate?.saveMapWithName(newName)
        }
        
        if nodeAtPoint(loc) == cancelButton.clickable
        {
            delegate?.closeSaveMapWindow()
        }
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
