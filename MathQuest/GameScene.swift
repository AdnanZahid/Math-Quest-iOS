//
//  GameScene.swift
//  MathQuest
//
//  Created by Adnan Zahid on 2/10/15.
//  Copyright (c) 2015 Adnan Zahid. All rights reserved.
//

import AVFoundation
import SpriteKit
import UIKit

@MainActor
class GameScene: SKScene, @preconcurrency SKPhysicsContactDelegate {

    private var width: CGFloat = 0
    private var height: CGFloat = 0

    private var scaleX: CGFloat = 0
    private var scaleY: CGFloat = 0

    private var gameOver = false
    private var showScore = false
    private var shield = false
    private var magnet = false
    private var addObstacles = false
    private var playerVelocity: CGFloat = 2
    private var minDifferenceBetweenRulers = 2500
    private var jumpHeight: CGFloat = 0
    private var gravity: CGFloat = 0
    private var timeSinceRuler: UInt8 = 0
    private var timeSinceShield: UInt8 = 0

    private var universe: SKNode!
    private var world: SKNode!
    private var platformGroup: SKNode!
    private var spriteArrayWalking: [SKTexture] = []
    private var spriteArrayFlying: [SKTexture] = []
    private var coinsArray: [SKTexture] = []
    private var shieldArray: [SKTexture] = []
    private var magnetArray: [SKTexture] = []
    private var rulerFireArray: [SKSpriteNode] = []
    private var heroSprite: SKSpriteNode!
    private var coinSprite: SKSpriteNode!
    private var coinSpriteArray: [SKSpriteNode] = []
    private var shieldSprite: SKSpriteNode!
    private var magnetSprite: SKSpriteNode!
    private var tacks: SKSpriteNode!
    private var distanceMoved: CGFloat = 0
    private var progressLabel: SKLabelNode!
    private var score: UInt32 = 0
    private var coins: UInt32 = 0
    private var meters: UInt32 = 0

    private let backgrounds = ["blue_background", "green_background", "orange_background", "pink_background"]
    private let positiveNumbers = [
        "plus1",
        "plus10",
        "plus100",
        "showScore",
    ]
    private let negativeNumbers = [
        "minus1",
        "minus10",
        "minus100",
        "divide10",
        "divide100",
    ]
    private var whichNumber = ""

    private var touchLeft = false

    private var repeatActionWalking: SKAction!
    private var repeatActionFlying: SKAction!
    private var shieldAction: SKAction!
    private var magnetAction: SKAction!
    private var coinAction: SKAction!

    private let startingX: CGFloat = 60
    private let startingY: CGFloat = 60
    private var positionX: CGFloat = 0
    private let ground = ["book", "ruler", "box"]
    private let maxRandom: UInt32 = 150
    private let minPlatformLength: UInt32 = 7
    private let maxPlatformLength: UInt32 = 12

    private let HEROCATEGORY: UInt32 = 0x1 << 0
    private let LEFTCATEGORY: UInt32 = 0x1 << 1
    private let GROUNDCATEGORY: UInt32 = 0x1 << 2
    private let TACKSCATEGORY: UInt32 = 0x1 << 3
    private let BOOKCATEGORY: UInt32 = 0x1 << 4
    private let FIRECATEGORY: UInt32 = 0x1 << 5
    private let COINCATEGORY: UInt32 = 0x1 << 6
    private let NUMBERCATEGORY: UInt32 = 0x1 << 7
    private let SHIELDCATEGORY: UInt32 = 0x1 << 8
    private let MAGNETCATEGORY: UInt32 = 0x1 << 9

    private var left: SKNode!

    private var parallaxArray: [SKNode] = []
    private let gameOverColor = SKColor(red: 0, green: 0.4784313725, blue: 1, alpha: 0.5)
    private let progressColor = SKColor(white: 0.5, alpha: 1)

    private var pauseButton: GGButton!
    private var effectsNode: SKEffectNode!
    private var finalmeters: SKLabelNode!
    private var buttonHome: GGButton!
    private var buttonResume: GGButton!
    private var buttonRetry: GGButton!

    private var executed = false
    private var soundOff = false

