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



class ACScrollViewItem : SKNode
{
    let bg:SKSpriteNode
    let label:SKLabelNode
    
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
        
        super.init()
        
        self.addChild(bg)
        self.addChild(label)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}

class ACOpenMapView : SKNode
{
    let bg:SKSpriteNode
    let scroll_bg:SKSpriteNode
    let itemsView:SKNode
    
    var items:[ACMapItem]
    
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
        
        itemsView = SKNode()
        itemsView.position = CGPointMake(scroll_bg.position.x, scroll_bg.position.y)
        
        items = [ACMapItem]()
        
        let scrollItemWidth = scroll_bg_width - (2*buffer)
        let scrollItemHeight = CGFloat(25)
        let scrollItemSize = CGSizeMake(scrollItemWidth, scrollItemHeight)
        
        // Retrieve saved maps
        let maps = savedMaps()
        
        for map in maps
        {
            items.append(ACMapItem(name:"\(map)"))
        }
        
        for (index, item) in items.enumerate()
        {
            // Create a new scrollItemView and place it properly
            let scrollItem = ACScrollViewItem(size:scrollItemSize, contents:item.name)
            
            let scrollItem_y = (0.5*scroll_bg_height) - buffer - scrollItemHeight/2 - CGFloat(index)*(buffer + scrollItemHeight)
            scrollItem.position = CGPointMake(0, scrollItem_y)
            
            itemsView.addChild(scrollItem)
        }
        
        super.init()
        
        self.addChild(bg)
        self.addChild(scroll_bg)
        self.addChild(itemsView)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}