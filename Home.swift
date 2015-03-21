//
//  Home.swift
//  MathQuest
//
//  Created by Adnan Zahid on 2/10/15.
//  Copyright (c) 2015 Adnan Zahid. All rights reserved.
//

import SpriteKit
import Social
import AVFoundation

class Home: SKScene {
    
    var width: CGFloat = 0;
    var height: CGFloat = 0;
    
    var scaleX: CGFloat = 0;
    var scaleY: CGFloat = 0;
    
    var button: GGButton!;
    var buttonSound: GGButton!;
    var buttonColor: SKColor = SKColor(red: 0, green: 0.4784313725, blue: 1, alpha: 0.5);
    
    let buttonScaleX: CGFloat = 2;
    let buttonScaleY: CGFloat = 2.5;
    
    var yShift: CGFloat = 0;
    var backgroundTouched: Bool = false;
    
    var bannerHeight: CGFloat = 0;
    var adMobBannerView: GADBannerView!;
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate;
    var backgroundMusicPlayer: AVAudioPlayer!;
    
    func playBackgroundMusic() {
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("musicOff") {
            var error: NSError?
            let backgroundMusicURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Home", ofType: "wav")!)
            appDelegate.backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: backgroundMusicURL, error: &error)
            appDelegate.backgroundMusicPlayer.numberOfLoops = -1
            appDelegate.backgroundMusicPlayer.prepareToPlay()
            appDelegate.backgroundMusicPlayer.play()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: CGSize, bannerHeight: CGFloat, bannerView: GADBannerView) {
        super.init(size: size);
        self.bannerHeight = bannerHeight;
        self.adMobBannerView = bannerView;
    }
    
    override func didMoveToView(view: SKView) {
        
        if !appDelegate.backgroundMusicPlayer.playing {
            playBackgroundMusic();
        }
        
        width = CGRectGetMaxX(frame);
        height = CGRectGetMaxY(frame);
        
        height -= bannerHeight;
        
        yShift = height/8;
        
        let background = SKSpriteNode(imageNamed:"splash_background");
        scaleX = width/background.size.width;
        scaleY = height/background.size.height;
        background.xScale = scaleX;
        background.yScale = scaleY;
        background.position = CGPoint(x:width/2, y:height/2);
        background.zPosition = 0;
        addChild(background);
        
        buttonSound = GGButton(scaleX: buttonScaleX, scaleY: buttonScaleY, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "Guide", textColor: buttonColor, buttonAction: goToGuide);
        buttonSound.xScale = scaleX;
        buttonSound.yScale = scaleY;
        buttonSound.restartLabel.fontSize = 80;
        buttonSound.restartLabel.position.y = buttonSound.defaultButton.position.y - buttonSound.restartLabel.fontSize*0.35;
        buttonSound.position = CGPointMake(buttonSound.defaultButton.size.width*scaleX/2, height*0.75 - yShift);
        addChild(buttonSound);
        
        button = GGButton(scaleX: buttonScaleX, scaleY: buttonScaleY, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "Menu", textColor: buttonColor, buttonAction: showMenu);
        button.xScale = scaleX;
        button.yScale = scaleY;
        button.restartLabel.fontSize = 80;
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize*0.35;
        button.position = CGPointMake(button.defaultButton.size.width*scaleX/2, height*0.25 - yShift);
        addChild(button);
        
        button = GGButton(scaleX: 1.5, scaleY: 1.5, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "", textColor: buttonColor, buttonAction: connectToFacebook);
        button.defaultButton.texture = SKTexture(imageNamed: "facebook");
        button.activeButton.texture = SKTexture(imageNamed: "facebookPressed");
        button.xScale = scaleX;
        button.yScale = scaleX;
        button.restartLabel.fontSize = 80;
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize*0.35;
        button.position = CGPointMake(width-button.defaultButton.size.width*scaleX*0.55, height*0.75 - yShift);
        addChild(button);
        
        button = GGButton(scaleX: 1.5, scaleY: 1.5, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "", textColor: buttonColor, buttonAction: connectToTwitter);
        button.defaultButton.texture = SKTexture(imageNamed: "twitter");
        button.activeButton.texture = SKTexture(imageNamed: "twitterPressed");
        button.xScale = scaleX;
        button.yScale = scaleX;
        button.restartLabel.fontSize = 80;
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize*0.35;
        button.position = CGPointMake(width-button.defaultButton.size.width*scaleX*0.55, height*0.25 - yShift);
        addChild(button);
        
        fadeOutText("Tap screen to play!");
    }
    
    func fadeOutText(textString: NSString) {
        
        let label = SKLabelNode(fontNamed:"ChalkboardSE-Bold");
        label.text = textString;
        label.fontSize = 100;
        label.fontColor = SKColor.lightGrayColor();
        label.position = CGPoint(x:width*0.525, y:height*0.1);
        label.xScale = scaleX;
        label.yScale = scaleY;
        label.zPosition = 16;
        addChild(label);
        
        var fadeOut = SKAction.fadeOutWithDuration(1);
        var fadeIn = SKAction.fadeInWithDuration(1);
        label.runAction(SKAction.repeatActionForever(SKAction.sequence([fadeOut, fadeIn])));
    }
    func showMenu() {
        
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Left, duration: 2);
        
        let scene = Menu(size: size, bannerHeight: CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("bannerHeight")), bannerView: adMobBannerView);
        scene.scaleMode = .AspectFill;
        
        view?.presentScene(scene, transition: transition);
    }
    
    func connectToFacebook() {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            var facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook);
            facebookSheet.setInitialText("This game is awesome!");
            facebookSheet.addImage(UIImage(named: "splash_background"));
            facebookSheet.addURL(NSURL(string: "http://mathquestgame.com"));
            
            view?.window?.rootViewController?.presentViewController(facebookSheet, animated: true, completion: nil);
        } else {
            var alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil));
            view?.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil);
        }
    }
    func connectToTwitter() {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            var twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter);
            twitterSheet.setInitialText("This game is awesome!");
            twitterSheet.addImage(UIImage(named: "splash_background"));
            twitterSheet.addURL(NSURL(string: "http://mathquestgame.com"));
            view?.window?.rootViewController?.presentViewController(twitterSheet, animated: true, completion: nil);
        } else {
            var alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil));
            view?.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil);
        }
    }
    func goToGuide() {
        
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Left, duration: 2);
        
        let scene = Guide(size: size, bannerHeight: CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("bannerHeight")), bannerView: adMobBannerView);
        scene.scaleMode = .AspectFill;
        
        view?.presentScene(scene, transition: transition);
    }
    
    func goToGameScene() {
        
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Left, duration: 2);
        
        let scene = GameScene(size: size, bannerHeight: CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("bannerHeight")), bannerView: adMobBannerView);
        scene.scaleMode = .AspectFill;
        
        view?.presentScene(scene, transition: transition);
    }
    
    #if os(iOS)
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        backgroundTouched = true;
    }
    #else
    override func mouseDown(theEvent: NSEvent) {
    
        backgroundTouched = true;
    }
    #endif
    
    override func update(currentTime: CFTimeInterval) {
        if backgroundTouched {
            backgroundTouched = false;
            goToGameScene();
        }
    }
}