    private var appDelegate: AppDelegate? {
        UIApplication.shared.delegate as? AppDelegate
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(size: CGSize) {
        super.init(size: size)
    }

    func playBackgroundMusic() {
        appDelegate?.playBackgroundMusic(named: "GameScene")
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

        let flashAction = SKAction.scale(by: 4, duration: 5)
        label.run(flashAction)
        label.run(.fadeOut(withDuration: 5)) {
            label.removeFromParent()
        }
    }

    override func didMove(to view: SKView) {
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

        soundOff = UserDefaults.standard.bool(forKey: "soundOff")

        width = frame.maxX
        height = frame.maxY

        jumpHeight = height * 0.04167
        gravity = -height / 200
        playerVelocity = CGFloat(UserDefaults.standard.integer(forKey: "difficulty")) + 2

        let textureAtlas = SKTextureAtlas(named: "hero.atlas")
        let shieldAtlas = SKTextureAtlas(named: "shield.atlas")

        universe = SKNode()
        addChild(universe)
        world = SKNode()
        universe.addChild(world)
        platformGroup = SKNode()
        world.addChild(platformGroup)

        physicsWorld.gravity = CGVector(dx: 0, dy: gravity)

        let background = SKSpriteNode(imageNamed: backgrounds[Int(arc4random_uniform(UInt32(backgrounds.count)))])
        scaleX = width / background.size.width
        scaleY = height / background.size.height
        background.xScale = scaleX
        background.yScale = scaleY
        background.position = CGPoint(x: width / 2, y: height / 2)
        background.zPosition = 0
        universe.addChild(background)

        parallaxify(imageName: "closets", time: 0.1, z: 1)
        parallaxify(imageName: "glass", time: 0.05, z: 1)

        tacks = SKSpriteNode(imageNamed: "tackSize")

        for index in 1...2 {
            appendSpriteWalking(textureAtlas: textureAtlas, imageName: "walking\(index)")
        }

        for index in 1...4 {
            appendSpriteFlying(textureAtlas: textureAtlas, imageName: "flying\(index)")
        }

        for index in 1...10 {
            appendCoins(textureAtlas: textureAtlas, imageName: "coin\(index)")
        }

        for index in 1...10 {
            appendShield(textureAtlas: shieldAtlas, imageName: "shield\(index)")
        }

        for index in 1...6 {
            appendMagnet(textureAtlas: shieldAtlas, imageName: "magnet\(index)")
        }

        let groundSprite = ground[Int(arc4random_uniform(UInt32(ground.count)))]
        let grassGround = SKSpriteNode(imageNamed: groundSprite)
        let initialRandom = CGFloat(arc4random_uniform(maxRandom))

        heroSprite = SKSpriteNode(texture: spriteArrayWalking[0])
        heroSprite.position = CGPoint(
            x: startingX,
            y: startingY + initialRandom + heroSprite.size.height / 2 + grassGround.size.height / 2
        )
        heroSprite.zPosition = 10
        universe.addChild(heroSprite)
        heroSprite.physicsBody = SKPhysicsBody(rectangleOf: heroSprite.size)
        heroSprite.physicsBody?.isDynamic = true
        heroSprite.physicsBody?.allowsRotation = false
        heroSprite.physicsBody?.restitution = 0
        heroSprite.physicsBody?.categoryBitMask = HEROCATEGORY
        heroSprite.physicsBody?.collisionBitMask = GROUNDCATEGORY | BOOKCATEGORY | TACKSCATEGORY
        heroSprite.physicsBody?.contactTestBitMask = GROUNDCATEGORY | BOOKCATEGORY | FIRECATEGORY | COINCATEGORY | NUMBERCATEGORY | SHIELDCATEGORY | MAGNETCATEGORY | TACKSCATEGORY
        heroSprite.physicsBody?.usesPreciseCollisionDetection = true

        let walkingAnimation = SKAction.animate(with: spriteArrayWalking, timePerFrame: 0.1)
        repeatActionWalking = SKAction.repeatForever(.group([walkingAnimation]))
        heroSprite.run(repeatActionWalking)

        let flyingAnimation = SKAction.animate(with: spriteArrayFlying, timePerFrame: 0.1)
        repeatActionFlying = SKAction.repeatForever(.group([flyingAnimation]))

        progressLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        progressLabel.text = "Coins: \(coins)      Distance: \(meters) feet"
        progressLabel.fontSize = 15
        progressLabel.fontColor = progressColor
        progressLabel.horizontalAlignmentMode = .right
        progressLabel.position = CGPoint(x: width - progressLabel.fontSize, y: height - 2.75 * progressLabel.fontSize * scaleY)
        progressLabel.zPosition = 8
        universe.addChild(progressLabel)

        pauseButton = GGButton(
            scaleX: scaleX * 0.15,
            scaleY: scaleY * 0.4,
            defaultButtonImage: "button_default",
            activeButtonImage: "button_pressed",
            text: "||",
            textColor: gameOverColor,
            buttonAction: pauseGame
        )
        pauseButton.position = CGPoint(x: pauseButton.defaultButton.size.width / 2, y: height - pauseButton.defaultButton.size.height / 2)
        addChild(pauseButton)

        let top = SKNode()
        top.position = CGPoint(x: 0, y: height - tacks.size.height * 0.25)
        top.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: width, height: tacks.size.height * 0.5 * scaleY))
        top.physicsBody?.isDynamic = false
        top.physicsBody?.allowsRotation = false
        top.physicsBody?.restitution = 3
        top.physicsBody?.categoryBitMask = TACKSCATEGORY
        top.physicsBody?.collisionBitMask = HEROCATEGORY | BOOKCATEGORY
        universe.addChild(top)

