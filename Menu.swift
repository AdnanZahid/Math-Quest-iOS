//
//  Menu.swift
//  MathQuest
//
//  Created by Adnan Zahid on 2/10/15.
//  Copyright (c) 2015 Adnan Zahid. All rights reserved.
//

import SpriteKit

class Menu: SKScene {

    private var width: CGFloat = 0
    private var height: CGFloat = 0

    private var scaleX: CGFloat = 0
    private var scaleY: CGFloat = 0

    private var button: GGButton!
    private var buttonSound: GGButton!
    private let buttonColor = SKColor(red: 0, green: 0.4784313725, blue: 1, alpha: 0.5)
    private let progressColor = SKColor.white

    private let buttonScaleX: CGFloat = 1
    private let buttonScaleY: CGFloat = 1

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(size: CGSize) {
        super.init(size: size)
    }

    override func didMove(to view: SKView) {
        width = frame.maxX
        height = frame.maxY

        let background = SKSpriteNode(imageNamed: "blackboard")
        scaleX = width / background.size.width
        scaleY = height / background.size.height
        background.xScale = scaleX
        background.yScale = scaleY
        background.position = CGPoint(x: width / 2, y: height / 2)
        background.zPosition = 0
        addChild(background)

        let progressLabel = SKLabelNode(fontNamed: "Chalkduster")
        progressLabel.text = "Menu:"
        progressLabel.fontSize = 60
        progressLabel.fontColor = progressColor
        progressLabel.horizontalAlignmentMode = .left
        progressLabel.xScale = scaleX
        progressLabel.yScale = scaleY
        progressLabel.position = CGPoint(x: progressLabel.fontSize * scaleX, y: height - progressLabel.fontSize * scaleY * 1.5)
        progressLabel.zPosition = 8
        addChild(progressLabel)

        buttonSound = GGButton(
            scaleX: buttonScaleX,
            scaleY: buttonScaleY,
            defaultButtonImage: "button_default",
            activeButtonImage: "button_pressed",
            text: "Audio",
            textColor: buttonColor,
            buttonAction: goToAudioScene
        )
        buttonSound.xScale = scaleX
        buttonSound.yScale = scaleY
        buttonSound.restartLabel.fontSize = 30
        buttonSound.restartLabel.position.y = buttonSound.defaultButton.position.y - buttonSound.restartLabel.fontSize * 0.35
        buttonSound.position = CGPoint(x: buttonSound.defaultButton.size.width * scaleX, y: height - 1.5 * buttonSound.defaultButton.size.height * scaleY)
        addChild(buttonSound)

        button = GGButton(
            scaleX: buttonScaleX,
            scaleY: buttonScaleY,
            defaultButtonImage: "button_default",
            activeButtonImage: "button_pressed",
            text: "Highscores",
            textColor: buttonColor,
            buttonAction: goToLocalScoresScene
        )
        button.xScale = scaleX
        button.yScale = scaleY
        button.restartLabel.fontSize = 30
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize * 0.35
        button.position = CGPoint(x: width - button.defaultButton.size.width * scaleX, y: height - 1.5 * button.defaultButton.size.height * scaleY)
        addChild(button)

        button = GGButton(
            scaleX: buttonScaleX,
            scaleY: buttonScaleY,
            defaultButtonImage: "button_default",
            activeButtonImage: "button_pressed",
            text: "Difficulty",
            textColor: buttonColor,
            buttonAction: goToUpgradeScene
        )
        button.xScale = scaleX
        button.yScale = scaleY
        button.restartLabel.fontSize = 30
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize * 0.35
        button.position = CGPoint(x: button.defaultButton.size.width * scaleX, y: button.defaultButton.size.height * scaleY)
        addChild(button)

        button = GGButton(
            scaleX: buttonScaleX,
            scaleY: buttonScaleY,
            defaultButtonImage: "button_default",
            activeButtonImage: "button_pressed",
            text: "Back",
            textColor: buttonColor,
            buttonAction: goToHomeScene
        )
        button.xScale = scaleX
        button.yScale = scaleY
        button.restartLabel.fontSize = 30
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize * 0.35
        button.position = CGPoint(x: width - button.defaultButton.size.width * scaleX, y: button.defaultButton.size.height * scaleY)
        addChild(button)
    }

    func goToLocalScoresScene() {
        let transition = SKTransition.reveal(with: .left, duration: 2)
        let scene = LocalScores(size: size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: transition)
    }

    func goToAudioScene() {
        let transition = SKTransition.reveal(with: .left, duration: 2)
        let scene = Audio(size: size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: transition)
    }

    func goToUpgradeScene() {
        let transition = SKTransition.reveal(with: .left, duration: 2)
        let scene = Upgrade(size: size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: transition)
    }

    func goToHomeScene() {
        let transition = SKTransition.reveal(with: .right, duration: 2)
        let scene = Home(size: size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: transition)
    }
}
