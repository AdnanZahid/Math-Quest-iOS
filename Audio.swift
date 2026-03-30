//
//  Audio.swift
//  MathQuest
//
//  Created by Adnan Zahid on 2/21/15.
//  Copyright (c) 2015 Adnan Zahid. All rights reserved.
//

import SpriteKit
import UIKit

class Audio: SKScene {

    private var width: CGFloat = 0
    private var height: CGFloat = 0

    private var scaleX: CGFloat = 0
    private var scaleY: CGFloat = 0

    private var soundButton: GGButton!
    private var musicButton: GGButton!
    private var buttonBack: GGButton!
    private let buttonColor = SKColor(red: 0, green: 0.4784313725, blue: 1, alpha: 0.5)
    private let progressColor = SKColor.white

    private let buttonScaleX: CGFloat = 1
    private let buttonScaleY: CGFloat = 1

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
        progressLabel.text = "Audio:"
        progressLabel.fontSize = 60
        progressLabel.fontColor = progressColor
        progressLabel.horizontalAlignmentMode = .left
        progressLabel.xScale = scaleX
        progressLabel.yScale = scaleY
        progressLabel.position = CGPoint(x: progressLabel.fontSize * scaleX, y: height - progressLabel.fontSize * scaleY * 1.5)
        progressLabel.zPosition = 8
        addChild(progressLabel)

        soundButton = GGButton(
            scaleX: buttonScaleX * 1.6,
            scaleY: buttonScaleY,
            defaultButtonImage: "button_default",
            activeButtonImage: "button_pressed",
            text: UserDefaults.standard.bool(forKey: "soundOff") ? "Sound is off" : "Sound is on",
            textColor: buttonColor,
            buttonAction: toggleSound
        )
        soundButton.xScale = scaleX
        soundButton.yScale = scaleY
        soundButton.restartLabel.fontSize = 40
        soundButton.restartLabel.position.y = soundButton.defaultButton.position.y - soundButton.restartLabel.fontSize * 0.35
        soundButton.position = CGPoint(x: soundButton.defaultButton.size.width * scaleX * 0.6, y: height - 2.5 * soundButton.defaultButton.size.height * scaleY * 0.7)
        addChild(soundButton)

        musicButton = GGButton(
            scaleX: buttonScaleX * 1.6,
            scaleY: buttonScaleY,
            defaultButtonImage: "button_default",
            activeButtonImage: "button_pressed",
            text: UserDefaults.standard.bool(forKey: "musicOff") ? "Music is off" : "Music is on",
            textColor: buttonColor,
            buttonAction: toggleMusic
        )
        musicButton.xScale = scaleX
        musicButton.yScale = scaleY
        musicButton.restartLabel.fontSize = 40
        musicButton.restartLabel.position.y = musicButton.defaultButton.position.y - musicButton.restartLabel.fontSize * 0.35
        musicButton.position = CGPoint(x: musicButton.defaultButton.size.width * scaleX * 0.6, y: musicButton.defaultButton.size.height * scaleY * 0.7)
        addChild(musicButton)

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

    func toggleSound() {
        let defaults = UserDefaults.standard
        let newValue = !defaults.bool(forKey: "soundOff")
        defaults.set(newValue, forKey: "soundOff")
        soundButton.restartLabel.text = newValue ? "Sound is off" : "Sound is on"
    }

    func toggleMusic() {
        let defaults = UserDefaults.standard
        let newValue = !defaults.bool(forKey: "musicOff")
        defaults.set(newValue, forKey: "musicOff")
        musicButton.restartLabel.text = newValue ? "Music is off" : "Music is on"

        if newValue {
            appDelegate?.backgroundMusicPlayer?.stop()
        } else if appDelegate?.backgroundMusicPlayer != nil {
            appDelegate?.backgroundMusicPlayer?.play()
        } else {
            appDelegate?.playBackgroundMusic(named: "Home")
        }
    }

    func goToMenuScene() {
        let transition = SKTransition.reveal(with: .right, duration: 2)
        let scene = Menu(size: size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: transition)
    }
}
