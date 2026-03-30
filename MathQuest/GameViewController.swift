//
//  GameViewController.swift
//  MathQuest
//
//  Created by Adnan Zahid on 2/10/15.
//  Copyright (c) 2015 Adnan Zahid. All rights reserved.
//

import SpriteKit
import UIKit

class GameViewController: UIViewController {

    override func loadView() {
        view = SKView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadScene()
    }

    func makeInitialScene(for size: CGSize) -> Home {
        let scene = Home(size: size)
        scene.scaleMode = .aspectFill
        return scene
    }

    func loadScene() {
        guard let skView = view as? SKView else {
            return
        }

        skView.ignoresSiblingOrder = true
        skView.presentScene(makeInitialScene(for: skView.bounds.size))
    }

    override var shouldAutorotate: Bool {
        true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        }

        return .all
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
}
