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
    var textColor: SKColor = SKColor.blue;
    var restartLabel: SKLabelNode!;
    var soundOff: Bool = false;
    
    init(scaleX: CGFloat, scaleY: CGFloat, defaultButtonImage: String, activeButtonImage: String, text: NSString, textColor: SKColor, buttonAction: @escaping () -> Void) {
        defaultButton = SKSpriteNode(imageNamed: defaultButtonImage)
        activeButton = SKSpriteNode(imageNamed: activeButtonImage)
        
        defaultButton.xScale = scaleX;
        defaultButton.yScale = scaleY;
        activeButton.xScale = scaleX;
        activeButton.yScale = scaleY;
        
        defaultButton.zPosition = 14;
        activeButton.zPosition = 15;
        activeButton.isHidden = true
        action = buttonAction
        self.text = text;
        self.textColor = textColor;
        
        super.init()
        
        isUserInteractionEnabled = true
        addChild(defaultButton)
        addChild(activeButton)
        
        restartLabel = SKLabelNode(fontNamed:"ChalkboardSE-Bold");
        restartLabel.text = text as String;
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeButton.isHidden = false
        defaultButton.isHidden = true
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch: UITouch = touches.first else { return }
        let location: CGPoint = touch.location(in: self)

        if defaultButton.contains(location) {
            activeButton.isHidden = false
            defaultButton.isHidden = true
        } else {
            activeButton.isHidden = true
            defaultButton.isHidden = false
        }
    }
    
    func playSound(soundName: NSString) {
        if !UserDefaults.standard.bool(forKey: "soundOff") {
            run(SKAction.playSoundFileNamed(soundName as String+".wav", waitForCompletion: false));
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch: UITouch = touches.first else { return }
        let location: CGPoint = touch.location(in: self)

        if defaultButton.contains(location) {
            action()
            playSound(soundName: "Button");
        }

        activeButton.isHidden = true
        defaultButton.isHidden = false
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
