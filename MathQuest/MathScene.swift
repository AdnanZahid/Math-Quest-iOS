//
//  MathScene.swift
//  MathQuest
//
//  Created by Adnan Zahid on 2/10/15.
//  Copyright (c) 2015 Adnan Zahid. All rights reserved.
//

import AVFoundation
import GameKit
import SpriteKit
import UIKit

class MathScene: SKScene {

    private var width: CGFloat = 0
    private var height: CGFloat = 0

    private var universe: SKNode!

    private let fontSize: CGFloat = 40
    private let yShift: CGFloat = 15
    private let labelShift: CGFloat = 20

    private var spriteArrayWalking: [SKTexture] = []
    private var heroSprite: SKSpriteNode!
    private var repeatActionWalking: SKAction!
    private var progressLabel: SKLabelNode!
    private var label: SKLabelNode!

    private var score: UInt32 = 0
    private var coins: UInt32 = 0
    private var sum: UInt32 = 0

    private var numberOfInputs = 0

    private var button: GGButton!
    private let buttonColor = SKColor(red: 0, green: 0.4784313725, blue: 1, alpha: 0.5)
    private let white = SKColor.white

    private var scaleX: CGFloat = 0
    private var scaleY: CGFloat = 0

    private var pauseButton: GGButton!
    private var effectsNode: SKEffectNode!
    private var finalmeters: SKLabelNode!
    private var buttonHome: GGButton!
    private var buttonResume: GGButton!

    private var soundOff = false

    private var gcEnabled = false
    private var gcDefaultLeaderboard = "mq5456"

