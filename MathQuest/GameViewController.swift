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
        if let path = Bundle.main.path(forResource: file as String, ofType: "sks"), let url = URL(string: path) {
            var sceneData = try! Data(contentsOf: url, options: .dataReadingMapped)
            var archiver = try! NSKeyedUnarchiver(forReadingFrom: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! GameScene
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
        adMobBannerView.isHidden = true;
        adMobBannerView.adUnitID = "ca-app-pub-7152525679107278/5241103547";
        adMobBannerView.rootViewController = self;
        view.addSubview(adMobBannerView);
        
        if !UserDefaults.standard.bool(forKey: "dontShowAds") {
            showBanner();
            UserDefaults.standard.set(Float(adMobBannerView.bounds.size.height), forKey: "bannerHeight");
        }
        else {
            hideBanner();
            UserDefaults.standard.set(0, forKey: "bannerHeight");
        }
        
        loadScene();
    }
    
    func showBanner() {
        adMobBannerView.isHidden = false;
        var request: GADRequest = GADRequest();
        request.testDevices = [ GAD_SIMULATOR_ID ];
        adMobBannerView.load(request);
    }
    
    func hideBanner() {
        adMobBannerView.isHidden = true;
    }
    
    func loadScene() {
        
        let skView = self.view as! SKView
        let scene = Home(size: skView.bounds.size, bannerHeight: CGFloat(UserDefaults.standard.float(forKey: "bannerHeight")), bannerView: adMobBannerView);
    
        skView.ignoresSiblingOrder = true
        
        scene.scaleMode = .aspectFill
    
        skView.presentScene(scene)
    }
}
