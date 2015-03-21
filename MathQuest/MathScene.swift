//
//  MathScene.swift
//  MathQuest
//
//  Created by Adnan Zahid on 2/10/15.
//  Copyright (c) 2015 Adnan Zahid. All rights reserved.
//

import SpriteKit
import Social
import AVFoundation
import GameKit

class MathScene: SKScene {
    
    var width: CGFloat = 0;
    var height: CGFloat = 0;
    
    var universe: SKNode!;
    
    let fontSize: CGFloat = 40;
    let yShift: CGFloat = 15;
    let labelShift: CGFloat = 20;
    
    var spriteArrayWalking = Array<SKTexture>();
    var heroSprite: SKSpriteNode!;
    var repeatActionWalking: SKAction!;
    var progressLabel: SKLabelNode!;
    var label: SKLabelNode!;
    
    var score: UInt32 = 0;
    var coins: UInt32 = 0;
    var sum: UInt32 = 0;
    
    var numberOfInputs: CGFloat = 0;
    
    var button: GGButton!;
    var buttonColor: SKColor = SKColor(red: 0, green: 0.4784313725, blue: 1, alpha: 0.5);
    let white = SKColor.whiteColor();
    
    var scaleX: CGFloat = 0;
    var scaleY: CGFloat = 0;
    
    var pauseButton: GGButton!;
    var effectsNode: SKEffectNode!;
    var finalmeters: SKLabelNode!;
    var buttonHome: GGButton!;
    var buttonResume: GGButton!;
    
    var soundOff: Bool = false;
    
    var bannerHeight: CGFloat = 0;
    var adMobBannerView: GADBannerView!;
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate;
    var backgroundMusicPlayer: AVAudioPlayer!;
    
    var gcEnabled: Bool = false;
    var gcDefaultLeaderBoard: String = "mq5456";
    
