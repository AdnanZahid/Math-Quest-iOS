//
//  Audio.swift
//  MathQuest
//
//  Created by Adnan Zahid on 2/21/15.
//  Copyright (c) 2015 Adnan Zahid. All rights reserved.
//

import SpriteKit

class Audio: SKScene {
    
    var width: CGFloat = 0;
    var height: CGFloat = 0;
    
    var scaleX: CGFloat = 0;
    var scaleY: CGFloat = 0;
    
    var buttonRemoveAds: GGButton!;
    var buttonShowDifficulty: GGButton!;
    var buttonBack: GGButton!;
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
        
        let progressLabel = SKLabelNode(fontNamed:"Chalkduster");
        progressLabel.text = "Audio:";
        progressLabel.fontSize = 60;
        progressLabel.fontColor = progressColor;
        progressLabel.horizontalAlignmentMode = .left;
        progressLabel.xScale = scaleX;
        progressLabel.yScale = scaleY;
        progressLabel.position = CGPoint(x:progressLabel.fontSize*scaleX, y:height-progressLabel.fontSize*scaleY*1.5);
        progressLabel.zPosition = 8;
        
        addChild(progressLabel);
        
        if UserDefaults.standard.bool(forKey: "soundOff") {
            
            buttonRemoveAds = GGButton(scaleX: buttonScaleX*1.6, scaleY: buttonScaleY, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "Sound is off", textColor: buttonColor, buttonAction: toggleSound);
            buttonRemoveAds.xScale = scaleX;
            buttonRemoveAds.yScale = scaleY;
            buttonRemoveAds.restartLabel.fontSize = 40;
            buttonRemoveAds.restartLabel.position.y = buttonRemoveAds.defaultButton.position.y - buttonRemoveAds.restartLabel.fontSize*0.35;
            buttonRemoveAds.position = CGPoint(x: buttonRemoveAds.defaultButton.size.width*scaleX*0.6,
                                               y: height-2.5*buttonRemoveAds.defaultButton.size.height*scaleY*0.7);
            addChild(buttonRemoveAds);
        }
        else {
            buttonRemoveAds = GGButton(scaleX: buttonScaleX*1.6, scaleY: buttonScaleY, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "Sound is on", textColor: buttonColor, buttonAction: toggleSound);
            buttonRemoveAds.xScale = scaleX;
            buttonRemoveAds.yScale = scaleY;
            buttonRemoveAds.restartLabel.fontSize = 40;
            buttonRemoveAds.restartLabel.position.y = buttonRemoveAds.defaultButton.position.y - buttonRemoveAds.restartLabel.fontSize*0.35;
            buttonRemoveAds.position = CGPoint(x: buttonRemoveAds.defaultButton.size.width*scaleX*0.6,
                                               y: height-2.5*buttonRemoveAds.defaultButton.size.height*scaleY*0.7);
            addChild(buttonRemoveAds);
        }
        
        if UserDefaults.standard.bool(forKey: "musicOff") {
            
            buttonShowDifficulty = GGButton(scaleX: buttonScaleX*1.6, scaleY: buttonScaleY, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "Music is off", textColor: buttonColor, buttonAction: toggleMusic);
            buttonShowDifficulty.xScale = scaleX;
            buttonShowDifficulty.yScale = scaleY;
            buttonShowDifficulty.restartLabel.fontSize = 40;
            buttonShowDifficulty.restartLabel.position.y = buttonShowDifficulty.defaultButton.position.y - buttonShowDifficulty.restartLabel.fontSize*0.35;
            buttonShowDifficulty.position = CGPoint(x: buttonShowDifficulty.defaultButton.size.width*scaleX*0.6,
                                                    y: buttonShowDifficulty.defaultButton.size.height*scaleY*0.7);
            addChild(buttonShowDifficulty);
        }
        else {
            buttonShowDifficulty = GGButton(scaleX: buttonScaleX*1.6, scaleY: buttonScaleY, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "Music is on", textColor: buttonColor, buttonAction: toggleMusic);
            buttonShowDifficulty.xScale = scaleX;
            buttonShowDifficulty.yScale = scaleY;
            buttonShowDifficulty.restartLabel.fontSize = 40;
            buttonShowDifficulty.restartLabel.position.y = buttonShowDifficulty.defaultButton.position.y - buttonShowDifficulty.restartLabel.fontSize*0.35;
            buttonShowDifficulty.position = CGPoint(x: buttonShowDifficulty.defaultButton.size.width*scaleX*0.6,
                                                    y: buttonShowDifficulty.defaultButton.size.height*scaleY*0.7);
            addChild(buttonShowDifficulty);
        }
        
        buttonBack = GGButton(scaleX: buttonScaleX, scaleY: buttonScaleY, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "Back", textColor: buttonColor, buttonAction: goToMenuScene);
        buttonBack.xScale = scaleX;
        buttonBack.yScale = scaleY;
        buttonBack.restartLabel.fontSize = 40;
        buttonBack.restartLabel.position.y = buttonBack.defaultButton.position.y - buttonBack.restartLabel.fontSize*0.35;
        buttonBack.position = CGPoint(x: width-buttonBack.defaultButton.size.width*scaleX*0.6,
                                      y: buttonBack.defaultButton.size.height*scaleY*0.7);
        addChild(buttonBack);
    }
    func toggleSound() {
        if !UserDefaults.standard.bool(forKey: "soundOff") {
            buttonRemoveAds.restartLabel.text = "Sound is off";
            UserDefaults.standard.set(true, forKey: "soundOff");
            UserDefaults.standard.synchronize();
        }
        else {
            buttonRemoveAds.restartLabel.text = "Sound is on";
            UserDefaults.standard.set(false, forKey: "soundOff");
            UserDefaults.standard.synchronize();
        }
    }
    func toggleMusic() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        
        if !UserDefaults.standard.bool(forKey: "musicOff") {
            appDelegate.backgroundMusicPlayer.stop();
            
            buttonShowDifficulty.restartLabel.text = "Music is off";
            UserDefaults.standard.set(true, forKey: "musicOff");
            UserDefaults.standard.synchronize();
        }
        else {
            appDelegate.backgroundMusicPlayer.play();
            
            buttonShowDifficulty.restartLabel.text = "Music is on";
            UserDefaults.standard.set(false, forKey: "musicOff");
            UserDefaults.standard.synchronize();
        }
    }
    func placeLabel(text: NSString, distance: CGFloat, color: SKColor, yCoefficient: CGFloat) {
        let label = SKLabelNode(fontNamed:"ChalkboardSE-Bold");
        label.text = text as String;
        label.fontSize = fontSize;
        label.fontColor = color;
        label.horizontalAlignmentMode = .left
        label.position = CGPoint(x:distance, y:height-yCoefficient*label.fontSize*scaleY);
        label.zPosition = 1;
        label.xScale = scaleX;
        label.yScale = scaleY;
        addChild(label);
    }
    func goToMenuScene() {
        
        let transition = SKTransition.reveal(with: SKTransitionDirection.right, duration: 2);
        
        let scene = Menu(size: size, bannerHeight: CGFloat(UserDefaults.standard.float(forKey: "bannerHeight")), bannerView: adMobBannerView);
        scene.scaleMode = .aspectFill;
        
        view?.presentScene(scene, transition: transition);
    }
}
