//
//  Menu.swift
//  MathQuest
//
//  Created by Adnan Zahid on 2/10/15.
//  Copyright (c) 2015 Adnan Zahid. All rights reserved.
//

import SpriteKit

class Menu: SKScene {
    
    var width: CGFloat = 0;
    var height: CGFloat = 0;
    
    var scaleX: CGFloat = 0;
    var scaleY: CGFloat = 0;
    
    var button: GGButton!;
    var buttonSound: GGButton!;
    var buttonColor: SKColor = SKColor(red: 0, green: 0.4784313725, blue: 1, alpha: 0.5);
    var progressColor: SKColor = SKColor.whiteColor();
    
    let buttonScaleX: CGFloat = 1;
    let buttonScaleY: CGFloat = 1;
    
    var bannerHeight: CGFloat = 0;
    var adMobBannerView: GADBannerView!;
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: CGSize, bannerHeight: CGFloat, bannerView: GADBannerView) {
        super.init(size: size);
        self.bannerHeight = bannerHeight;
        self.adMobBannerView = bannerView;
    }
    
    override func didMoveToView(view: SKView) {
        
        width = CGRectGetMaxX(frame);
        height = CGRectGetMaxY(frame);
        
        height -= bannerHeight;
        
        let background = SKSpriteNode(imageNamed:"blackboard");
        scaleX = width/background.size.width;
        scaleY = height/background.size.height;
        background.xScale = scaleX;
        background.yScale = scaleY;
        background.position = CGPoint(x:width/2, y:height/2);
        background.zPosition = 0;
        addChild(background);
        
        let progressLabel = SKLabelNode(fontNamed:"Chalkduster");
        progressLabel.text = "Menu:";
        progressLabel.fontSize = 60;
        progressLabel.fontColor = progressColor;
        progressLabel.horizontalAlignmentMode = .Left;
        progressLabel.xScale = scaleX;
        progressLabel.yScale = scaleY;
        progressLabel.position = CGPoint(x:progressLabel.fontSize*scaleX, y:height-progressLabel.fontSize*scaleY*1.5);
        progressLabel.zPosition = 8;
        
        addChild(progressLabel);
        
        buttonSound = GGButton(scaleX: buttonScaleX, scaleY: buttonScaleY, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "Audio", textColor: buttonColor, buttonAction: goToAudioScene);
        buttonSound.xScale = scaleX;
        buttonSound.yScale = scaleY;
        buttonSound.restartLabel.fontSize = 30;
        buttonSound.restartLabel.position.y = buttonSound.defaultButton.position.y - buttonSound.restartLabel.fontSize*0.35;
        buttonSound.position = CGPointMake(buttonSound.defaultButton.size.width*scaleX, height-1.5*buttonSound.defaultButton.size.height*scaleY);
        addChild(buttonSound);
        
        button = GGButton(scaleX: buttonScaleX, scaleY: buttonScaleY, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "Highscores", textColor: buttonColor, buttonAction: goToLocalScoresScene);
        button.xScale = scaleX;
        button.yScale = scaleY;
        button.restartLabel.fontSize = 30;
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize*0.35;
        button.position = CGPointMake(width-button.defaultButton.size.width*scaleX, height-1.5*button.defaultButton.size.height*scaleY);
        addChild(button);
        
        button = GGButton(scaleX: buttonScaleX, scaleY: buttonScaleY, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "Difficulty", textColor: buttonColor, buttonAction: goToUpgradeScene);
        button.xScale = scaleX;
        button.yScale = scaleY;
        button.restartLabel.fontSize = 30;
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize*0.35;
        button.position = CGPointMake(button.defaultButton.size.width*scaleX, button.defaultButton.size.height*scaleY);
        addChild(button);
        
        button = GGButton(scaleX: buttonScaleX, scaleY: buttonScaleY, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "Back", textColor: buttonColor, buttonAction: goToHomeScene);
        button.xScale = scaleX;
        button.yScale = scaleY;
        button.restartLabel.fontSize = 30;
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize*0.35;
        button.position = CGPointMake(width-button.defaultButton.size.width*scaleX, button.defaultButton.size.height*scaleY);
        addChild(button);
    }
    func goToLocalScoresScene() {
        
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Left, duration: 2);
        
        let scene = LocalScores(size: size, bannerHeight: CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("bannerHeight")), bannerView: adMobBannerView);
        scene.scaleMode = .AspectFill;
        
        view?.presentScene(scene, transition: transition);
    }
    func goToAudioScene() {
        
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Left, duration: 2);
        
        let scene = Audio(size: size, bannerHeight: CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("bannerHeight")), bannerView: adMobBannerView);
        scene.scaleMode = .AspectFill;
        
        view?.presentScene(scene, transition: transition);
    }
    func goToUpgradeScene() {
        
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Left, duration: 2);
        
        let scene = Upgrade(size: size, bannerHeight: CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("bannerHeight")), bannerView: adMobBannerView);
        scene.scaleMode = .AspectFill;
        
        view?.presentScene(scene, transition: transition);
    }
    func goToHomeScene() {
        
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Right, duration: 2);
        
        let scene = Home(size: size, bannerHeight: CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("bannerHeight")), bannerView: adMobBannerView);
        scene.scaleMode = .AspectFill;
        
        view?.presentScene(scene, transition: transition);
    }
}