//
//  AppDelegate.swift
//  MathQuest
//
//  Created by Adnan Zahid on 2/10/15.
//  Copyright (c) 2015 Adnan Zahid. All rights reserved.
//

import AVFoundation
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var backgroundMusicPlayer: AVAudioPlayer?

    func playBackgroundMusic(named resource: String) {
        guard !UserDefaults.standard.bool(forKey: "musicOff"),
              let url = Bundle.main.url(forResource: resource, withExtension: "wav"),
              let player = try? AVAudioPlayer(contentsOf: url) else {
            return
        }

        backgroundMusicPlayer = player
        player.numberOfLoops = -1
        player.prepareToPlay()
        player.play()
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if #unavailable(iOS 13.0) {
            let gameViewController = GameViewController()
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.rootViewController = gameViewController
            window.makeKeyAndVisible()
            self.window = window
        }

        playBackgroundMusic(named: "Home")
        return true
    }

    @available(iOS 13.0, *)
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}

    func applicationWillResignActive(_ application: UIApplication) {
        if !UserDefaults.standard.bool(forKey: "musicOff") {
            backgroundMusicPlayer?.pause()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if !UserDefaults.standard.bool(forKey: "musicOff") {
            backgroundMusicPlayer?.stop()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if !UserDefaults.standard.bool(forKey: "musicOff") {
            backgroundMusicPlayer?.play()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if !UserDefaults.standard.bool(forKey: "musicOff"),
           backgroundMusicPlayer?.isPlaying != true {
            backgroundMusicPlayer?.play()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        if !UserDefaults.standard.bool(forKey: "musicOff") {
            backgroundMusicPlayer?.stop()
        }
    }
}
