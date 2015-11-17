//
//  ACHoverButton.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/24/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation
import SpriteKit

enum ButtonStatus
{
    case NONE, HOVER, DOWN
}

protocol ButtonDelegate
{
    func trigger(identifier:String)
}

class ACHoverButton : SKNode
{
    let identifier:String
    var delegate:ButtonDelegate?
    
    let bg:SKSpriteNode
    let icon:SKSpriteNode
    let glow:SKSpriteNode
    let clickable:SKSpriteNode
    
    var status:ButtonStatus = .NONE
    
    init(size:CGSize, iconName:String, identifier:String)
    {
        self.identifier = identifier
        
        bg = SKSpriteNode(imageNamed:"smooth_square.png")
        icon = SKSpriteNode(imageNamed:iconName)
        glow = SKSpriteNode(imageNamed:"smooth_square.png")
        clickable = SKSpriteNode(imageNamed:"blank.png")
        
        let buttonBgColor = NSColor(red:0.15, green:0.15, blue:0.15, alpha:1.0)
        
        bg.resizeNode(size.width, y:size.height)
        bg.position = CGPointMake(0, 0)
        bg.color = buttonBgColor
        bg.colorBlendFactor = 1.0
        
        icon.resizeNode(size.width, y:size.height)
        icon.position = CGPointMake(0, 0)
        icon.color = NSColor(red:0.9, green:0.9, blue:0.9, alpha:1.0)
        icon.colorBlendFactor = 1.0
        
        glow.resizeNode(size.width, y:size.height)
        glow.position = CGPointMake(0, 0)
        glow.alpha = 0.0
        
        clickable.resizeNode(size.width, y:size.height)
        clickable.position = CGPointMake(0, 0)
        
        super.init()
        
        self.addChild(bg)
        self.addChild(icon)
        self.addChild(glow)
        self.addChild(clickable)
    }
    
    func switchIcon(newIconName:String)
    {
        icon.texture = SKTexture(imageNamed:"\(newIconName).png")
    }
    
    func setButtonDelegate(delegate:ButtonDelegate)
    {
        self.delegate = delegate
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Mouse Responder Methods
    //////////////////////////////////////////////////////////////////////////////////////////
    
    override func mouseDown(event:NSEvent)
    {
        let loc = event.locationInNode(self)
        
        if (self.nodeAtPoint(loc) == clickable)
        {
            status = .DOWN
        }
    }
    
    override func mouseUp(event:NSEvent)
    {
        let loc = event.locationInNode(self)
        
        if (self.nodeAtPoint(loc) == clickable)
        {
            status = .HOVER
            trigger()
        }
    }
    
    override func mouseMoved(event:NSEvent)
    {
        let loc = event.locationInNode(self)
        
        if (self.nodeAtPoint(loc) == clickable)
        {
            if (status == .NONE)
            {
                buttonGainedFocus()
            }
        }
        else if (status == .HOVER || status == .DOWN)
        {
            buttonLostFocus()
        }
    }    
    
    func buttonGainedFocus()
    {
        status = .HOVER
        
        glow.removeAllActions()
        
        let fadeAction = fadeTo(glow, alpha:0.5, duration:0.25, type:CurveType.QUADRATIC_OUT)
        glow.runAction(fadeAction)
    }
    
    func buttonLostFocus()
    {
        status = .NONE
        
        glow.removeAllActions()
        
        let fadeAction = fadeTo(glow, alpha:0.0, duration:0.5, type:CurveType.QUADRATIC_IN)
        glow.runAction(fadeAction)
    }
    
    func trigger()
    {
        delegate?.trigger(identifier)
    }
}