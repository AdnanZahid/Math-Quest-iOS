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
    var progressColor: SKColor = SKColor.white;
    
    let buttonScaleX: CGFloat = 1;
    let buttonScaleY: CGFloat = 1;
    
    let white = SKColor.white;
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
    
    override func didMove(to view: SKView) {
        
        width = frame.maxX;
        height = frame.maxY;
        
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
        button.position = CGPoint(x: button.defaultButton.size.width*scaleX*0.6,
                                  y: button.defaultButton.size.height*scaleY*0.7);
        addChild(button);
        
        button = GGButton(scaleX: buttonScaleX, scaleY: buttonScaleY, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "Back", textColor: buttonColor, buttonAction: goToMenuScene);
        button.xScale = scaleX;
        button.yScale = scaleY;
        button.restartLabel.fontSize = 40;
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize*0.35;
        button.position = CGPoint(x: width-button.defaultButton.size.width*scaleX*0.6,
                                  y: button.defaultButton.size.height*scaleY*0.7);
        addChild(button);
        
        let progressLabel = SKLabelNode(fontNamed:"Chalkduster");
        progressLabel.text = "Guide:";
        progressLabel.fontSize = 60;
        progressLabel.fontColor = progressColor;
        progressLabel.horizontalAlignmentMode = .left;
        progressLabel.xScale = scaleX;
        progressLabel.yScale = scaleY;
        progressLabel.position = CGPoint(x:progressLabel.fontSize*scaleX, y:height-progressLabel.fontSize*scaleY*1.5);
        progressLabel.zPosition = 8;
        
        addChild(progressLabel);
        
        placeLabel(text: "1) Tap the screen to fly.", distance: progressLabel.fontSize*scaleX, color: white, yCoefficient: 1.5);
        placeLabel(text: "2) Collect numbers and coins.", distance: progressLabel.fontSize*scaleX, color: white, yCoefficient: 3);
        placeLabel(text: "3) Calculate your own score.", distance: progressLabel.fontSize*scaleX, color: white, yCoefficient: 4.5);
    }
    func demo() {
        UserDefaults.standard.set(false, forKey: "notFirstTime");
        UserDefaults.standard.set(false, forKey: "notFirstTimeGoldenNumbers");
        UserDefaults.standard.set(false, forKey: "notFirstTimeRememberScore");
        UserDefaults.standard.set(false, forKey: "notFirstTimeMath");
        UserDefaults.standard.synchronize();
        
        let transition = SKTransition.reveal(with: SKTransitionDirection.left, duration: 2);
        
        let scene = GameScene(size: size, bannerHeight: CGFloat(UserDefaults.standard.float(forKey: "bannerHeight")), bannerView: adMobBannerView);
        scene.scaleMode = .aspectFill;
        
        view?.presentScene(scene, transition: transition);
    }
    func placeLabel(text: NSString, distance: CGFloat, color: SKColor, yCoefficient: CGFloat) {
        let label = SKLabelNode(fontNamed:"ChalkboardSE-Bold");
        label.text = text as String;
        label.fontSize = fontSize;
        label.fontColor = color;
        label.horizontalAlignmentMode = .left
        label.position = CGPoint(x:distance, y:height-yCoefficient*label.fontSize*scaleY - yShift*scaleY);
        label.zPosition = 1;
        label.xScale = scaleX;
        label.yScale = scaleY;
        addChild(label);
    }
    func goToMenuScene() {
        
        let transition = SKTransition.reveal(with: SKTransitionDirection.right, duration: 2);
        
        let scene = Home(size: size, bannerHeight: CGFloat(UserDefaults.standard.float(forKey: "bannerHeight")), bannerView: adMobBannerView);
        scene.scaleMode = .aspectFill;
        
        view?.presentScene(scene, transition: transition);
    }
}
