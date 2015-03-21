//
//  GameViewController.swift
//  MathQuest
//
//  Created by Adnan Zahid on 2/10/15.
//  Copyright (c) 2015 Adnan Zahid. All rights reserved.
//

import UIKit
import SpriteKit
import iAd

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController, ADBannerViewDelegate {
    
    var adMobBannerView: GADBannerView!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        adMobBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerLandscape);
        adMobBannerView.hidden = true;
        adMobBannerView.adUnitID = "ca-app-pub-7152525679107278/5241103547";
        adMobBannerView.rootViewController = self;
        view.addSubview(adMobBannerView);
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("dontShowAds") {
            showBanner();
            NSUserDefaults.standardUserDefaults().setFloat(Float(adMobBannerView.bounds.size.height), forKey: "bannerHeight");
        }
        else {
            hideBanner();
            NSUserDefaults.standardUserDefaults().setFloat(0, forKey: "bannerHeight");
        }
        
        loadScene();
    }
    
    func showBanner() {
        adMobBannerView.hidden = false;
        var request: GADRequest = GADRequest();
        request.testDevices = [ GAD_SIMULATOR_ID ];
        adMobBannerView.loadRequest(request);
    }
    
    func hideBanner() {
        adMobBannerView.hidden = true;
    }
    
    func loadScene() {
        
        let skView = self.view as SKView
        let scene = Home(size: skView.bounds.size, bannerHeight: CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("bannerHeight")), bannerView: adMobBannerView);
    
        skView.ignoresSiblingOrder = true
        
        scene.scaleMode = .AspectFill
    
        skView.presentScene(scene)
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
}
