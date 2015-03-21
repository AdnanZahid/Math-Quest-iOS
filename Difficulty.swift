//
//  Difficulty.swift
//  MathQuest
//
//  Created by Adnan Zahid on 2/19/15.
//  Copyright (c) 2015 Adnan Zahid. All rights reserved.
//

import SpriteKit

class Difficulty: SKNode {
    
    var text: NSString = "";
    var textColor: SKColor = SKColor.blueColor();
    var label: SKLabelNode!;
    var action: () -> Void
    
    init(text: NSString, textColor: SKColor, buttonAction: () -> Void) {
        self.text = text;
        self.textColor = textColor;
        action = buttonAction
        
        super.init()
        
        label = SKLabelNode(fontNamed:"Chalkduster");
        label.text = text;
        label.fontSize = 33;
        label.fontColor = textColor;
        label.horizontalAlignmentMode = .Left;
        label.zPosition = 8;
        userInteractionEnabled = true;
        
        addChild(label);
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #if os(iOS)
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        var touch: UITouch = touches.allObjects[0] as UITouch
        var location: CGPoint = touch.locationInNode(self)
        
        if label.containsPoint(location) {
            action()
        }
    }
    #else
    override func mouseDown(theEvent: NSEvent) {
        var location: CGPoint = theEvent.locationInNode(self);
    
        if label.containsPoint(location) {
            action();
        }
    }
    
    #endif
}