//
//  Upgrade.swift
//  MathQuest
//
//  Created by Adnan Zahid on 2/10/15.
//  Copyright (c) 2015 Adnan Zahid. All rights reserved.
//

import SpriteKit

class Upgrade: SKScene {

    private var width: CGFloat = 0
    private var height: CGFloat = 0

    private var scaleX: CGFloat = 0
    private var scaleY: CGFloat = 0

    private var buttonBack: GGButton!
    private let buttonColor = SKColor(red: 0, green: 0.4784313725, blue: 1, alpha: 0.5)
    private let difficultyColor = SKColor.white
    private let progressColor = SKColor.white

    private let buttonScaleX: CGFloat = 1
    private let buttonScaleY: CGFloat = 1

    private var cake: Difficulty!
    private var medium: Difficulty!
    private var hard: Difficulty!
    private var geek: Difficulty!

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(size: CGSize) {
        super.init(size: size)
    }

    func switchToCake() {
        cake.label.text = "☑ Cake"
        medium.label.text = "▢ Medium"
        hard.label.text = "▢ Hard"
        geek.label.text = "▢ Geek"
        UserDefaults.standard.set(-1, forKey: "difficulty")
    }

    func switchToMedium() {
        cake.label.text = "▢ Cake"
        medium.label.text = "☑ Medium"
        hard.label.text = "▢ Hard"
        geek.label.text = "▢ Geek"
        UserDefaults.standard.set(0, forKey: "difficulty")
    }

    func switchToHard() {
        cake.label.text = "▢ Cake"
        medium.label.text = "▢ Medium"
        hard.label.text = "☑ Hard"
        geek.label.text = "▢ Geek"
        UserDefaults.standard.set(1, forKey: "difficulty")
    }

    func switchToGeek() {
        cake.label.text = "▢ Cake"
        medium.label.text = "▢ Medium"
        hard.label.text = "▢ Hard"
        geek.label.text = "☑ Geek"
        UserDefaults.standard.set(2, forKey: "difficulty")
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
        progressLabel.text = "Difficulty:"
        progressLabel.fontSize = 60
        progressLabel.fontColor = progressColor
        progressLabel.horizontalAlignmentMode = .left
        progressLabel.xScale = scaleX
        progressLabel.yScale = scaleY
        progressLabel.position = CGPoint(x: progressLabel.fontSize * scaleX, y: height - progressLabel.fontSize * scaleY * 1.5)
        progressLabel.zPosition = 8
        addChild(progressLabel)

        cake = Difficulty(text: "▢ Cake", textColor: difficultyColor, buttonAction: switchToCake)
        cake.xScale = scaleX
        cake.yScale = scaleY
        cake.zPosition = 8
        cake.position = CGPoint(x: 2.5 * cake.label.fontSize * scaleX, y: height - cake.label.fontSize * scaleY * 5)
        addChild(cake)

        medium = Difficulty(text: "▢ Medium", textColor: difficultyColor, buttonAction: switchToMedium)
        medium.xScale = scaleX
        medium.yScale = scaleY
        medium.zPosition = 8
        medium.position = CGPoint(x: 2.5 * medium.label.fontSize * scaleX, y: height - cake.label.fontSize * scaleY * 7)
        addChild(medium)

        hard = Difficulty(text: "▢ Hard", textColor: difficultyColor, buttonAction: switchToHard)
        hard.xScale = scaleX
        hard.yScale = scaleY
        hard.zPosition = 8
        hard.position = CGPoint(x: 2.5 * medium.label.fontSize * scaleX, y: height - cake.label.fontSize * scaleY * 9)
        addChild(hard)

        geek = Difficulty(text: "▢ Geek", textColor: difficultyColor, buttonAction: switchToGeek)
        geek.xScale = scaleX
        geek.yScale = scaleY
        geek.zPosition = 8
        geek.position = CGPoint(x: 2.5 * medium.label.fontSize * scaleX, y: height - cake.label.fontSize * scaleY * 11)
        addChild(geek)

        switch UserDefaults.standard.integer(forKey: "difficulty") {
        case -1:
            switchToCake()
        case 1:
            switchToHard()
        case 2:
            switchToGeek()
        default:
            switchToMedium()
        }

        buttonBack = GGButton(
            scaleX: buttonScaleX,
            scaleY: buttonScaleY,
            defaultButtonImage: "button_default",
            activeButtonImage: "button_pressed",
            text: "Back",
            textColor: buttonColor,
            buttonAction: goToMenuScene
        )
        buttonBack.xScale = scaleX
        buttonBack.yScale = scaleY
        buttonBack.restartLabel.fontSize = 40
        buttonBack.restartLabel.position.y = buttonBack.defaultButton.position.y - buttonBack.restartLabel.fontSize * 0.35
        buttonBack.position = CGPoint(x: width - buttonBack.defaultButton.size.width * scaleX * 0.6, y: buttonBack.defaultButton.size.height * scaleY * 0.7)
        addChild(buttonBack)
    }

    func goToMenuScene() {
        let transition = SKTransition.reveal(with: .right, duration: 2)
        let scene = Menu(size: size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: transition)
    }
}
