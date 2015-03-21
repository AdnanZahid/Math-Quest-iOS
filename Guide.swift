//
//  GlobalScores.swift
//  MathQuest
//
//  Created by Adnan Zahid on 2/10/15.
//  Copyright (c) 2015 Adnan Zahid. All rights reserved.
//

import SpriteKit

class Guide: SKScene {
    
    var width: CGFloat = 0;
    var height: CGFloat = 0;
    
    var scaleX: CGFloat = 0;
    var scaleY: CGFloat = 0;
    
    let yShift: CGFloat = 90;
    
    var button: GGButton!;
    var buttonSound: GGButton!;
    var buttonColor: SKColor = SKColor(red: 0, green: 0.4784313725, blue: 1, alpha: 0.5);
    var progressColor: SKColor = SKColor.whiteColor();
    
    let buttonScaleX: CGFloat = 1;
    let buttonScaleY: CGFloat = 1;
    
    let white = SKColor.whiteColor();
    let fontSize: CGFloat = 40;
    
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
        
        button = GGButton(scaleX: buttonScaleX*1.6, scaleY: buttonScaleY, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "Tutorial", textColor: buttonColor, buttonAction: demo);
        button.xScale = scaleX;
        button.yScale = scaleY;
        button.restartLabel.fontSize = 40;
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize*0.35;
        button.position = CGPointMake(button.defaultButton.size.width*scaleX*0.6, button.defaultButton.size.height*scaleY*0.7);
        addChild(button);
        
        button = GGButton(scaleX: buttonScaleX, scaleY: buttonScaleY, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "Back", textColor: buttonColor, buttonAction: goToMenuScene);
        button.xScale = scaleX;
        button.yScale = scaleY;
        button.restartLabel.fontSize = 40;
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize*0.35;
        button.position = CGPointMake(width-button.defaultButton.size.width*scaleX*0.6, button.defaultButton.size.height*scaleY*0.7);
        addChild(button);
        
        let progressLabel = SKLabelNode(fontNamed:"Chalkduster");
        progressLabel.text = "Guide:";
        progressLabel.fontSize = 60;
        progressLabel.fontColor = progressColor;
        progressLabel.horizontalAlignmentMode = .Left;
        progressLabel.xScale = scaleX;
        progressLabel.yScale = scaleY;
        progressLabel.position = CGPoint(x:progressLabel.fontSize*scaleX, y:height-progressLabel.fontSize*scaleY*1.5);
        progressLabel.zPosition = 8;
        
        addChild(progressLabel);
        
        placeLabel("1) Tap the screen to fly.", distance: progressLabel.fontSize*scaleX, color: white, yCoefficient: 1.5);
        placeLabel("2) Collect numbers and coins.", distance: progressLabel.fontSize*scaleX, color: white, yCoefficient: 3);
        placeLabel("3) Calculate your own score.", distance: progressLabel.fontSize*scaleX, color: white, yCoefficient: 4.5);
    }
    func demo() {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "notFirstTime");
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "notFirstTimeGoldenNumbers");
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "notFirstTimeRememberScore");
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "notFirstTimeMath");
        NSUserDefaults.standardUserDefaults().synchronize();
        
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Left, duration: 2);
        
        let scene = GameScene(size: size, bannerHeight: CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("bannerHeight")), bannerView: adMobBannerView);
        scene.scaleMode = .AspectFill;
        
        view?.presentScene(scene, transition: transition);
    }
    func placeLabel(text: NSString, distance: CGFloat, color: SKColor, yCoefficient: CGFloat) {
        let label = SKLabelNode(fontNamed:"ChalkboardSE-Bold");
        label.text = text;
        label.fontSize = fontSize;
        label.fontColor = color;
        label.horizontalAlignmentMode = .Left
        label.position = CGPoint(x:distance, y:height-yCoefficient*label.fontSize*scaleY - yShift*scaleY);
        label.zPosition = 1;
        label.xScale = scaleX;
        label.yScale = scaleY;
        addChild(label);
    }
    func goToMenuScene() {
        
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Right, duration: 2);
        
        let scene = Home(size: size, bannerHeight: CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("bannerHeight")), bannerView: adMobBannerView);
        scene.scaleMode = .AspectFill;
        
        view?.presentScene(scene, transition: transition);
    }
}