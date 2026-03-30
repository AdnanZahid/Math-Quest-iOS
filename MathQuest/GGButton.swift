//
//  GGButton.swift
//  MathQuest
//
//  Created by Adnan Zahid on 2/12/15.
//  Copyright (c) 2015 Adnan Zahid. All rights reserved.
//

import SpriteKit

class GGButton: SKNode {
    let defaultButton: SKSpriteNode
    let activeButton: SKSpriteNode
    let restartLabel: SKLabelNode

    private let action: () -> Void

    init(
        scaleX: CGFloat,
        scaleY: CGFloat,
        defaultButtonImage: String,
        activeButtonImage: String,
        text: String,
        textColor: SKColor,
        buttonAction: @escaping () -> Void
    ) {
        defaultButton = SKSpriteNode(imageNamed: defaultButtonImage)
        activeButton = SKSpriteNode(imageNamed: activeButtonImage)
        action = buttonAction
        restartLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")

        super.init()

        defaultButton.xScale = scaleX
        defaultButton.yScale = scaleY
        activeButton.xScale = scaleX
        activeButton.yScale = scaleY

        defaultButton.zPosition = 14
        activeButton.zPosition = 15
        activeButton.isHidden = true

        restartLabel.text = text
        restartLabel.fontSize = 50 * scaleY
        restartLabel.fontColor = textColor
        restartLabel.position.x = defaultButton.position.x
        restartLabel.position.y = defaultButton.position.y - restartLabel.fontSize * 0.35
        restartLabel.zPosition = 15

        isUserInteractionEnabled = true
        addChild(defaultButton)
        addChild(activeButton)
        addChild(restartLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        setHighlighted(true)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }

        let location = touch.location(in: self)
        setHighlighted(defaultButton.contains(location))
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        setHighlighted(false)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer { setHighlighted(false) }

        guard let touch = touches.first else {
            return
        }

        let location = touch.location(in: self)
        if defaultButton.contains(location) {
            action()
            playSound("Button")
        }
    }

    private func setHighlighted(_ highlighted: Bool) {
        activeButton.isHidden = !highlighted
        defaultButton.isHidden = highlighted
    }

    private func playSound(_ soundName: String) {
        if !UserDefaults.standard.bool(forKey: "soundOff") {
            run(SKAction.playSoundFileNamed("\(soundName).wav", waitForCompletion: false))
        }
    }
}