        let bottom = SKNode()
        bottom.position = CGPoint(x: 0, y: tacks.size.height * 0.25)
        bottom.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: width, height: tacks.size.height * 0.5 * scaleY))
        bottom.physicsBody?.isDynamic = false
        bottom.physicsBody?.allowsRotation = false
        bottom.physicsBody?.restitution = 1
        bottom.physicsBody?.categoryBitMask = TACKSCATEGORY
        bottom.physicsBody?.collisionBitMask = HEROCATEGORY | BOOKCATEGORY
        universe.addChild(bottom)

        left = SKNode()
        left.zPosition = 20
        left.position = CGPoint(x: -heroSprite.size.width * 2, y: height / 2)
        left.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: height))
        left.physicsBody?.isDynamic = true
        left.physicsBody?.mass = -100
        left.physicsBody?.affectedByGravity = false
        left.physicsBody?.allowsRotation = false
        left.physicsBody?.restitution = 0
        left.physicsBody?.categoryBitMask = LEFTCATEGORY
        left.physicsBody?.contactTestBitMask = FIRECATEGORY | GROUNDCATEGORY | BOOKCATEGORY | FIRECATEGORY | COINCATEGORY | NUMBERCATEGORY | SHIELDCATEGORY | MAGNETCATEGORY
        universe.addChild(left)

        addCoins()

        positionX = addPlatform(
            imageName: ground[Int(1 + arc4random_uniform(UInt32(ground.count - 1)))],
            numberOfBlocks: minPlatformLength + arc4random_uniform(maxPlatformLength),
            x: startingX,
            y: startingY + initialRandom
        )
        for _ in 0..<Int(ceil(scaleX)) {
            positionX = addPlatform(
                imageName: ground[Int(1 + arc4random_uniform(UInt32(ground.count - 1)))],
                numberOfBlocks: minPlatformLength + arc4random_uniform(maxPlatformLength),
                x: positionX,
                y: startingY + CGFloat(arc4random_uniform(maxRandom))
            )

            positionX = addPlatform(
                imageName: ground[Int(1 + arc4random_uniform(UInt32(ground.count - 1)))],
                numberOfBlocks: minPlatformLength + arc4random_uniform(maxPlatformLength),
                x: positionX,
                y: startingY + CGFloat(arc4random_uniform(maxRandom))
            )
        }

        physicsWorld.contactDelegate = self

        if !UserDefaults.standard.bool(forKey: "notFirstTime") {
            fadeOutText("Tap anywhere to fly")
            UserDefaults.standard.set(true, forKey: "notFirstTime")
        }
    }

    func parallaxify(imageName: String, time: CGFloat, z: CGFloat) {
        let groundImage = SKTexture(imageNamed: imageName)
        let moveBackground = SKAction.moveBy(
            x: -groundImage.size().width * scaleX,
            y: 0,
            duration: TimeInterval(time * groundImage.size().width * scaleX)
        )
        let resetBackground = SKAction.moveBy(x: groundImage.size().width * scaleX, y: 0, duration: 0)
        let moveBackgroundForever = SKAction.repeatForever(.sequence([moveBackground, resetBackground]))

        let spriteCount = Int(ceil(2 + frame.size.width / (groundImage.size().width * scaleX)))
        for index in 0..<spriteCount {
            let sprite = SKSpriteNode(texture: groundImage)
            sprite.xScale = scaleX
            sprite.yScale = scaleY
            sprite.zPosition = z
            sprite.position = CGPoint(x: CGFloat(index) * sprite.size.width, y: sprite.size.height / 2)
            sprite.run(moveBackgroundForever)
            universe.addChild(sprite)
            parallaxArray.append(sprite)
        }
    }

    func addPlatform(imageName: String, numberOfBlocks: UInt32, x: CGFloat, y: CGFloat) -> CGFloat {
        var currentX = x
        let obstaclePositionX = arc4random_uniform(numberOfBlocks)

        for index in 0...numberOfBlocks {
            let grassGround = SKSpriteNode(imageNamed: imageName)
            grassGround.position = CGPoint(x: currentX, y: y)
            currentX += grassGround.size.width
            grassGround.zPosition = 10
            platformGroup.addChild(grassGround)

            grassGround.physicsBody = SKPhysicsBody(rectangleOf: grassGround.size)
            grassGround.physicsBody?.isDynamic = false
            grassGround.physicsBody?.restitution = 0
            grassGround.physicsBody?.categoryBitMask = imageName == "book" ? BOOKCATEGORY : GROUNDCATEGORY
            grassGround.physicsBody?.collisionBitMask = COINCATEGORY | NUMBERCATEGORY | SHIELDCATEGORY | MAGNETCATEGORY | HEROCATEGORY | TACKSCATEGORY

            guard imageName != "book",
                  index == obstaclePositionX,
                  obstaclePositionX != numberOfBlocks,
                  obstaclePositionX != numberOfBlocks - 1,
                  obstaclePositionX != numberOfBlocks - 2,
                  obstaclePositionX != numberOfBlocks - 3,
                  obstaclePositionX != numberOfBlocks - 4,
                  addObstacles else {
                continue
            }

            let obstacle: SKSpriteNode
            let moveObstacleForward: SKAction
            let moveObstacleBackward: SKAction
            let path = CGMutablePath()

            if obstaclePositionX % 2 == 0 {
                obstacle = SKSpriteNode(imageNamed: "protactor_obstacle")
                obstacle.position = CGPoint(x: currentX, y: grassGround.position.y + grassGround.size.height / 4 + obstacle.size.height / 2)
                moveObstacleForward = SKAction.moveBy(x: obstacle.size.width * 0.75, y: 0, duration: 0.5)
                moveObstacleBackward = SKAction.moveBy(x: -obstacle.size.width * 0.75, y: 0, duration: 0.5)

                let offsetX = obstacle.frame.size.width * obstacle.anchorPoint.x
                let offsetY = obstacle.frame.size.height * obstacle.anchorPoint.y
                path.move(to: CGPoint(x: 0 - offsetX, y: 0 - offsetY))
                path.addLine(to: CGPoint(x: 38 - offsetX, y: 0 - offsetY))
                path.addLine(to: CGPoint(x: 38 - offsetX, y: 6 - offsetY))
                path.addLine(to: CGPoint(x: 36 - offsetX, y: 10 - offsetY))
                path.addLine(to: CGPoint(x: 30 - offsetX, y: 15 - offsetY))
                path.addLine(to: CGPoint(x: 25 - offsetX, y: 19 - offsetY))
                path.addLine(to: CGPoint(x: 19 - offsetX, y: 19 - offsetY))
                path.addLine(to: CGPoint(x: 11 - offsetX, y: 18 - offsetY))
                path.addLine(to: CGPoint(x: 5 - offsetX, y: 14 - offsetY))
                path.addLine(to: CGPoint(x: 1 - offsetX, y: 7 - offsetY))
            } else {
                obstacle = SKSpriteNode(imageNamed: "pencil_obstacle")
                obstacle.position = CGPoint(x: currentX, y: grassGround.position.y + grassGround.size.height)
                moveObstacleForward = SKAction.moveBy(x: 0, y: obstacle.size.height * 0.15, duration: 0.25)
                moveObstacleBackward = SKAction.moveBy(x: 0, y: -obstacle.size.height * 0.15, duration: 0.25)

                let offsetX = obstacle.frame.size.width * obstacle.anchorPoint.x
                let offsetY = obstacle.frame.size.height * obstacle.anchorPoint.y
                path.move(to: CGPoint(x: 0 - offsetX, y: 0 - offsetY))
                path.addLine(to: CGPoint(x: 4 - offsetX, y: 0 - offsetY))
                path.addLine(to: CGPoint(x: 4 - offsetX, y: 25 - offsetY))
                path.addLine(to: CGPoint(x: 2 - offsetX, y: 30 - offsetY))
                path.addLine(to: CGPoint(x: 0 - offsetX, y: 25 - offsetY))
            }

            path.closeSubpath()

            let moveObstacleForever = SKAction.repeatForever(
                .sequence([moveObstacleForward, moveObstacleBackward, moveObstacleBackward, moveObstacleForward])
            )
            obstacle.run(moveObstacleForever)
            obstacle.zPosition = 6
            world.addChild(obstacle)
            obstacle.physicsBody = SKPhysicsBody(polygonFrom: path)
            obstacle.physicsBody?.isDynamic = false
            obstacle.physicsBody?.restitution = 0
            obstacle.physicsBody?.categoryBitMask = FIRECATEGORY
            obstacle.physicsBody?.contactTestBitMask = COINCATEGORY | NUMBERCATEGORY | SHIELDCATEGORY | MAGNETCATEGORY | HEROCATEGORY | LEFTCATEGORY
            obstacle.physicsBody?.collisionBitMask = HEROCATEGORY | LEFTCATEGORY
        }

        return currentX + heroSprite.size.width * 4
    }

    func appendSpriteWalking(textureAtlas: SKTextureAtlas, imageName: String) {
        spriteArrayWalking.append(textureAtlas.textureNamed(imageName))
    }

    func appendSpriteFlying(textureAtlas: SKTextureAtlas, imageName: String) {
        spriteArrayFlying.append(textureAtlas.textureNamed(imageName))
    }

    func appendCoins(textureAtlas: SKTextureAtlas, imageName: String) {
        coinsArray.append(textureAtlas.textureNamed(imageName))
    }

    func appendShield(textureAtlas: SKTextureAtlas, imageName: String) {
        shieldArray.append(textureAtlas.textureNamed(imageName))
    }

    func appendMagnet(textureAtlas: SKTextureAtlas, imageName: String) {
        magnetArray.append(textureAtlas.textureNamed(imageName))
    }

    func rotateForever(sprite: SKSpriteNode) {
        let rotate = SKAction.rotate(byAngle: .pi, duration: 0.5)
        sprite.run(.repeatForever(rotate))
    }

    func fireRulers(x: CGFloat) {
        let sizeRuler = SKSpriteNode(imageNamed: "ruler_fire")

        var firstY = arc4random_uniform(UInt32(height))
        var secondY = arc4random_uniform(UInt32(height))

        while abs(Int(firstY) - Int(secondY)) < minDifferenceBetweenRulers / 10 {
            firstY = arc4random_uniform(UInt32(sizeRuler.size.height))
            secondY = arc4random_uniform(UInt32(height - sizeRuler.size.height))
        }

        for yPosition in [firstY, secondY] {
            let ruler = SKSpriteNode(imageNamed: "ruler_fire")
            ruler.xScale = scaleX
            ruler.yScale = scaleY
            ruler.position = CGPoint(x: x, y: CGFloat(yPosition))
            ruler.zPosition = 11
            world.addChild(ruler)
            rotateForever(sprite: ruler)
            ruler.physicsBody = SKPhysicsBody(rectangleOf: ruler.size)
            ruler.physicsBody?.isDynamic = false
            ruler.physicsBody?.allowsRotation = false
            ruler.physicsBody?.restitution = 0
            ruler.physicsBody?.categoryBitMask = FIRECATEGORY
            ruler.physicsBody?.contactTestBitMask = COINCATEGORY | NUMBERCATEGORY | SHIELDCATEGORY | MAGNETCATEGORY | HEROCATEGORY | LEFTCATEGORY
            ruler.physicsBody?.collisionBitMask = HEROCATEGORY | LEFTCATEGORY
            ruler.physicsBody?.usesPreciseCollisionDetection = false
            rulerFireArray.append(ruler)
        }
    }

    func goToGameScene() {
        let transition = SKTransition.reveal(with: .left, duration: 2)
        let scene = MathScene(size: size, score: score, coins: coins)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: transition)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLeft = true
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
        finalmeters.fontColor = gameOverColor
        finalmeters.position = CGPoint(x: width / 2, y: height / 2 + finalmeters.fontSize / 2)
        finalmeters.zPosition = 13
        addChild(finalmeters)

        buttonHome = GGButton(
            scaleX: 0.5,
            scaleY: 0.5,
            defaultButtonImage: "button_default",
            activeButtonImage: "button_pressed",
            text: "Home",
            textColor: gameOverColor,
            buttonAction: goToHomeScene
        )
        buttonHome.position = CGPoint(x: width / 2 - buttonHome.defaultButton.size.width, y: height / 2 - buttonHome.defaultButton.size.height / 2)
        addChild(buttonHome)

        buttonResume = GGButton(
            scaleX: 0.5,
            scaleY: 0.5,
            defaultButtonImage: "button_default",
            activeButtonImage: "button_pressed",
            text: "Resume",
            textColor: gameOverColor,
            buttonAction: resumeGame
        )
        buttonResume.position = CGPoint(x: width / 2, y: height / 2 - buttonResume.defaultButton.size.height / 2)
        addChild(buttonResume)

        buttonRetry = GGButton(
            scaleX: 0.5,
            scaleY: 0.5,
            defaultButtonImage: "button_default",
            activeButtonImage: "button_pressed",
            text: "Retry",
            textColor: gameOverColor,
            buttonAction: retry
        )
        buttonRetry.position = CGPoint(x: width / 2 + buttonRetry.defaultButton.size.width, y: height / 2 - buttonRetry.defaultButton.size.height / 2)
        addChild(buttonRetry)

        pauseButton.removeFromParent()
        isPaused = true
    }

    func resumeGame() {
        appDelegate?.backgroundMusicPlayer?.play()

        isPaused = false

        finalmeters.removeFromParent()
        buttonHome.removeFromParent()
        buttonResume.removeFromParent()
        buttonRetry.removeFromParent()
        universe.removeFromParent()
        effectsNode.removeFromParent()
        addChild(universe)
        addChild(pauseButton)
    }

    func retry() {
        let transition = SKTransition.reveal(with: .left, duration: 2)
        let scene = GameScene(size: size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: transition)
    }

    func goToHomeScene() {
        let transition = SKTransition.reveal(with: .right, duration: 2)
        let scene = Home(size: size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: transition)
    }

    func playSound(_ soundName: String) {
        if !soundOff {
            run(SKAction.playSoundFileNamed("\(soundName).wav", waitForCompletion: false))
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        if firstBody.categoryBitMask == HEROCATEGORY {
            if secondBody.categoryBitMask == FIRECATEGORY || secondBody.categoryBitMask == TACKSCATEGORY {
                if !shield && !magnet {
                    playSound("Died")
                    gameOver = true
                } else if shield {
                    playSound("Pop")
                    if let body = heroSprite.physicsBody {
                        body.velocity = CGVector(dx: body.velocity.dx, dy: 0)
                        body.applyImpulse(CGVector(dx: 0, dy: jumpHeight / 3))
                    }

                    shield = false
                    shieldSprite.removeFromParent()
                } else if magnet {
                    playSound("Pop")
                    if let body = heroSprite.physicsBody {
                        body.velocity = CGVector(dx: body.velocity.dx, dy: 0)
                        body.applyImpulse(CGVector(dx: 0, dy: jumpHeight / 3))
                    }

                    magnet = false
                    magnetSprite.removeFromParent()

                    let animateAction = SKAction.animate(with: coinsArray, timePerFrame: 0.1)
                    coinAction = SKAction.repeatForever(.group([animateAction]))

                    for singleCoin in coinSpriteArray {
                        singleCoin.physicsBody?.usesPreciseCollisionDetection = false
                        singleCoin.removeAllActions()
                        singleCoin.run(coinAction)
                    }
                }

                if secondBody.categoryBitMask == FIRECATEGORY {
                    secondBody.node?.removeFromParent()
                }
            } else if secondBody.categoryBitMask == GROUNDCATEGORY {
                heroSprite.removeAllActions()
                heroSprite.run(repeatActionWalking)
            } else if secondBody.categoryBitMask == BOOKCATEGORY {
                heroSprite.removeAllActions()
                heroSprite.run(repeatActionWalking)
                secondBody.isDynamic = true
            } else if secondBody.categoryBitMask == COINCATEGORY {
                coins += 1
                secondBody.node?.removeFromParent()
                playSound("Coin")
            } else if secondBody.categoryBitMask == NUMBERCATEGORY {
                whichNumber = secondBody.node?.name ?? ""
                secondBody.node?.removeFromParent()
            } else if secondBody.categoryBitMask == SHIELDCATEGORY {
                playSound("Shield")

                magnetSprite?.removeFromParent()
                magnet = false

                shieldSprite?.removeFromParent()
                shield = true
                shieldSprite = SKSpriteNode(texture: shieldArray[0])
                let animateAction = SKAction.animate(with: shieldArray, timePerFrame: 0.1)
                shieldAction = SKAction.repeatForever(.group([animateAction]))
                shieldSprite.run(shieldAction)
                shieldSprite.position = heroSprite.position
                shieldSprite.zPosition = 12
                universe.addChild(shieldSprite)

                secondBody.node?.removeFromParent()
            } else if secondBody.categoryBitMask == MAGNETCATEGORY {
                playSound("Magnet")

                shieldSprite?.removeFromParent()
                shield = false

                magnetSprite?.removeFromParent()
                magnet = true
                magnetSprite = SKSpriteNode(texture: magnetArray[0])
                let animateAction = SKAction.animate(with: magnetArray, timePerFrame: 0.1)
                magnetAction = SKAction.repeatForever(.group([animateAction]))
                magnetSprite.run(magnetAction)
                magnetSprite.position = heroSprite.position
                magnetSprite.zPosition = 9
                universe.addChild(magnetSprite)

                secondBody.node?.removeFromParent()
            }
        } else if firstBody.categoryBitMask == LEFTCATEGORY {
            secondBody.node?.removeFromParent()
        } else if secondBody.categoryBitMask == LEFTCATEGORY {
            firstBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask != FIRECATEGORY && secondBody.categoryBitMask != FIRECATEGORY {
            secondBody.node?.removeFromParent()
        }
    }

    func addCoins() {
        for _ in 0...minPlatformLength / 2 {
            coinSprite = SKSpriteNode(texture: coinsArray[0])
            coinSprite.position = CGPoint(
                x: positionX + 3 * coinSprite.size.width + CGFloat(arc4random_uniform(UInt32(width / 8))),
                y: coinSprite.size.height + CGFloat(arc4random_uniform(UInt32(height - 2 * coinSprite.size.height)))
            )

            let animateAction = SKAction.animate(with: coinsArray, timePerFrame: 0.1)
            coinAction = SKAction.repeatForever(.group([animateAction]))
            coinSprite.run(coinAction)
            coinSprite.zPosition = 12
            world.addChild(coinSprite)

            coinSprite.physicsBody = SKPhysicsBody(rectangleOf: coinSprite.size)
            coinSprite.physicsBody?.isDynamic = true
//            coinSprite.physicsBody?.mass = -100
            coinSprite.physicsBody?.affectedByGravity = false
            coinSprite.physicsBody?.allowsRotation = false
            coinSprite.physicsBody?.restitution = 0
            coinSprite.physicsBody?.categoryBitMask = COINCATEGORY
            coinSprite.physicsBody?.contactTestBitMask = FIRECATEGORY
            coinSprite.physicsBody?.collisionBitMask = GROUNDCATEGORY | BOOKCATEGORY | NUMBERCATEGORY | SHIELDCATEGORY | MAGNETCATEGORY | HEROCATEGORY

            coinSpriteArray.append(coinSprite)
        }
    }

    func addPositiveNumber() {
        let name = positiveNumbers[Int(arc4random_uniform(UInt32(positiveNumbers.count)))]
        let numberSprite = SKSpriteNode(imageNamed: name)
        numberSprite.name = name
        numberSprite.position = CGPoint(
            x: positionX + CGFloat(arc4random_uniform(UInt32(width / 8))),
            y: numberSprite.size.height + CGFloat(arc4random_uniform(UInt32(height - 2 * numberSprite.size.height)))
        )
        numberSprite.zPosition = 12
        world.addChild(numberSprite)

        numberSprite.physicsBody = SKPhysicsBody(rectangleOf: numberSprite.size)
        numberSprite.physicsBody?.isDynamic = true
//        numberSprite.physicsBody?.mass = -100
        numberSprite.physicsBody?.affectedByGravity = false
        numberSprite.physicsBody?.allowsRotation = false
        numberSprite.physicsBody?.restitution = 0
        numberSprite.physicsBody?.categoryBitMask = NUMBERCATEGORY
        numberSprite.physicsBody?.collisionBitMask = GROUNDCATEGORY | BOOKCATEGORY | COINCATEGORY | SHIELDCATEGORY | MAGNETCATEGORY | HEROCATEGORY
        numberSprite.physicsBody?.contactTestBitMask = FIRECATEGORY
    }

    func addNegativeNumber() {
        let name = negativeNumbers[Int(arc4random_uniform(UInt32(negativeNumbers.count)))]
        let numberSprite = SKSpriteNode(imageNamed: name)
        numberSprite.name = name
        numberSprite.position = CGPoint(
            x: positionX + CGFloat(arc4random_uniform(UInt32(width / 8))),
            y: numberSprite.size.height + CGFloat(arc4random_uniform(UInt32(height - 2 * numberSprite.size.height)))
        )
        numberSprite.zPosition = 12
        world.addChild(numberSprite)

        numberSprite.physicsBody = SKPhysicsBody(rectangleOf: numberSprite.size)
        numberSprite.physicsBody?.isDynamic = true
//        numberSprite.physicsBody?.mass = -100
        numberSprite.physicsBody?.affectedByGravity = false
        numberSprite.physicsBody?.allowsRotation = false
        numberSprite.physicsBody?.restitution = 0
        numberSprite.physicsBody?.categoryBitMask = NUMBERCATEGORY
        numberSprite.physicsBody?.collisionBitMask = GROUNDCATEGORY | BOOKCATEGORY | COINCATEGORY | SHIELDCATEGORY | MAGNETCATEGORY | HEROCATEGORY
        numberSprite.physicsBody?.contactTestBitMask = FIRECATEGORY
    }

    func addShield() {
        let itemNode = SKSpriteNode(texture: shieldArray[0])
        let animateAction = SKAction.animate(with: shieldArray, timePerFrame: 0.1)
        shieldAction = SKAction.repeatForever(.group([animateAction]))
        itemNode.run(shieldAction)
        itemNode.position = CGPoint(
            x: positionX + CGFloat(arc4random_uniform(UInt32(width / 8))),
            y: itemNode.size.height + CGFloat(arc4random_uniform(UInt32(height - 2 * itemNode.size.height)))
        )
        itemNode.zPosition = 12
        world.addChild(itemNode)

        itemNode.physicsBody = SKPhysicsBody(rectangleOf: itemNode.size)
        itemNode.physicsBody?.isDynamic = true
//        itemNode.physicsBody?.mass = -100
        itemNode.physicsBody?.affectedByGravity = false
        itemNode.physicsBody?.allowsRotation = false
        itemNode.physicsBody?.restitution = 0
        itemNode.physicsBody?.categoryBitMask = SHIELDCATEGORY
        itemNode.physicsBody?.collisionBitMask = GROUNDCATEGORY | BOOKCATEGORY | COINCATEGORY | NUMBERCATEGORY | MAGNETCATEGORY | HEROCATEGORY
        itemNode.physicsBody?.contactTestBitMask = FIRECATEGORY
    }

    func addMagnet() {
        let itemNode = SKSpriteNode(texture: magnetArray[0])
        let animateAction = SKAction.animate(with: magnetArray, timePerFrame: 0.1)
        magnetAction = SKAction.repeatForever(.group([animateAction]))
        itemNode.run(magnetAction)
        itemNode.position = CGPoint(
            x: positionX + CGFloat(arc4random_uniform(UInt32(width / 8))),
            y: itemNode.size.height + CGFloat(arc4random_uniform(UInt32(height - 2 * itemNode.size.height)))
        )
        itemNode.zPosition = 9
        world.addChild(itemNode)

        itemNode.physicsBody = SKPhysicsBody(rectangleOf: itemNode.size)
        itemNode.physicsBody?.isDynamic = true
//        itemNode.physicsBody?.mass = -100
        itemNode.physicsBody?.affectedByGravity = false
        itemNode.physicsBody?.allowsRotation = false
        itemNode.physicsBody?.restitution = 0
        itemNode.physicsBody?.categoryBitMask = MAGNETCATEGORY
        itemNode.physicsBody?.contactTestBitMask = FIRECATEGORY
        itemNode.physicsBody?.collisionBitMask = GROUNDCATEGORY | BOOKCATEGORY | COINCATEGORY | NUMBERCATEGORY | SHIELDCATEGORY | HEROCATEGORY
    }

    func rememberYourScore() {
        showScore = false
        if !UserDefaults.standard.bool(forKey: "notFirstTimeRememberScore") {
            fadeOutText("Remember your score!")
            UserDefaults.standard.set(true, forKey: "notFirstTimeRememberScore")
        }
    }

    override func update(_ currentTime: TimeInterval) {
        if !isPaused {
            if !gameOver {
                if touchLeft {
                    touchLeft = false
                    heroSprite.removeAllActions()
                    heroSprite.run(repeatActionFlying)
                    if let body = heroSprite.physicsBody {
                        body.velocity = CGVector(dx: body.velocity.dx, dy: 0)
                        body.applyImpulse(CGVector(dx: 0, dy: jumpHeight))
                    }
                }

                if shield {
                    shieldSprite.position = heroSprite.position
                } else if magnet {
                    magnetSprite.position = heroSprite.position

                    let moveToPlayerY = SKAction.moveTo(y: heroSprite.position.y, duration: 0.1)
                    for singleCoin in coinSpriteArray {
                        singleCoin.physicsBody?.usesPreciseCollisionDetection = true
                        singleCoin.run(moveToPlayerY)
                    }

                    let moveToPlayerX = SKAction.moveTo(x: heroSprite.position.x, duration: 10)
                    for singleCoin in coinSpriteArray {
                        singleCoin.physicsBody?.usesPreciseCollisionDetection = true
                        singleCoin.run(moveToPlayerX)
                    }
                }

                heroSprite.position.x = startingX
                left.position = CGPoint(x: -heroSprite.size.width * 2, y: height / 2)
                world.position.x -= playerVelocity
                for ruler in rulerFireArray {
                    ruler.position.x -= 1.2 * playerVelocity
                }
                distanceMoved += playerVelocity

                switch whichNumber {
                case "plus1":
                    playSound("PositiveNumber")
                    score += 1
                    rememberYourScore()
                case "plus10":
                    playSound("PositiveNumber")
                    score += 10
                    rememberYourScore()
                case "plus100":
                    playSound("PositiveNumber")
                    score += 100
                    rememberYourScore()
                case "minus1":
                    playSound("NegativeNumber")
                    if score > 0 {
                        score -= 1
                    }
                    rememberYourScore()
                case "minus10":
                    playSound("NegativeNumber")
                    if score > 9 {
                        score -= 10
                    }
                    rememberYourScore()
                case "minus100":
                    playSound("NegativeNumber")
                    if score > 99 {
                        score -= 100
                    }
                    rememberYourScore()
                case "multiply10":
                    playSound("PositiveNumber")
                    score *= 10
                    rememberYourScore()
                case "multiply100":
                    playSound("PositiveNumber")
                    score *= 100
                    rememberYourScore()
                case "divide10":
                    playSound("NegativeNumber")
                    score /= 10
                    rememberYourScore()
                case "divide100":
                    playSound("NegativeNumber")
                    score /= 100
                    rememberYourScore()
                case "showScore":
                    showScore = true
                    fadeOutText("Score: \(score)")
                default:
                    break
                }
                whichNumber = ""

                if showScore {
                    progressLabel.text = "Score: \(score)     Coins: \(coins)     Distance: \(meters) feet"
                } else {
                    progressLabel.text = "Coins: \(coins)     Distance: \(meters) feet"
                }

                if distanceMoved > width / 2 &&
                    platformGroup.children.count <= Int(maxPlatformLength * 3) * Int(ceil(scaleX)) {
                    playerVelocity += 0.01
                    distanceMoved = 0
                    meters += 1
                    timeSinceRuler += 1
                    timeSinceShield += 1

                    addObstacles = true

                    addCoins()
                    for _ in 0..<Int(ceil(scaleX)) {
                        positionX = addPlatform(
                            imageName: ground[Int(arc4random_uniform(UInt32(ground.count)))],
                            numberOfBlocks: minPlatformLength + arc4random_uniform(maxPlatformLength),
                            x: positionX,
                            y: startingY + CGFloat(arc4random_uniform(maxRandom))
                        )
                    }

                    if !UserDefaults.standard.bool(forKey: "notFirstTimeGoldenNumbers") {
                        fadeOutText("Collect golden numbers")
                        UserDefaults.standard.set(true, forKey: "notFirstTimeGoldenNumbers")
                    }

                    if score >= 100 {
                        let randomBoolean = arc4random() % 2
                        if randomBoolean == 0 {
                            addNegativeNumber()
                        } else {
                            addPositiveNumber()
                        }
                    } else {
                        addPositiveNumber()
                    }

                    if timeSinceShield >= 5 {
                        timeSinceShield = 0
                        minDifferenceBetweenRulers -= 1
                        let randomBoolean = arc4random() % 2
                        if !shield && randomBoolean == 0 {
                            addShield()
                        }
                        if !magnet && randomBoolean == 1 {
                            addMagnet()
                        }
                    }

                    if timeSinceRuler >= 3 {
                        timeSinceRuler = 0
                        fireRulers(x: positionX + width)
                    }
                }
            } else if !executed {
                appDelegate?.backgroundMusicPlayer?.stop()

                world.removeAllChildren()
                pauseButton.removeFromParent()

                effectsNode.shouldEnableEffects = true

                universe.removeFromParent()
                effectsNode.addChild(universe)
                addChild(effectsNode)

                let finalLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
                finalLabel.text = "You ran \(meters) feet!"
                finalLabel.fontSize = 50
                finalLabel.fontColor = gameOverColor
                finalLabel.position = CGPoint(x: width / 2, y: height / 2 + finalLabel.fontSize / 2)
                finalLabel.zPosition = 13
                addChild(finalLabel)

                let mathButton = GGButton(
                    scaleX: 1,
                    scaleY: 1,
                    defaultButtonImage: "button_default",
                    activeButtonImage: "button_pressed",
                    text: "Math",
                    textColor: gameOverColor,
                    buttonAction: goToGameScene
                )
                mathButton.position = CGPoint(x: width / 2, y: height / 2 - mathButton.defaultButton.size.height / 2)
                addChild(mathButton)

                executed = true
                for parallaxElement in parallaxArray {
                    parallaxElement.removeAllActions()
                }
            }
        }
    }
}
