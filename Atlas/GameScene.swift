//
//  GameScene.swift
//  Atlas
//
//  Created by Alicia Cicon on 9/30/15.
//  Copyright (c) 2015 Runemark. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    override init(size:CGSize) {
        super.init(size:size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
    }
    
    override func mouseDown(theEvent: NSEvent) {
//        let location = theEvent.locationInNode(self)
    }
    
    override func update(currentTime: CFTimeInterval) {
    }
}
