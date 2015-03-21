//
//  GGButton.swift
//  MathQuest
//
//  Created by Adnan Zahid on 2/12/15.
//  Copyright (c) 2015 Adnan Zahid. All rights reserved.
//

import SpriteKit

class GGButton: SKNode {
    var defaultButton: SKSpriteNode
    var activeButton: SKSpriteNode
    var action: () -> Void
    var text: NSString = "";
    var textColor: SKColor = SKColor.blueColor();
    var restartLabel: SKLabelNode!;
    var soundOff: Bool = false;
    
    init(scaleX: CGFloat, scaleY: CGFloat, defaultButtonImage: String, activeButtonImage: String, text: NSString, textColor: SKColor, buttonAction: () -> Void) {
        defaultButton = SKSpriteNode(imageNamed: defaultButtonImage)
        activeButton = SKSpriteNode(imageNamed: activeButtonImage)
        
        defaultButton.xScale = scaleX;
        defaultButton.yScale = scaleY;
        activeButton.xScale = scaleX;
        activeButton.yScale = scaleY;
        
        defaultButton.zPosition = 14;
        activeButton.zPosition = 15;
        activeButton.hidden = true
        action = buttonAction
        self.text = text;
        self.textColor = textColor;
        
        super.init()
        
        userInteractionEnabled = true
        addChild(defaultButton)
        addChild(activeButton)
        
        restartLabel = SKLabelNode(fontNamed:"ChalkboardSE-Bold");
        restartLabel.text = text;
        restartLabel.fontSize = 50*scaleY;
        restartLabel.fontColor = textColor;
        restartLabel.position.x = defaultButton.position.x;
        restartLabel.position.y = defaultButton.position.y - restartLabel.fontSize*0.35;
        restartLabel.zPosition = 15;
        addChild(restartLabel);
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #if os(iOS)
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        activeButton.hidden = false
        defaultButton.hidden = true
    }

    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        var touch: UITouch = touches.allObjects[0] as UITouch
        var location: CGPoint = touch.locationInNode(self)

        if defaultButton.containsPoint(location) {
            activeButton.hidden = false
            defaultButton.hidden = true
        } else {
            activeButton.hidden = true
            defaultButton.hidden = false
        }
    }
    
    func playSound(soundName: NSString) {
        if !NSUserDefaults.standardUserDefaults().boolForKey("soundOff") {
            runAction(SKAction.playSoundFileNamed(soundName+".wav", waitForCompletion: false));
        }
    }
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        var touch: UITouch = touches.allObjects[0] as UITouch
        var location: CGPoint = touch.locationInNode(self)

        if defaultButton.containsPoint(location) {
            action()
            playSound("Button");
        }

        activeButton.hidden = true
        defaultButton.hidden = false
    }
    #else
    override func mouseDown(theEvent: NSEvent) {
        
        var location: CGPoint = theEvent.locationInNode(self);
        
        if defaultButton.containsPoint(location) {
            activeButton.hidden = false;
            defaultButton.hidden = true;
        } else {
            activeButton.hidden = true;
            defaultButton.hidden = false;
        }
    }
    
    override func mouseMoved(theEvent: NSEvent) {
        
        var location: CGPoint = theEvent.locationInNode(self);
        
        if defaultButton.containsPoint(location) {
            activeButton.hidden = false;
            defaultButton.hidden = true;
        } else {
            activeButton.hidden = true;
            defaultButton.hidden = false;
        }
    }
    
    override func mouseUp(theEvent: NSEvent) {
        
        var location: CGPoint = theEvent.locationInNode(self);
        
        if defaultButton.containsPoint(location) {
            action();
            playSound("Button");
        }
    
        activeButton.hidden = true;
        defaultButton.hidden = false;
    }
    
    override func mouseExited(theEvent: NSEvent) {
        
        var location: CGPoint = theEvent.locationInNode(self);
        
        if defaultButton.containsPoint(location) {
            action();
            playSound("Button");
        }
    
        activeButton.hidden = true;
        defaultButton.hidden = false;
    }
    #endif
}