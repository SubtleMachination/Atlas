//
//  ACMapLoadWindow.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/27/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation
import SpriteKit

class ACMapItem : Equatable
{
    var name:String
    
    init(name:String)
    {
        self.name = name
    }
}

extension ACMapItem : Hashable
{
    var hashValue:Int
    {
        return name.hashValue
    }
}

func ==(lhs:ACMapItem, rhs:ACMapItem) -> Bool
{
    return lhs.name == rhs.name
}

protocol ACMapOpenerDelegate
{
    func loadMap(name:String)
    func closeMapSelectionWindow()
}

class ACScrollViewItem : SKNode
{
    let bg:SKSpriteNode
    let label:SKLabelNode
    let clickable:SKSpriteNode
    
    init(size:CGSize, contents:String)
    {
        bg = SKSpriteNode(imageNamed:"square.png")
        bg.resizeNode(size.width, y:size.height)
        bg.position = CGPointMake(0, 0)
        bg.color = NSColor(red:0.8, green:0.85, blue:0.9, alpha:1.0)
        bg.colorBlendFactor = 1.0
        bg.zPosition = 0
        
        label = SKLabelNode(text:contents)
        label.fontName = "Avenir"
        label.fontSize = CGFloat(14.0)
        label.fontColor = NSColor(red:0.0, green:0.0, blue:0.0, alpha:1.0)
        label.position = CGPointMake(0, -5.0)
        label.zPosition = 1
        
        clickable = SKSpriteNode(imageNamed:"blank.png")
        clickable.resizeNode(size.width, y:size.height)
        clickable.position = CGPointMake(0, 0)
        clickable.zPosition = 2
        
        super.init()
        
        self.addChild(bg)
        self.addChild(label)
        self.addChild(clickable)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}

class ACOpenMapView : SKNode
{
    // Model
    var items:[ACMapItem]
    var selection:ACMapItem?
    
    // Viewmodel
    var listItemSprites:[Int:ACScrollViewItem]
    
    // View
    let bg:SKSpriteNode
    
    let scroll_bg:SKSpriteNode
    let listItemNode:SKNode
    let selectionRect:SKSpriteNode
    
    let preview_bg:SKSpriteNode
    
    let openButton:ACQuickButton
    let cancelButton:ACQuickButton
    
    // Controller
    var delegate:ACMapOpenerDelegate?
    
    init(size:CGSize)
    {
        bg = SKSpriteNode(imageNamed:"square.png")
        bg.resizeNode(size.width, y:size.height)
        bg.position = CGPointMake(0, 0)
        bg.color = NSColor(red:0.5, green:0.55, blue:0.6, alpha:1.0)
        bg.colorBlendFactor = 1.0
        
        let buffer = CGFloat(6.0)
        
        scroll_bg = SKSpriteNode(imageNamed:"square.png")
        let scroll_bg_width = (size.width - (3*buffer)) / 2
        let scroll_bg_height = size.height - (2*buffer)
        scroll_bg.resizeNode(scroll_bg_width, y:scroll_bg_height)
        scroll_bg.position = CGPointMake(-0.5*(buffer + scroll_bg_width), 0)
        scroll_bg.color = NSColor(red:0.05, green:0.1, blue:0.15, alpha:1.0)
        scroll_bg.colorBlendFactor = 1.0
        
        preview_bg = SKSpriteNode(imageNamed:"square.png")
        let preview_bg_width = (size.width - (3*buffer)) / 2
        let preview_bg_height = (size.height - (2*buffer)) / 2
        preview_bg.resizeNode(preview_bg_width, y:preview_bg_height)
        preview_bg.position = CGPointMake(0.5*(buffer + scroll_bg_width), 0)
        preview_bg.color = NSColor(red:0.05, green:0.1, blue:0.15, alpha:1.0)
        preview_bg.colorBlendFactor = 1.0
        
        let buttonSize = CGSizeMake(75.0, 40.0)
        openButton = ACQuickButton(size:buttonSize, color:NSColor.greenColor())
        openButton.position = CGPointMake((size.width / 2)*(1/3), -1*(size.height/2 - 50))
        
        cancelButton = ACQuickButton(size:buttonSize, color:NSColor.redColor())
        cancelButton.position = CGPointMake((size.width / 2)*(2/3), -1*(size.height/2 - 50))
        
        listItemNode = SKNode()
        listItemNode.position = CGPointMake(scroll_bg.position.x, scroll_bg.position.y)
        
        items = [ACMapItem]()
        listItemSprites = [Int:ACScrollViewItem]()
        
        let scrollItemWidth = scroll_bg_width - (2*buffer)
        let scrollItemHeight = CGFloat(25)
        let scrollItemSize = CGSizeMake(scrollItemWidth, scrollItemHeight)
        
        // Retrieve saved maps
        let maps = savedMaps()
        
        for map in maps
        {
            items.append(ACMapItem(name:"\(map)"))
        }
        
        selectionRect = SKSpriteNode(imageNamed:"square.png")
        selectionRect.resizeNode(scrollItemWidth + buffer, y:scrollItemHeight + buffer)
        selectionRect.position = CGPointMake(0, 0)
        selectionRect.alpha = 0.0
        
        super.init()
        
        for (index, item) in items.enumerate()
        {
            // Create a new scrollItemView and place it properly
            let listItemSprite = ACScrollViewItem(size:scrollItemSize, contents:item.name)
            
            let scrollItem_y = (0.5*scroll_bg_height) - buffer - scrollItemHeight/2 - CGFloat(index)*(buffer + scrollItemHeight)
            listItemSprite.position = CGPointMake(0, scrollItem_y)
            
            listItemNode.addChild(listItemSprite)
            listItemSprites[index] = listItemSprite
        }
        
        self.addChild(bg)
        self.addChild(scroll_bg)
        self.addChild(selectionRect)
        self.addChild(listItemNode)
        
        self.addChild(preview_bg)
        self.addChild(openButton)
        self.addChild(cancelButton)
    }
    
    func setMapOpenerDelegate(delegate:ACMapOpenerDelegate)
    {
        self.delegate = delegate
    }
    
    override func mouseDown(event:NSEvent)
    {
        let loc = event.locationInNode(self)
        
        // Check collisions with map list items
        for (index, listItemSprite) in listItemSprites
        {
            if nodeAtPoint(loc) == listItemSprite.clickable
            {
                itemSelected(items[index])
                
                selectionRect.alpha = 1.0
                selectionRect.position = convertPoint(listItemSprite.position, fromNode:listItemNode)
            }
        }
        
        // Check collisions with buttons
        if nodeAtPoint(loc) == openButton.clickable
        {
            openSelection()
        }
        
        if nodeAtPoint(loc) == cancelButton.clickable
        {
            cancel()
        }
    }
    
    func itemSelected(item:ACMapItem)
    {
        selection = item
    }
    
    func openSelection()
    {
        if let currentSelection = selection
        {
            delegate?.loadMap(currentSelection.name)
        }
        
        delegate?.closeMapSelectionWindow()
    }
    
    func cancel()
    {
        delegate?.closeMapSelectionWindow()
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}