    func playBackgroundMusic() {
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("musicOff") {
            var error: NSError?
            let backgroundMusicURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("MathScene", ofType: "wav")!)
            appDelegate.backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: backgroundMusicURL, error: &error)
            appDelegate.backgroundMusicPlayer.numberOfLoops = -1
            appDelegate.backgroundMusicPlayer.prepareToPlay()
            appDelegate.backgroundMusicPlayer.play()
        }
    }
    func submitScore() {
        var leaderboardID = "mq5456"
        var sScore = GKScore(leaderboardIdentifier: leaderboardID)
        sScore.value = Int64(sum)
        
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        GKScore.reportScores([sScore], withCompletionHandler: { (error: NSError!) -> Void in })
        
    }
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1 Show login if player is not logged in
                self.view?.window?.rootViewController?.presentViewController(ViewController, animated: true, completion: nil)
            } else if (localPlayer.authenticated) {
                // 2 Player is already euthenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifer: String!, error: NSError!) -> Void in
                    if error != nil {
                    } else {
                        self.gcDefaultLeaderBoard = leaderboardIdentifer
                    }
                })
                
                
            } else {
                // 3 Game center is not enabled on the users device
                self.gcEnabled = false
            }
            
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        super.init(size: size);
    }
    
    init(size: CGSize, score: UInt32, coins: UInt32, bannerHeight: CGFloat, bannerView: GADBannerView) {
        super.init(size: size);
        self.bannerHeight = bannerHeight;
        self.score = score;
        self.coins = coins;
        self.adMobBannerView = bannerView;
    }
    
    override func didMoveToView(view: SKView) {
        
        soundOff = NSUserDefaults.standardUserDefaults().boolForKey("soundOff");
        
        appDelegate.backgroundMusicPlayer.stop();
        playBackgroundMusic();
        
        effectsNode = SKEffectNode();
        let filter = CIFilter(name: "CIGaussianBlur");
        filter.setValue(32, forKey: kCIInputRadiusKey);
        
        effectsNode.filter = filter;
        effectsNode.blendMode = .Alpha;
        effectsNode.shouldEnableEffects = true;
        effectsNode.shouldEnableEffects = false;
        effectsNode.shouldRasterize = true;
        
        width = CGRectGetMaxX(frame);
        height = CGRectGetMaxY(frame);
        
        height -= bannerHeight;
        
        universe = SKNode();
        addChild(universe);
        
        let textureAtlas = SKTextureAtlas(named:"hero.atlas");
        
        let background = SKSpriteNode(imageNamed: "blackboard");
        scaleX = width/background.size.width;
        scaleY = height/background.size.height;
        background.xScale = scaleX;
        background.yScale = scaleY;
        background.position = CGPoint(x:width/2, y:height/2);
        background.zPosition = 0;
        universe.addChild(background);
        
        for i in 1...2 {
            appendSpriteWalking(textureAtlas, imageName: "walking"+String(i));
        }
        
        heroSprite = SKSpriteNode(texture:spriteArrayWalking[0]);
        heroSprite.xScale = scaleX;
        heroSprite.yScale = scaleY;
        heroSprite.position = CGPoint(x:heroSprite.size.width+10*scaleX*1.85,y:heroSprite.size.height);
        heroSprite.zPosition = 2;
        universe.addChild(heroSprite);
        
        var animateAction = SKAction.animateWithTextures(spriteArrayWalking, timePerFrame: 1);
        var group = SKAction.group([ animateAction ]);
        repeatActionWalking = SKAction.repeatActionForever(group);
        heroSprite.runAction(repeatActionWalking);
        
        progressLabel = SKLabelNode(fontNamed:"Chalkduster");
        progressLabel.xScale = scaleX;
        progressLabel.yScale = scaleY;
        progressLabel.text = "Coins: " + String(coins);
        progressLabel.fontSize = 15;
        progressLabel.fontColor = white;
        progressLabel.horizontalAlignmentMode = .Right
        progressLabel.position = CGPoint(x:width-3*progressLabel.fontSize*scaleX, y:height-3*progressLabel.fontSize*scaleY);
        progressLabel.zPosition = 1;
        universe.addChild(progressLabel);
        
        button = GGButton(scaleX: 0.3, scaleY: 0.6, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "9", textColor: buttonColor, buttonAction: numberPressed9);
        button.xScale = scaleX;
        button.yScale = scaleY;
        button.restartLabel.fontSize = 50;
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize*0.35;
        button.position = CGPointMake(3*button.defaultButton.size.width*scaleX, height - button.defaultButton.size.height*scaleY - yShift);
        universe.addChild(button);
        
        button = GGButton(scaleX: 0.3, scaleY: 0.6, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "8", textColor: buttonColor, buttonAction: numberPressed8);
        button.position = CGPointMake(2*button.defaultButton.size.width*scaleX, height - button.defaultButton.size.height*scaleY - yShift);
        button.xScale = scaleX;
        button.yScale = scaleY;
        button.restartLabel.fontSize = 50;
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize*0.35;
        universe.addChild(button);
        
        button = GGButton(scaleX: 0.3, scaleY: 0.6, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "7", textColor: buttonColor, buttonAction: numberPressed7);
        button.position = CGPointMake(button.defaultButton.size.width*scaleX, height - button.defaultButton.size.height*scaleY - yShift);
        button.xScale = scaleX;
        button.yScale = scaleY;
        button.restartLabel.fontSize = 50;
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize*0.35;
        universe.addChild(button);
        
        button = GGButton(scaleX: 0.3, scaleY: 0.6, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "6", textColor: buttonColor, buttonAction: numberPressed6);
        button.position = CGPointMake(3*button.defaultButton.size.width*scaleX, height - 2*button.defaultButton.size.height*scaleY - yShift);
        button.xScale = scaleX;
        button.yScale = scaleY;
        button.restartLabel.fontSize = 50;
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize*0.35;
        universe.addChild(button);
        
        button = GGButton(scaleX: 0.3, scaleY: 0.6, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "5", textColor: buttonColor, buttonAction: numberPressed5);
        button.position = CGPointMake(2*button.defaultButton.size.width*scaleX, height - 2*button.defaultButton.size.height*scaleY - yShift);
        button.xScale = scaleX;
        button.yScale = scaleY;
        button.restartLabel.fontSize = 50;
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize*0.35;
        universe.addChild(button);
        
        button = GGButton(scaleX: 0.3, scaleY: 0.6, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "4", textColor: buttonColor, buttonAction: numberPressed4);
        button.position = CGPointMake(button.defaultButton.size.width*scaleX, height - 2*button.defaultButton.size.height*scaleY - yShift);
        button.xScale = scaleX;
        button.yScale = scaleY;
        button.restartLabel.fontSize = 50;
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize*0.35;
        universe.addChild(button);
        
        button = GGButton(scaleX: 0.3, scaleY: 0.6, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "3", textColor: buttonColor, buttonAction: numberPressed3);
        button.position = CGPointMake(3*button.defaultButton.size.width*scaleX, height - 3*button.defaultButton.size.height*scaleY - yShift);
        button.xScale = scaleX;
        button.yScale = scaleY;
        button.restartLabel.fontSize = 50;
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize*0.35;
        universe.addChild(button);
        
        button = GGButton(scaleX: 0.3, scaleY: 0.6, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "2", textColor: buttonColor, buttonAction: numberPressed2);
        button.position = CGPointMake(2*button.defaultButton.size.width*scaleX, height - 3*button.defaultButton.size.height*scaleY - yShift);
        button.xScale = scaleX;
        button.yScale = scaleY;
        button.restartLabel.fontSize = 50;
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize*0.35;
        universe.addChild(button);
        
        button = GGButton(scaleX: 0.3, scaleY: 0.6, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "1", textColor: buttonColor, buttonAction: numberPressed1);
        button.position = CGPointMake(button.defaultButton.size.width*scaleX, height - 3*button.defaultButton.size.height*scaleY - yShift);
        button.xScale = scaleX;
        button.yScale = scaleY;
        button.restartLabel.fontSize = 50;
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize*0.35;
        universe.addChild(button);
        
        button = GGButton(scaleX: 0.6, scaleY: 0.6, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "0", textColor: buttonColor, buttonAction: numberPressed0);
        button.position = CGPointMake(1.25*button.defaultButton.size.width*scaleX, height - 4*button.defaultButton.size.height*scaleY - yShift);
        button.xScale = scaleX;
        button.yScale = scaleY;
        button.restartLabel.fontSize = 50;
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize*0.35;
        universe.addChild(button);
        
        if score / 100000 > 0 {
            numberOfInputs = 0;
        }
        else if score / 10000 > 0 {
            numberOfInputs = 1;
        }
        else if score / 1000 > 0 {
            numberOfInputs = 2;
        }
        else if score / 100 > 0 {
            numberOfInputs = 3;
        }
        else if score / 10 > 0 {
            numberOfInputs = 4;
        }
        else if score >= 0 {
            numberOfInputs = 5;
        }
        
        pauseButton = GGButton(scaleX: scaleX*0.15, scaleY: scaleY*0.4, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "||", textColor: buttonColor, buttonAction: pauseGame);
        pauseButton.position = CGPointMake(pauseButton.defaultButton.size.width/2, height-pauseButton.defaultButton.size.height/2);
        universe.addChild(pauseButton);
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("notFirstTimeMath") {
            fadeOutText("Enter your score!");
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "notFirstTimeMath");
            NSUserDefaults.standardUserDefaults().synchronize();
        }
        
        self.authenticateLocalPlayer()
    }
    
    func placeLabel(text: NSString, distance: CGFloat, color: SKColor, yCoefficient: CGFloat) {
        let xCoefficient: CGFloat = 0.69;
        label = SKLabelNode(fontNamed:"Chalkduster");
        label.text = text;
        label.fontSize = fontSize;
        label.fontColor = color;
        label.horizontalAlignmentMode = .Right
        label.position = CGPoint(x:width*xCoefficient-distance*label.fontSize*scaleX, y:height-yCoefficient*label.fontSize*scaleY - labelShift - yShift);
        label.zPosition = 1;
        label.xScale = scaleX;
        label.yScale = scaleY;
        universe.addChild(label);
    }
    
    func appendSpriteWalking(textureAtlas: SKTextureAtlas, imageName: NSString) {
        spriteArrayWalking.append(textureAtlas.textureNamed(imageName));
    }
    
    func decimalPlaces(var maxNumberLength: UInt32, whichNumber: UInt32) -> UInt32 {
        var resultingNumber: UInt32 = 0
        if whichNumber >= 100000 {
            resultingNumber = maxNumberLength-5;
        }
        else if whichNumber >= 10000 {
            resultingNumber = maxNumberLength-4;
        }
        else if whichNumber >= 1000 {
            resultingNumber = maxNumberLength-3;
        }
        else if whichNumber >= 100 {
            resultingNumber = maxNumberLength-2;
        }
        else if whichNumber >= 10 {
            resultingNumber = maxNumberLength-1;
        }
        else {
            resultingNumber = maxNumberLength;
        }
        return resultingNumber;
    }
    
    func numberPressed(number: UInt32) {
        
        if numberOfInputs < 6 {
            
            numberOfInputs++;
            
            let distance: CGFloat = 7 - numberOfInputs;
            placeLabel(String(number), distance: distance, color: white, yCoefficient: 1.5);
            
            var numberPlace: UInt32 = UInt32(pow(10, Double(6-numberOfInputs)));
            var correctNumber: UInt32 = (score%(numberPlace*10))/(numberPlace);
            
            var processedScore: UInt32 = 0;
            if number == UInt32(correctNumber) {
                playSound("GreenScore");
                placeLabel(String(correctNumber), distance: distance, color: SKColor.greenColor(), yCoefficient: 3);
                processedScore = number;
                placeLabel(String(number), distance: distance, color: white, yCoefficient: 4.5);
            }
            else {
                playSound("RedScore");
                placeLabel(String(correctNumber), distance: distance, color: SKColor.redColor(), yCoefficient: 3);
                processedScore = 0;
                placeLabel("0", distance: distance, color: white, yCoefficient: 4.5);
            }
            sum += processedScore*numberPlace;
            
            if numberOfInputs == 6 {
                
                placeLabel("(Remains)", distance: distance - 6, color: white, yCoefficient: 4.5);
                
                var resultingNumber: UInt32 = decimalPlaces(6, whichNumber: sum);
                
                for i in resultingNumber...6 {
                    numberPlace = UInt32(pow(10, Double(6-i)));
                    correctNumber = (sum%(numberPlace*10))/(numberPlace);
                    
                    placeLabel(String(correctNumber), distance: 7 - CGFloat(i), color: white, yCoefficient: 6);
                }
                
                resultingNumber = decimalPlaces(5, whichNumber: coins);
                
                for i in resultingNumber...5 {
                    numberPlace = UInt32(pow(10, Double(5-i)));
                    correctNumber = (coins%(numberPlace*10))/(numberPlace);
                    
                    placeLabel(String(correctNumber), distance: -CGFloat(i), color: white, yCoefficient: 6);
                }
                
                placeLabel(" + ", distance: distance - 1, color: white, yCoefficient: 6);
                
                sum += coins;
                resultingNumber = decimalPlaces(6, whichNumber: sum);
                
                for i in resultingNumber...6 {
                    numberPlace = UInt32(pow(10, Double(6-i)));
                    correctNumber = (sum%(numberPlace*10))/(numberPlace);
                    
                    placeLabel(String(correctNumber), distance: 7 - CGFloat(i), color: white, yCoefficient: 7.5);
                }
                
                placeLabel("(Total)", distance: distance - 6, color: white, yCoefficient: 7.5);
                
                button = GGButton(scaleX: 0.7, scaleY: 0.7, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "Retry", textColor: buttonColor, buttonAction: retry);
                button.position = CGPointMake(width - button.defaultButton.size.width*scaleX*0.75, height - button.defaultButton.size.height*scaleY - yShift);
                button.xScale = scaleX;
                button.yScale = scaleY;
                universe.addChild(button);
                
                button = GGButton(scaleX: 0.45, scaleY: 0.45, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "", textColor: buttonColor, buttonAction: postOnFacebook);
                button.defaultButton.texture = SKTexture(imageNamed: "facebook");
                button.activeButton.texture = SKTexture(imageNamed: "facebookPressed");
                button.xScale = scaleX;
                button.yScale = scaleX;
                button.position = CGPointMake(width - button.defaultButton.size.width*scaleX*3.65, button.defaultButton.size.height*scaleY*1.15 - yShift);
                universe.addChild(button);
                
                button = GGButton(scaleX: 0.45, scaleY: 0.45, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "", textColor: buttonColor, buttonAction: postOnTwitter);
                button.defaultButton.texture = SKTexture(imageNamed: "twitter");
                button.activeButton.texture = SKTexture(imageNamed: "twitterPressed");
                button.xScale = scaleX;
                button.yScale = scaleX;
                button.position = CGPointMake(width - button.defaultButton.size.width*scaleX*2.5, button.defaultButton.size.height*scaleY*1.15 - yShift);
                universe.addChild(button);
                
                button = GGButton(scaleX: 0.675, scaleY: 0.6, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "Scores", textColor: buttonColor, buttonAction: goToLocalScoresScene);
                button.position = CGPointMake(width - button.defaultButton.size.width*scaleX*0.75, button.defaultButton.size.height*scaleY*0.9 - yShift);
                button.xScale = scaleX;
                button.yScale = scaleY;
                universe.addChild(button);
                
                var highscoreArray = Array<Int>();
                for i in 0...4 {
                    highscoreArray.append(NSUserDefaults.standardUserDefaults().integerForKey("highscore"+String(i)));
                }
                highscoreArray.append(Int(sum));
                highscoreArray = removeDuplicates(highscoreArray);
                highscoreArray = highscoreArray.sorted(>);
                for i in 0...4 {
                    highscoreArray.append(0);
                }
                for i in 0...4 {
                    NSUserDefaults.standardUserDefaults().setInteger(highscoreArray[i], forKey: "highscore"+String(i));
                }
                NSUserDefaults.standardUserDefaults().synchronize();
                
                if sum >= UInt32(highscoreArray[0]) {
                    playSound("Highscore");
                    fadeOutText("Highscore!");
                }
                submitScore();
            }
        }
    }
    func playSound(soundName: NSString) {
        if !soundOff {
            runAction(SKAction.playSoundFileNamed(soundName+".wav", waitForCompletion: false));
        }
    }
    func fadeOutText(textString: NSString) {
        
        playSound("FadeOut");
        let label = SKLabelNode(fontNamed:"Chalkduster");
        label.text = textString;
        label.fontSize = 20;
        label.fontColor = SKColor.whiteColor();
        label.position = CGPoint(x:width/2, y:height/2);
        label.xScale = scaleX;
        label.yScale = scaleY;
        label.zPosition = 20;
        universe.addChild(label);
        
        var flashAction: SKAction = SKAction.scaleBy(4, duration: 1);
        label.runAction(flashAction);
        flashAction = SKAction.fadeOutWithDuration(1);
        label.runAction(flashAction, completion: {label.removeFromParent();});
    }
    func removeDuplicates(array:[Int]) -> [Int] {
        var arr = array
        var indArr = [Int]()
        var tempArr = arr
        var i = 0
        for a in enumerate(arr) {
            
            if contains(prefix(arr, a.index), a.element) {
                indArr.append(a.index)
            }
            
            i++
        }
        var ind = 0
        for i in indArr {
            arr.removeAtIndex(i-ind)
            ind++
        }
        return arr
    }
    func goToLocalScoresScene() {
        
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Left, duration: 2);
        
        let scene = LocalScores(size: size, bannerHeight: CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("bannerHeight")), bannerView: adMobBannerView);
        scene.scaleMode = .AspectFill;
        
        view?.presentScene(scene, transition: transition);
    }
    func screenShotMethod() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: view!.frame.size.width, height: view!.frame.size.height), true, 1)
        view!.drawViewHierarchyInRect(view!.frame, afterScreenUpdates: true)
        let context = UIGraphicsGetCurrentContext()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image;
    }
    func postOnFacebook() {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            var facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.setInitialText("Wow! I scored "+String(score+coins)+" points in Math Quest.")
            facebookSheet.addImage(screenShotMethod());
            facebookSheet.addURL(NSURL(string: "http://mathquestgame.com"));
            view?.window?.rootViewController?.presentViewController(facebookSheet, animated: true, completion: nil)
        } else {
            var alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            view?.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        }
    }
    func postOnTwitter() {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            var twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter);
            twitterSheet.setInitialText("Wow! I scored "+String(score+coins)+" points in Math Quest.")
            twitterSheet.addImage(screenShotMethod());
            twitterSheet.addURL(NSURL(string: "http://mathquestgame.com"));
            view?.window?.rootViewController?.presentViewController(twitterSheet, animated: true, completion: nil);
        } else {
            var alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil));
            view?.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil);
        }
    }
    
    func numberPressed0() {
        numberPressed(0);
    }
    
    func numberPressed1() {
        numberPressed(1);
    }
    
    func numberPressed2() {
        numberPressed(2);
    }
    
    func numberPressed3() {
        numberPressed(3);
    }
    
    func numberPressed4() {
        numberPressed(4);
    }
    
    func numberPressed5() {
        numberPressed(5);
    }
    
    func numberPressed6() {
        numberPressed(6);
    }
    
    func numberPressed7() {
        numberPressed(7);
    }
    
    func numberPressed8() {
        numberPressed(8);
    }
    
    func numberPressed9() {
        numberPressed(9);
    }
    
    func retry() {
        
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Right, duration: 2);
        
        let scene = GameScene(size: size, bannerHeight: CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("bannerHeight")), bannerView: adMobBannerView);
        scene.scaleMode = .AspectFill;
        
        view?.presentScene(scene, transition: transition);
    }
    
    func pauseGame() {
        
        appDelegate.backgroundMusicPlayer.stop()
        
        effectsNode.shouldEnableEffects = true;
        
        universe.removeFromParent();
        effectsNode.addChild(universe);
        addChild(effectsNode);
        
        finalmeters = SKLabelNode(fontNamed:"ChalkboardSE-Bold");
        finalmeters.text = "Game paused!";
        finalmeters.fontSize = 50;
        finalmeters.fontColor = buttonColor;
        finalmeters.position = CGPoint(x:width/2, y:height/2+finalmeters.fontSize/2);
        finalmeters.zPosition = 13;
        addChild(finalmeters);
        
        buttonHome = GGButton(scaleX: 1, scaleY: 1, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "Home", textColor: buttonColor, buttonAction: goToHomeScene);
        buttonHome.position = CGPointMake(width/2-buttonHome.defaultButton.size.width/2, height/2-buttonHome.defaultButton.size.height/2);
        addChild(buttonHome);
        
        buttonResume = GGButton(scaleX: 1, scaleY: 1, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "Resume", textColor: buttonColor, buttonAction: resumeGame);
        buttonResume.position = CGPointMake(width/2+buttonResume.defaultButton.size.width/2, height/2-buttonResume.defaultButton.size.height/2);
        addChild(buttonResume);
        pauseButton.removeFromParent();
        paused = true;
    }
    func resumeGame() {
        
        appDelegate.backgroundMusicPlayer.play()
        
        paused = false;
        
        finalmeters.removeFromParent();
        buttonHome.removeFromParent();
        buttonResume.removeFromParent();
        effectsNode.removeFromParent();
        universe.removeFromParent();
        addChild(universe);
        addChild(pauseButton);
    }
    func goToHomeScene() {
        
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Right, duration: 2);
        
        let scene = Home(size: size, bannerHeight: CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("bannerHeight")), bannerView: adMobBannerView);
        scene.scaleMode = .AspectFill;
        
        view?.presentScene(scene, transition: transition);
    }
}