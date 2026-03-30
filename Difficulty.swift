//
//  Difficulty.swift
//  MathQuest
//
//  Created by Adnan Zahid on 2/19/15.
//  Copyright (c) 2015 Adnan Zahid. All rights reserved.
//

import SpriteKit

class Difficulty: SKNode {

    let label: SKLabelNode
    private let action: () -> Void

    init(text: String, textColor: SKColor, buttonAction: @escaping () -> Void) {
        action = buttonAction

        label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = text
        label.fontSize = 33
        label.fontColor = textColor
        label.horizontalAlignmentMode = .left
        label.zPosition = 8

        super.init()

        isUserInteractionEnabled = true
        addChild(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }

        let location = touch.location(in: self)
        if label.contains(location) {
            action()
        }
    }
}
