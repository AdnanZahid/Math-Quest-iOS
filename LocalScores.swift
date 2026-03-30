//
//  LocalScores.swift
//  MathQuest
//
//  Created by Adnan Zahid on 2/10/15.
//  Copyright (c) 2015 Adnan Zahid. All rights reserved.
//

import GameKit
import SpriteKit
import UIKit

@MainActor
class LocalScores: SKScene, @preconcurrency GKGameCenterControllerDelegate {

    private var width: CGFloat = 0
    private var height: CGFloat = 0

    private var scaleX: CGFloat = 0
    private var scaleY: CGFloat = 0

    private let yShift: CGFloat = 90

    private var button: GGButton!
    private let buttonColor = SKColor(red: 0, green: 0.4784313725, blue: 1, alpha: 0.5)
    private let progressColor = SKColor.white

    private let buttonScaleX: CGFloat = 1
    private let buttonScaleY: CGFloat = 1

    private let white = SKColor.white
    private let fontSize: CGFloat = 40

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

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }

    func playBackgroundMusic() {
        appDelegate?.playBackgroundMusic(named: "Home")
    }

    func showLeaderboard() {
        let gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        gameCenterViewController.viewState = .leaderboards
        gameCenterViewController.leaderboardIdentifier = gcDefaultLeaderboard
        view?.window?.rootViewController?.present(gameCenterViewController, animated: true)
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
        appDelegate?.backgroundMusicPlayer?.stop()
        playBackgroundMusic()

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

        button = GGButton(
            scaleX: buttonScaleX,
            scaleY: buttonScaleY,
            defaultButtonImage: "button_default",
            activeButtonImage: "button_pressed",
            text: "Game Center",
            textColor: buttonColor,
            buttonAction: showLeaderboard
        )
        button.xScale = scaleX
        button.yScale = scaleY
        button.restartLabel.fontSize = 30
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize * 0.35
        button.position = CGPoint(x: width - button.defaultButton.size.width * scaleX * 0.6, y: height / 2)
        addChild(button)

        button = GGButton(
            scaleX: buttonScaleX,
            scaleY: buttonScaleY,
            defaultButtonImage: "button_default",
            activeButtonImage: "button_pressed",
            text: "Back",
            textColor: buttonColor,
            buttonAction: goToMenuScene
        )
        button.xScale = scaleX
        button.yScale = scaleY
        button.restartLabel.fontSize = 40
        button.restartLabel.position.y = button.defaultButton.position.y - button.restartLabel.fontSize * 0.35
        button.position = CGPoint(x: width - button.defaultButton.size.width * scaleX * 0.6, y: button.defaultButton.size.height * scaleY * 0.7)
        addChild(button)

        let progressLabel = SKLabelNode(fontNamed: "Chalkduster")
        progressLabel.text = "Highscores:"
        progressLabel.fontSize = 60
        progressLabel.fontColor = progressColor
        progressLabel.horizontalAlignmentMode = .left
        progressLabel.xScale = scaleX
        progressLabel.yScale = scaleY
        progressLabel.position = CGPoint(x: progressLabel.fontSize * scaleX, y: height - progressLabel.fontSize * scaleY * 1.5)
        progressLabel.zPosition = 8
        addChild(progressLabel)

        for index in 0...4 {
            let score = UserDefaults.standard.integer(forKey: "highscore\(index)")
            placeLabel("\(index + 1)) \(score)", distance: progressLabel.fontSize * scaleX, color: white, yCoefficient: 1.5 * CGFloat(index + 1))
        }

        authenticateLocalPlayer()
    }

    func placeLabel(_ text: String, distance: CGFloat, color: SKColor, yCoefficient: CGFloat) {
        let label = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        label.text = text
        label.fontSize = fontSize
        label.fontColor = color
        label.horizontalAlignmentMode = .left
        label.position = CGPoint(x: distance, y: height - yCoefficient * label.fontSize * scaleY - yShift * scaleY)
        label.zPosition = 1
        label.xScale = scaleX
        label.yScale = scaleY
        addChild(label)
    }

    func goToMenuScene() {
        let transition = SKTransition.reveal(with: .right, duration: 2)
        let scene = Menu(size: size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: transition)
    }
}
