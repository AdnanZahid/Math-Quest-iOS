//
//  Home.swift
//  MathQuest
//
//  Created by Adnan Zahid on 2/10/15.
//  Copyright (c) 2015 Adnan Zahid. All rights reserved.
//

import SpriteKit
import UIKit

class Home: SKScene {

    private var width: CGFloat = 0
    private var height: CGFloat = 0

    private var scaleX: CGFloat = 0
    private var scaleY: CGFloat = 0

    private var menuButton: GGButton!
    private var guideButton: GGButton!
    private let buttonColor = SKColor(red: 0, green: 0.4784313725, blue: 1, alpha: 0.5)

    private let buttonScaleX: CGFloat = 2
    private let buttonScaleY: CGFloat = 2.5

    private var yShift: CGFloat = 0
    private var backgroundTouched = false

    private var appDelegate: AppDelegate? {
        UIApplication.shared.delegate as? AppDelegate
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(size: CGSize) {
        super.init(size: size)
    }

    override func didMove(to view: SKView) {
        if appDelegate?.backgroundMusicPlayer?.isPlaying != true {
            appDelegate?.playBackgroundMusic(named: "Home")
        }

        width = frame.maxX
        height = frame.maxY
        yShift = height / 8

        let background = SKSpriteNode(imageNamed: "splash_background")
        scaleX = width / background.size.width
        scaleY = height / background.size.height
        background.xScale = scaleX
        background.yScale = scaleY
        background.position = CGPoint(x: width / 2, y: height / 2)
        background.zPosition = 0
        addChild(background)

        guideButton = GGButton(
            scaleX: buttonScaleX,
            scaleY: buttonScaleY,
            defaultButtonImage: "button_default",
            activeButtonImage: "button_pressed",
            text: "Guide",
            textColor: buttonColor,
            buttonAction: goToGuide
        )
        guideButton.xScale = scaleX
        guideButton.yScale = scaleY
        guideButton.restartLabel.fontSize = 80
        guideButton.restartLabel.position.y = guideButton.defaultButton.position.y - guideButton.restartLabel.fontSize * 0.35
        guideButton.position = CGPoint(x: width * 0.28, y: height * 0.2 - yShift * 0.35)
        addChild(guideButton)

        menuButton = GGButton(
            scaleX: buttonScaleX,
            scaleY: buttonScaleY,
            defaultButtonImage: "button_default",
            activeButtonImage: "button_pressed",
            text: "Menu",
            textColor: buttonColor,
            buttonAction: showMenu
        )
        menuButton.xScale = scaleX
        menuButton.yScale = scaleY
        menuButton.restartLabel.fontSize = 80
        menuButton.restartLabel.position.y = menuButton.defaultButton.position.y - menuButton.restartLabel.fontSize * 0.35
        menuButton.position = CGPoint(x: width * 0.72, y: height * 0.2 - yShift * 0.35)
        addChild(menuButton)

        fadeOutText("Tap screen to play!")
    }

    func fadeOutText(_ textString: String) {
        let label = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        label.text = textString
        label.fontSize = 100
        label.fontColor = .lightGray
        label.position = CGPoint(x: width * 0.525, y: height * 0.1)
        label.xScale = scaleX
        label.yScale = scaleY
        label.zPosition = 16
        addChild(label)

        let fadeOut = SKAction.fadeOut(withDuration: 1)
        let fadeIn = SKAction.fadeIn(withDuration: 1)
        label.run(.repeatForever(.sequence([fadeOut, fadeIn])))
    }

    func showMenu() {
        let transition = SKTransition.reveal(with: .left, duration: 2)
        let scene = Menu(size: size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: transition)
    }

    func goToGuide() {
        let transition = SKTransition.reveal(with: .left, duration: 2)
        let scene = Guide(size: size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: transition)
    }

    func goToGameScene() {
        let transition = SKTransition.reveal(with: .left, duration: 2)
        let scene = GameScene(size: size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: transition)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        backgroundTouched = true
    }

    override func update(_ currentTime: TimeInterval) {
        if backgroundTouched {
            backgroundTouched = false
            goToGameScene()
        }
    }
}
