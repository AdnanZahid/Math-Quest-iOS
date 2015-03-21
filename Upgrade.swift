//
//  Upgrade.swift
//  MathQuest
//
//  Created by Adnan Zahid on 2/10/15.
//  Copyright (c) 2015 Adnan Zahid. All rights reserved.
//

import SpriteKit

class Upgrade: SKScene {
    
    var width: CGFloat = 0;
    var height: CGFloat = 0;
    
    var scaleX: CGFloat = 0;
    var scaleY: CGFloat = 0;
    
    var buttonRemoveAds: GGButton!;
    var buttonShowDifficulty: GGButton!;
    var buttonBack: GGButton!;
    var buttonColor: SKColor = SKColor(red: 0, green: 0.4784313725, blue: 1, alpha: 0.5);
    var difficultyColor: SKColor = SKColor.whiteColor();
    var progressColor: SKColor = SKColor.whiteColor();
    
    let buttonScaleX: CGFloat = 1;
    let buttonScaleY: CGFloat = 1;
    
    let white = SKColor.whiteColor();
    let fontSize: CGFloat = 40;
    
    var bannerHeight: CGFloat = 0;
    var adMobBannerView: GADBannerView!;
    
    var cake: Difficulty!;
    var medium: Difficulty!;
    var hard: Difficulty!;
    var geek: Difficulty!;
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: CGSize, bannerHeight: CGFloat, bannerView: GADBannerView) {
        super.init(size: size);
        self.bannerHeight = bannerHeight;
        self.adMobBannerView = bannerView;
    }
    
    func switchToCake() {
        cake.label.text = "☑ Cake";
        medium.label.text = "▢ Medium";
        hard.label.text = "▢ Hard";
        geek.label.text = "▢ Geek";
        NSUserDefaults.standardUserDefaults().setInteger(-1, forKey: "difficulty");
        NSUserDefaults.standardUserDefaults().synchronize();
    }
    func switchToMedium() {
        cake.label.text = "▢ Cake";
        medium.label.text = "☑ Medium";
        hard.label.text = "▢ Hard";
        geek.label.text = "▢ Geek";
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "difficulty");
        NSUserDefaults.standardUserDefaults().synchronize();
    }
    func switchToHard() {
        cake.label.text = "▢ Cake";
        medium.label.text = "▢ Medium";
        hard.label.text = "☑ Hard";
        geek.label.text = "▢ Geek";
        NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "difficulty");
        NSUserDefaults.standardUserDefaults().synchronize();
    }
    func switchToGeek() {
        cake.label.text = "▢ Cake";
        medium.label.text = "▢ Medium";
        hard.label.text = "▢ Hard";
        geek.label.text = "☑ Geek";
        NSUserDefaults.standardUserDefaults().setInteger(2, forKey: "difficulty");
        NSUserDefaults.standardUserDefaults().synchronize();
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
        progressLabel.text = "Difficulty:";
        progressLabel.fontSize = 60;
        progressLabel.fontColor = progressColor;
        progressLabel.horizontalAlignmentMode = .Left;
        progressLabel.xScale = scaleX;
        progressLabel.yScale = scaleY;
        progressLabel.position = CGPoint(x:progressLabel.fontSize*scaleX, y:height-progressLabel.fontSize*scaleY*1.5);
        progressLabel.zPosition = 8;
        
        addChild(progressLabel);
        
        cake = Difficulty(text: "▢ Cake", textColor: difficultyColor, buttonAction: switchToCake);
        cake.xScale = scaleX;
        cake.yScale = scaleY;
        cake.zPosition = 8;
        cake.position = CGPoint(x:2.5*cake.label.fontSize*scaleX, y:height-cake.label.fontSize*scaleY*5);
        addChild(cake);
        
        medium = Difficulty(text: "▢ Medium", textColor: difficultyColor, buttonAction: switchToMedium);
        medium.xScale = scaleX;
        medium.yScale = scaleY;
        medium.zPosition = 8;
        medium.position = CGPoint(x:2.5*medium.label.fontSize*scaleX, y:height-cake.label.fontSize*scaleY*7);
        addChild(medium);
        
        hard = Difficulty(text: "▢ Hard", textColor: difficultyColor, buttonAction: switchToHard);
        hard.xScale = scaleX;
        hard.yScale = scaleY;
        hard.zPosition = 8;
        hard.position = CGPoint(x:2.5*medium.label.fontSize*scaleX, y:height-cake.label.fontSize*scaleY*9);
        addChild(hard);
        
        geek = Difficulty(text: "▢ Geek", textColor: difficultyColor, buttonAction: switchToGeek);
        geek.xScale = scaleX;
        geek.yScale = scaleY;
        geek.zPosition = 8;
        geek.position = CGPoint(x:2.5*medium.label.fontSize*scaleX, y:height-cake.label.fontSize*scaleY*11);
        addChild(geek);
        
        if NSUserDefaults.standardUserDefaults().integerForKey("difficulty") == -1 {
            switchToCake();
        }
        else if NSUserDefaults.standardUserDefaults().integerForKey("difficulty") == 0 {
            switchToMedium();
        }
        else if NSUserDefaults.standardUserDefaults().integerForKey("difficulty") == 1 {
            switchToHard();
        }
        else if NSUserDefaults.standardUserDefaults().integerForKey("difficulty") == 2 {
            switchToGeek();
        }
        
        buttonBack = GGButton(scaleX: buttonScaleX, scaleY: buttonScaleY, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "Back", textColor: buttonColor, buttonAction: goToMenuScene);
        buttonBack.xScale = scaleX;
        buttonBack.yScale = scaleY;
        buttonBack.restartLabel.fontSize = 40;
        buttonBack.restartLabel.position.y = buttonBack.defaultButton.position.y - buttonBack.restartLabel.fontSize*0.35;
        buttonBack.position = CGPointMake(width-buttonBack.defaultButton.size.width*scaleX*0.6, buttonBack.defaultButton.size.height*scaleY*0.7);
        addChild(buttonBack);
    }
    func placeLabel(text: NSString, distance: CGFloat, color: SKColor, yCoefficient: CGFloat) {
        let label = SKLabelNode(fontNamed:"ChalkboardSE-Bold");
        label.text = text;
        label.fontSize = fontSize;
        label.fontColor = color;
        label.horizontalAlignmentMode = .Left
        label.position = CGPoint(x:distance, y:height-yCoefficient*label.fontSize*scaleY);
        label.zPosition = 1;
        label.xScale = scaleX;
        label.yScale = scaleY;
        addChild(label);
    }
    func removeAds() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "dontShowAds");
        NSUserDefaults.standardUserDefaults().setFloat(0, forKey: "bannerHeight");
        NSUserDefaults.standardUserDefaults().synchronize();
        
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Left, duration: 2);
        
        let scene = Upgrade(size: size, bannerHeight: CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("bannerHeight")), bannerView: adMobBannerView);
        adMobBannerView.hidden = true;
        scene.scaleMode = .AspectFill;
        
        view?.presentScene(scene, transition: transition);
    }
    func customDifficulty() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "showCustomDifficulty");
        NSUserDefaults.standardUserDefaults().synchronize();
        
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Left, duration: 2);
        
        let scene = Upgrade(size: size, bannerHeight: CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("bannerHeight")), bannerView: adMobBannerView);
        scene.scaleMode = .AspectFill;
        
        view?.presentScene(scene, transition: transition);
    }
    func goToMenuScene() {
        
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Right, duration: 2);
        
        let scene = Menu(size: size, bannerHeight: CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("bannerHeight")), bannerView: adMobBannerView);
        scene.scaleMode = .AspectFill;
        
        view?.presentScene(scene, transition: transition);
    }
}