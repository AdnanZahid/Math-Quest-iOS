//
//  LocalScores.swift
//  MathQuest
//
//  Created by Adnan Zahid on 2/10/15.
//  Copyright (c) 2015 Adnan Zahid. All rights reserved.
//

import SpriteKit
import AVFoundation
import GameKit

class LocalScores: SKScene, GKGameCenterControllerDelegate {
    
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
    
    var gcEnabled: Bool = false;
    var gcDefaultLeaderBoard: String = "mq5456";
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate;
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController!) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func playBackgroundMusic() {
        
        if !UserDefaults.standard.bool(forKey: "musicOff") {
            var error: NSError?
            let backgroundMusicURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Home", ofType: "wav")!)
            appDelegate.backgroundMusicPlayer = try! AVAudioPlayer(contentsOf: backgroundMusicURL as URL)
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
    
    func showLeaderboard() {
        var gcVC: GKGameCenterViewController = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = GKGameCenterViewControllerState.leaderboards
        gcVC.leaderboardIdentifier = "mq5456"
        view?.window?.rootViewController?.present(gcVC, animated: true, completion: nil)
    }
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.local
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if let ViewController = ViewController {
                // 1 Show login if player is not logged in
                self.view?.window?.rootViewController?.present(ViewController, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2 Player is already euthenticated & logged in, load game center
               self.gcEnabled = true
                
                // Get the default leaderboard ID
//                localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifer: String!, error: NSError!) -> Void in
//                    if error != nil {
//                    } else {
//                        self.gcDefaultLeaderBoard = leaderboardIdentifer
//                    }
//                })
                
                
            } else {
                // 3 Game center is not enabled on the users device
                self.gcEnabled = false
            }
            
        }
        
    }
    
    override func didMove(to view: SKView) {
        
        appDelegate.backgroundMusicPlayer.stop();
        playBackgroundMusic();
        
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
        
        button = GGButton(scaleX: buttonScaleX, scaleY: buttonScaleY, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "Game Center", textColor: buttonColor, buttonAction: showLeaderboard);
        button.xScale = scaleX;
        button.yScale = scaleY;
        button.restartLabel.fontSize = 30;
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize*0.35;
        button.position = CGPoint(x: width-button.defaultButton.size.width*scaleX*0.6,
                                  y: height/2);
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
        progressLabel.text = "Highscores:";
        progressLabel.fontSize = 60;
        progressLabel.fontColor = progressColor;
        progressLabel.horizontalAlignmentMode = .left;
        progressLabel.xScale = scaleX;
        progressLabel.yScale = scaleY;
        progressLabel.position = CGPoint(x:progressLabel.fontSize*scaleX, y:height-progressLabel.fontSize*scaleY*1.5);
        progressLabel.zPosition = 8;
        
        addChild(progressLabel);
        
        for i in 0...4 {
            placeLabel(text: String(i+1)+") "+String(UserDefaults.standard.integer(forKey: "highscore"+String(i))) as NSString, distance: progressLabel.fontSize*scaleX, color: white, yCoefficient: 1.5*CGFloat(i+1));
        }
        
        self.authenticateLocalPlayer()
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
        
        let scene = Menu(size: size, bannerHeight: CGFloat(UserDefaults.standard.float(forKey: "bannerHeight")), bannerView: adMobBannerView);
        scene.scaleMode = .aspectFill;
        
        view?.presentScene(scene, transition: transition);
    }
}
