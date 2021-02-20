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
    var textColor: SKColor = SKColor.blue;
    var label: SKLabelNode!;
    var action: () -> Void
    
    init(text: NSString, textColor: SKColor, buttonAction: @escaping () -> Void) {
        self.text = text;
        self.textColor = textColor;
        action = buttonAction
        
        super.init()
        
        label = SKLabelNode(fontNamed:"Chalkduster");
        label.text = text as String;
        label.fontSize = 33;
        label.fontColor = textColor;
        label.horizontalAlignmentMode = .left;
        label.zPosition = 8;
        isUserInteractionEnabled = true;
        
        addChild(label);
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch: UITouch = touches.first else { return }
        let location: CGPoint = touch.location(in: self)
        
        if label.contains(location) {
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