    private var appDelegate: AppDelegate? {
        UIApplication.shared.delegate as? AppDelegate
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(size: CGSize) {
        super.init(size: size)
    }

    init(size: CGSize, score: UInt32, coins: UInt32) {
        self.score = score
        self.coins = coins
        super.init(size: size)
    }

    func playBackgroundMusic() {
        appDelegate?.playBackgroundMusic(named: "MathScene")
    }

    func submitScore() {
        let localPlayer = GKLocalPlayer.local
        guard localPlayer.isAuthenticated else {
            return
        }

        if #available(iOS 14.0, *) {
            GKLeaderboard.submitScore(
                Int(sum),
                context: 0,
                player: localPlayer,
                leaderboardIDs: [gcDefaultLeaderboard]
            ) { _ in }
        } else {
            let scoreReporter = GKScore(leaderboardIdentifier: gcDefaultLeaderboard)
            scoreReporter.value = Int64(sum)
            GKScore.report([scoreReporter]) { _ in }
        }
    }

    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { [weak self] viewController, _ in
            guard let self else {
                return
            }

            if let viewController {
                self.view?.window?.rootViewController?.present(viewController, animated: true)
                return
            }

            self.gcEnabled = localPlayer.isAuthenticated
            if self.gcEnabled {
                localPlayer.loadDefaultLeaderboardIdentifier { identifier, _ in
                    if let identifier {
                        DispatchQueue.main.async { [weak self] in
                            self?.gcDefaultLeaderboard = identifier
                        }
                    }
                }
            }
        }
    }

    override func didMove(to view: SKView) {
        soundOff = UserDefaults.standard.bool(forKey: "soundOff")

        appDelegate?.backgroundMusicPlayer?.stop()
        playBackgroundMusic()

        effectsNode = SKEffectNode()
        if let filter = CIFilter(name: "CIGaussianBlur") {
            filter.setValue(32, forKey: kCIInputRadiusKey)
            effectsNode.filter = filter
        }
        effectsNode.blendMode = .alpha
        effectsNode.shouldEnableEffects = false
        effectsNode.shouldRasterize = true

        width = frame.maxX
        height = frame.maxY

        universe = SKNode()
        addChild(universe)

        let textureAtlas = SKTextureAtlas(named: "hero.atlas")

        let background = SKSpriteNode(imageNamed: "blackboard")
        scaleX = width / background.size.width
        scaleY = height / background.size.height
        background.xScale = scaleX
        background.yScale = scaleY
        background.position = CGPoint(x: width / 2, y: height / 2)
        background.zPosition = 0
        universe.addChild(background)

        for index in 1...2 {
            appendSpriteWalking(textureAtlas: textureAtlas, imageName: "walking\(index)")
        }

        heroSprite = SKSpriteNode(texture: spriteArrayWalking[0])
        heroSprite.xScale = scaleX
        heroSprite.yScale = scaleY
        heroSprite.position = CGPoint(x: heroSprite.size.width + 10 * scaleX * 1.85, y: heroSprite.size.height)
        heroSprite.zPosition = 2
        universe.addChild(heroSprite)

        let animateAction = SKAction.animate(with: spriteArrayWalking, timePerFrame: 1)
        repeatActionWalking = SKAction.repeatForever(.group([animateAction]))
        heroSprite.run(repeatActionWalking)

        progressLabel = SKLabelNode(fontNamed: "Chalkduster")
        progressLabel.xScale = scaleX
        progressLabel.yScale = scaleY
        progressLabel.text = "Coins: \(coins)"
        progressLabel.fontSize = 15
        progressLabel.fontColor = white
        progressLabel.horizontalAlignmentMode = .right
        progressLabel.position = CGPoint(x: width - 3 * progressLabel.fontSize * scaleX, y: height - 3 * progressLabel.fontSize * scaleY)
        progressLabel.zPosition = 1
        universe.addChild(progressLabel)

        addNumberButton("9", action: numberPressed9, xMultiplier: 3, row: 1)
        addNumberButton("8", action: numberPressed8, xMultiplier: 2, row: 1)
        addNumberButton("7", action: numberPressed7, xMultiplier: 1, row: 1)
        addNumberButton("6", action: numberPressed6, xMultiplier: 3, row: 2)
        addNumberButton("5", action: numberPressed5, xMultiplier: 2, row: 2)
        addNumberButton("4", action: numberPressed4, xMultiplier: 1, row: 2)
        addNumberButton("3", action: numberPressed3, xMultiplier: 3, row: 3)
        addNumberButton("2", action: numberPressed2, xMultiplier: 2, row: 3)
        addNumberButton("1", action: numberPressed1, xMultiplier: 1, row: 3)

        button = GGButton(
            scaleX: 0.6,
            scaleY: 0.6,
            defaultButtonImage: "button_default",
            activeButtonImage: "button_pressed",
            text: "0",
            textColor: buttonColor,
            buttonAction: numberPressed0
        )
        button.position = CGPoint(x: 1.25 * button.defaultButton.size.width * scaleX, y: height - 4 * button.defaultButton.size.height * scaleY - yShift)
        button.xScale = scaleX
        button.yScale = scaleY
        button.restartLabel.fontSize = 50
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize * 0.35
        universe.addChild(button)

        if score / 100000 > 0 {
            numberOfInputs = 0
        } else if score / 10000 > 0 {
            numberOfInputs = 1
        } else if score / 1000 > 0 {
            numberOfInputs = 2
        } else if score / 100 > 0 {
            numberOfInputs = 3
        } else if score / 10 > 0 {
            numberOfInputs = 4
        } else {
            numberOfInputs = 5
        }

        pauseButton = GGButton(
            scaleX: scaleX * 0.15,
            scaleY: scaleY * 0.4,
            defaultButtonImage: "button_default",
            activeButtonImage: "button_pressed",
            text: "||",
            textColor: buttonColor,
            buttonAction: pauseGame
        )
        pauseButton.position = CGPoint(x: pauseButton.defaultButton.size.width / 2, y: height - pauseButton.defaultButton.size.height / 2)
        universe.addChild(pauseButton)

        if !UserDefaults.standard.bool(forKey: "notFirstTimeMath") {
            fadeOutText("Enter your score!")
            UserDefaults.standard.set(true, forKey: "notFirstTimeMath")
        }

        authenticateLocalPlayer()
    }

    private func addNumberButton(_ text: String, action: @escaping () -> Void, xMultiplier: CGFloat, row: CGFloat) {
        button = GGButton(
            scaleX: 0.3,
            scaleY: 0.6,
            defaultButtonImage: "button_default",
            activeButtonImage: "button_pressed",
            text: text,
            textColor: buttonColor,
            buttonAction: action
        )
        button.position = CGPoint(x: xMultiplier * button.defaultButton.size.width * scaleX, y: height - row * button.defaultButton.size.height * scaleY - yShift)
        button.xScale = scaleX
        button.yScale = scaleY
        button.restartLabel.fontSize = 50
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize * 0.35
        universe.addChild(button)
    }

    func placeLabel(_ text: String, distance: CGFloat, color: SKColor, yCoefficient: CGFloat) {
        let xCoefficient: CGFloat = 0.69
        label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = text
        label.fontSize = fontSize
        label.fontColor = color
        label.horizontalAlignmentMode = .right
        label.position = CGPoint(
            x: width * xCoefficient - distance * label.fontSize * scaleX,
            y: height - yCoefficient * label.fontSize * scaleY - labelShift - yShift
        )
        label.zPosition = 1
        label.xScale = scaleX
        label.yScale = scaleY
        universe.addChild(label)
    }

    func appendSpriteWalking(textureAtlas: SKTextureAtlas, imageName: String) {
        spriteArrayWalking.append(textureAtlas.textureNamed(imageName))
    }

    func decimalPlaces(_ maxNumberLength: UInt32, whichNumber: UInt32) -> UInt32 {
        if whichNumber >= 100000 {
            return maxNumberLength - 5
        } else if whichNumber >= 10000 {
            return maxNumberLength - 4
        } else if whichNumber >= 1000 {
            return maxNumberLength - 3
        } else if whichNumber >= 100 {
            return maxNumberLength - 2
        } else if whichNumber >= 10 {
            return maxNumberLength - 1
        }

        return maxNumberLength
    }

    func numberPressed(_ number: UInt32) {
        guard numberOfInputs < 6 else {
            return
        }

        numberOfInputs += 1

        let distance = CGFloat(7 - numberOfInputs)
        placeLabel(String(number), distance: distance, color: white, yCoefficient: 1.5)

        var numberPlace = UInt32(pow(10.0, Double(6 - numberOfInputs)))
        let correctNumber = (score % (numberPlace * 10)) / numberPlace

        let processedScore: UInt32
        if number == correctNumber {
            playSound("GreenScore")
            placeLabel(String(correctNumber), distance: distance, color: .green, yCoefficient: 3)
            processedScore = number
            placeLabel(String(number), distance: distance, color: white, yCoefficient: 4.5)
        } else {
            playSound("RedScore")
            placeLabel(String(correctNumber), distance: distance, color: .red, yCoefficient: 3)
            processedScore = 0
            placeLabel("0", distance: distance, color: white, yCoefficient: 4.5)
        }
        sum += processedScore * numberPlace

        guard numberOfInputs == 6 else {
            return
        }

        placeLabel("(Remains)", distance: distance - 6, color: white, yCoefficient: 4.5)

        var resultingNumber = Int(decimalPlaces(6, whichNumber: sum))
        for index in resultingNumber...6 {
            numberPlace = UInt32(pow(10.0, Double(6 - index)))
            let digit = (sum % (numberPlace * 10)) / numberPlace
            placeLabel(String(digit), distance: CGFloat(7 - index), color: white, yCoefficient: 6)
        }

        resultingNumber = Int(decimalPlaces(5, whichNumber: coins))
        for index in resultingNumber...5 {
            numberPlace = UInt32(pow(10.0, Double(5 - index)))
            let digit = (coins % (numberPlace * 10)) / numberPlace
            placeLabel(String(digit), distance: CGFloat(-index), color: white, yCoefficient: 6)
        }

        placeLabel(" + ", distance: distance - 1, color: white, yCoefficient: 6)

        sum += coins
        resultingNumber = Int(decimalPlaces(6, whichNumber: sum))
        for index in resultingNumber...6 {
            numberPlace = UInt32(pow(10.0, Double(6 - index)))
            let digit = (sum % (numberPlace * 10)) / numberPlace
            placeLabel(String(digit), distance: CGFloat(7 - index), color: white, yCoefficient: 7.5)
        }

        placeLabel("(Total)", distance: distance - 6, color: white, yCoefficient: 7.5)

        let retryButton = GGButton(
            scaleX: 0.7,
            scaleY: 0.7,
            defaultButtonImage: "button_default",
            activeButtonImage: "button_pressed",
            text: "Retry",
            textColor: buttonColor,
            buttonAction: retry
        )
        retryButton.position = CGPoint(x: width - retryButton.defaultButton.size.width * scaleX * 0.75, y: height - retryButton.defaultButton.size.height * scaleY - yShift)
        retryButton.xScale = scaleX
        retryButton.yScale = scaleY
        universe.addChild(retryButton)

        let scoresButton = GGButton(
            scaleX: 0.675,
            scaleY: 0.6,
            defaultButtonImage: "button_default",
            activeButtonImage: "button_pressed",
            text: "Scores",
            textColor: buttonColor,
            buttonAction: goToLocalScoresScene
        )
        scoresButton.position = CGPoint(x: width - scoresButton.defaultButton.size.width * scaleX * 0.75, y: button.defaultButton.size.height * scaleY * 0.9 - yShift)
        scoresButton.xScale = scaleX
        scoresButton.yScale = scaleY
        universe.addChild(scoresButton)

        var highscoreArray = (0...4).map { UserDefaults.standard.integer(forKey: "highscore\($0)") }
        highscoreArray.append(Int(sum))
        highscoreArray = Array(Set(highscoreArray)).sorted(by: >)
        while highscoreArray.count < 5 {
            highscoreArray.append(0)
        }

        for (index, value) in highscoreArray.prefix(5).enumerated() {
            UserDefaults.standard.set(value, forKey: "highscore\(index)")
        }

        if sum >= UInt32(highscoreArray[0]) {
            playSound("Highscore")
            fadeOutText("Highscore!")
        }

        submitScore()
    }

    func playSound(_ soundName: String) {
        if !soundOff {
            run(SKAction.playSoundFileNamed("\(soundName).wav", waitForCompletion: false))
        }
    }

    func fadeOutText(_ textString: String) {
        playSound("FadeOut")

        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = textString
        label.fontSize = 20
        label.fontColor = .white
        label.position = CGPoint(x: width / 2, y: height / 2)
        label.xScale = scaleX
        label.yScale = scaleY
        label.zPosition = 20
        universe.addChild(label)

        let flashAction = SKAction.scale(by: 4, duration: 1)
        label.run(flashAction)
        label.run(.fadeOut(withDuration: 1)) {
            label.removeFromParent()
        }
    }

    func goToLocalScoresScene() {
        let transition = SKTransition.reveal(with: .left, duration: 2)
        let scene = LocalScores(size: size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: transition)
    }

    func numberPressed0() { numberPressed(0) }
    func numberPressed1() { numberPressed(1) }
    func numberPressed2() { numberPressed(2) }
    func numberPressed3() { numberPressed(3) }
    func numberPressed4() { numberPressed(4) }
    func numberPressed5() { numberPressed(5) }
    func numberPressed6() { numberPressed(6) }
    func numberPressed7() { numberPressed(7) }
    func numberPressed8() { numberPressed(8) }
    func numberPressed9() { numberPressed(9) }

    func retry() {
        let transition = SKTransition.reveal(with: .right, duration: 2)
        let scene = GameScene(size: size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: transition)
    }

    func pauseGame() {
        appDelegate?.backgroundMusicPlayer?.stop()

        effectsNode.shouldEnableEffects = true

        universe.removeFromParent()
        effectsNode.addChild(universe)
        addChild(effectsNode)

        finalmeters = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        finalmeters.text = "Game paused!"
        finalmeters.fontSize = 50
        finalmeters.fontColor = buttonColor
        finalmeters.position = CGPoint(x: width / 2, y: height / 2 + finalmeters.fontSize / 2)
        finalmeters.zPosition = 13
        addChild(finalmeters)

        buttonHome = GGButton(
            scaleX: 1,
            scaleY: 1,
            defaultButtonImage: "button_default",
            activeButtonImage: "button_pressed",
            text: "Home",
            textColor: buttonColor,
            buttonAction: goToHomeScene
        )
        buttonHome.position = CGPoint(x: width / 2 - buttonHome.defaultButton.size.width / 2, y: height / 2 - buttonHome.defaultButton.size.height / 2)
        addChild(buttonHome)

        buttonResume = GGButton(
            scaleX: 1,
            scaleY: 1,
            defaultButtonImage: "button_default",
            activeButtonImage: "button_pressed",
            text: "Resume",
            textColor: buttonColor,
            buttonAction: resumeGame
        )
        buttonResume.position = CGPoint(x: width / 2 + buttonResume.defaultButton.size.width / 2, y: height / 2 - buttonResume.defaultButton.size.height / 2)
        addChild(buttonResume)

        pauseButton.removeFromParent()
        isPaused = true
    }

    func resumeGame() {
        appDelegate?.backgroundMusicPlayer?.play()

        isPaused = false

        finalmeters.removeFromParent()
        buttonHome.removeFromParent()
        buttonResume.removeFromParent()
        effectsNode.removeFromParent()
        universe.removeFromParent()
        addChild(universe)
        addChild(pauseButton)
    }

    func goToHomeScene() {
        let transition = SKTransition.reveal(with: .right, duration: 2)
        let scene = Home(size: size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: transition)
    }
}
