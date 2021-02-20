//
//  GameScene.swift
//  MathQuest
//
//  Created by Adnan Zahid on 2/10/15.
//  Copyright (c) 2015 Adnan Zahid. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var width: CGFloat = 0;
    var height: CGFloat = 0;
    
    var scaleX: CGFloat = 0;
    var scaleY: CGFloat = 0;
    
    var gameOver: Bool = false;
    var showScore: Bool = false;
    var shield: Bool = false;
    var magnet: Bool = false;
    var addObstacles: Bool = false;
    var playerVelocity: CGFloat = 2;
    var minDifferenceBetweenRulers = 2500;
    var jumpHeight: CGFloat = 0;
    var gravity: CGFloat = 0;
    var timeSinceRuler: UInt8 = 0;
    var timeSinceShield: UInt8 = 0;
    
    var universe: SKNode!;
    var world: SKNode!;
    var platformGroup: SKNode!;
    var spriteArrayWalking = Array<SKTexture>();
    var spriteArrayFlying = Array<SKTexture>();
    var coinsArray = Array<SKTexture>();
    var shieldArray = Array<SKTexture>();
    var magnetArray = Array<SKTexture>();
    var rulerFireArray = Array<SKSpriteNode>();
    var heroSprite: SKSpriteNode!;
    var coinSprite: SKSpriteNode!;
    var coinSpriteArray = Array<SKSpriteNode>();
    var shieldSprite: SKSpriteNode!;
    var magnetSprite: SKSpriteNode!;
    var tacks: SKSpriteNode!;
    var distanceMoved: CGFloat = 0;
    var progressLabel: SKLabelNode!;
    var score: UInt32 = 0;
    var coins: UInt32 = 0;
    var meters: UInt32 = 0;
    
    let backgrounds: [NSString] = ["blue_background", "green_background", "orange_background", "pink_background"];
    let positiveNumbers: [NSString] = [
        "plus1",
        "plus10",
        "plus100",
        "showScore"];
    let negativeNumbers: [NSString] = [
        "minus1",
        "minus10",
        "minus100",
        "divide10",
        "divide100"];
    var whichNumber: NSString = "";
    
    var touchLeft: Bool = false;
    var touchRight: Bool = false;
    
    var repeatActionWalking: SKAction!;
    var repeatActionFlying: SKAction!;
    var shieldAction: SKAction!;
    var magnetAction: SKAction!;
    var coinAction: SKAction!;
    
    let startingX: CGFloat = 60;
    let startingY: CGFloat = 60;
    var positionX: CGFloat = 0;
    let ground: [NSString] = ["book", "ruler", "box"];
    let maxRandom: UInt32 = 150;
    let minPlatformLength: UInt32 = 7;
    let maxPlatformLength: UInt32 = 12;
    
    let HEROCATEGORY: UInt32 = 0x1 << 0;
    let LEFTCATEGORY: UInt32 = 0x1 << 1;
    let GROUNDCATEGORY: UInt32 = 0x1 << 2;
    let TACKSCATEGORY: UInt32 = 0x1 << 3;
    let BOOKCATEGORY: UInt32 = 0x1 << 4;
    let FIRECATEGORY: UInt32 = 0x1 << 5;
    let COINCATEGORY: UInt32 = 0x1 << 6;
    let NUMBERCATEGORY: UInt32 = 0x1 << 7;
    let SHIELDCATEGORY: UInt32 = 0x1 << 8;
    let MAGNETCATEGORY: UInt32 = 0x1 << 9;
    
    var left: SKNode!;
    
    var parallaxArray = Array<SKNode>();
    var gameOverColor: SKColor = SKColor(red: 0, green: 0.4784313725, blue: 1, alpha: 0.5);
    var progressColor: SKColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1);
    
    var pauseButton: GGButton!;
    var effectsNode: SKEffectNode!;
    var finalmeters: SKLabelNode!;
    var buttonHome: GGButton!;
    var buttonResume: GGButton!;
    var buttonRetry: GGButton!;
    
    var executed: Bool = false;
    
    var bannerHeight: CGFloat = 0;
    var soundOff: Bool = false;
    var adMobBannerView: GADBannerView!;
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate;
    
    func playBackgroundMusic() {
        
        if !UserDefaults.standard.bool(forKey: "musicOff") {
            let backgroundMusicURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "GameScene", ofType: "wav")!)
            appDelegate.backgroundMusicPlayer = try! AVAudioPlayer(contentsOf: backgroundMusicURL as URL)
            appDelegate.backgroundMusicPlayer.numberOfLoops = -1
            appDelegate.backgroundMusicPlayer.prepareToPlay()
            appDelegate.backgroundMusicPlayer.play()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: CGSize, bannerHeight: CGFloat, bannerView: GADBannerView) {
        super.init(size: size);
        self.bannerHeight = bannerHeight;
        self.adMobBannerView = bannerView;
    }
    
    func fadeOutText(textString: NSString) {
        
        playSound(soundName: "FadeOut");
        let label = SKLabelNode(fontNamed:"Chalkduster");
        label.text = textString as String;
        label.fontSize = 20;
        label.fontColor = SKColor.white;
        label.position = CGPoint(x:width/2, y:height/2);
        label.xScale = scaleX;
        label.yScale = scaleY;
        label.zPosition = 20;
        universe.addChild(label);
        
        var flashAction: SKAction = SKAction.scale(by: 4, duration: 5);
        label.run(flashAction);
        flashAction = SKAction.fadeOut(withDuration: 5);
        label.run(flashAction, completion: {label.removeFromParent();});
    }
    
    override func didMove(to view: SKView) {
        
        appDelegate.backgroundMusicPlayer.stop();
        playBackgroundMusic();
        
        effectsNode = SKEffectNode();
        let filter = CIFilter(name: "CIGaussianBlur");
        filter?.setValue(32, forKey: kCIInputRadiusKey);
        
        effectsNode.filter = filter;
        effectsNode.blendMode = .alpha;
        effectsNode.shouldEnableEffects = true;
        effectsNode.shouldEnableEffects = false;
        effectsNode.shouldRasterize = true;
        
        soundOff = UserDefaults.standard.bool(forKey: "soundOff");
        
        width = frame.maxX;
        height = frame.maxY;
        
        height -= bannerHeight;
        
        jumpHeight = height*0.04167;
        gravity = -height/200;
        
        playerVelocity = CGFloat(UserDefaults.standard.integer(forKey: "difficulty")) + 2;
        
        let textureAtlas = SKTextureAtlas(named:"hero.atlas");
        let shieldAtlas = SKTextureAtlas(named:"shield.atlas");
        
        universe = SKNode();
        addChild(universe);
        world = SKNode();
        universe.addChild(world);
        platformGroup = SKNode();
        world.addChild(platformGroup);
        
        physicsWorld.gravity = CGVector(dx: 0, dy: gravity);
        
        let background = SKSpriteNode(imageNamed:backgrounds[Int(arc4random_uniform(UInt32(backgrounds.count)))] as String);
        scaleX = width/background.size.width;
        scaleY = height/background.size.height;
        background.xScale = scaleX;
        background.yScale = scaleY;
        background.position = CGPoint(x:width/2, y:height/2);
        background.zPosition = 0;
        universe.addChild(background);
        
        parallaxify(imageName: "closets", time: 0.1, z: 1);
        parallaxify(imageName: "glass", time: 0.05, z: 1);
        
        tacks = SKSpriteNode(imageNamed: "tackSize");
        
        for i in 1...2 {
            appendSpriteWalking(textureAtlas: textureAtlas, imageName: "walking"+String(i) as NSString);
        }
        
        for i in 1...4 {
            appendSpriteFlying(textureAtlas: textureAtlas, imageName: "flying"+String(i) as NSString);
        }
        
        for i in 1...10 {
            appendCoins(textureAtlas: textureAtlas, imageName: "coin"+String(i) as NSString);
        }
        
        for i in 1...10 {
            appendShield(textureAtlas: shieldAtlas, imageName: "shield"+String(i) as NSString);
        }
        
        for i in 1...6 {
            appendMagnet(textureAtlas: shieldAtlas, imageName: "magnet"+String(i) as NSString);
        }
        
        let groundSprite: NSString = ground[Int(arc4random_uniform(UInt32(ground.count)))];
        let grassGround = SKSpriteNode(imageNamed:groundSprite as String);
        
        let initialRandom: CGFloat = CGFloat(arc4random_uniform(maxRandom));
        
        heroSprite = SKSpriteNode(texture:spriteArrayWalking[0]);
        heroSprite.position = CGPoint(x:startingX,y:startingY + initialRandom + heroSprite.size.height/2 + grassGround.size.height/2);
        heroSprite.zPosition = 10;
        universe.addChild(heroSprite);
        heroSprite.physicsBody = SKPhysicsBody(rectangleOf: heroSprite.size);
        heroSprite.physicsBody!.isDynamic = true;
        heroSprite.physicsBody!.allowsRotation = false;
        heroSprite.physicsBody!.restitution = 0;
        
        heroSprite.physicsBody!.categoryBitMask = HEROCATEGORY;
        heroSprite.physicsBody!.collisionBitMask = GROUNDCATEGORY | BOOKCATEGORY | TACKSCATEGORY;
        heroSprite.physicsBody!.contactTestBitMask = GROUNDCATEGORY | BOOKCATEGORY | FIRECATEGORY | COINCATEGORY | NUMBERCATEGORY | SHIELDCATEGORY | MAGNETCATEGORY | TACKSCATEGORY;
        heroSprite.physicsBody?.usesPreciseCollisionDetection;
        
        var animateAction = SKAction.animate(with: spriteArrayWalking, timePerFrame: 0.1);
        var group = SKAction.group([ animateAction ]);
        repeatActionWalking = SKAction.repeatForever(group);
        heroSprite.run(repeatActionWalking);
        
        animateAction = SKAction.animate(with: spriteArrayFlying, timePerFrame: 0.1);
        group = SKAction.group([ animateAction ]);
        repeatActionFlying = SKAction.repeatForever(group);
        
        progressLabel = SKLabelNode(fontNamed:"ChalkboardSE-Bold");
        progressLabel.text = "Coins: " + String(coins) + "      Distance: " + String(meters) + " feet";
        progressLabel.fontSize = 15;
        progressLabel.fontColor = progressColor;
        progressLabel.horizontalAlignmentMode = .right
        progressLabel.position = CGPoint(x:width-progressLabel.fontSize, y:height-2.75*progressLabel.fontSize*scaleY);
        progressLabel.zPosition = 8;
        
        universe.addChild(progressLabel);
        
        pauseButton = GGButton(scaleX: scaleX*0.15, scaleY: scaleY*0.4, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "||", textColor: gameOverColor, buttonAction: pauseGame);
        pauseButton.position = CGPoint(x: pauseButton.defaultButton.size.width/2,
                                       y: height-pauseButton.defaultButton.size.height/2);
        addChild(pauseButton);
        
        let top: SKNode = SKNode();
        top.position = CGPoint(x: 0, y: height - tacks.size.height*0.25);
        top.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: width, height: tacks.size.height*0.5*scaleY));
        top.physicsBody!.isDynamic = false;
        top.physicsBody!.allowsRotation = false;
        top.physicsBody!.restitution = 3;
        top.physicsBody!.categoryBitMask = TACKSCATEGORY;
        top.physicsBody!.collisionBitMask = HEROCATEGORY | BOOKCATEGORY;
        universe.addChild(top);
        
        let bottom: SKNode = SKNode();
        bottom.position = CGPoint(x: 0, y: tacks.size.height*0.25);
        bottom.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: width, height: tacks.size.height*0.5*scaleY));
        bottom.physicsBody!.isDynamic = false;
        bottom.physicsBody!.allowsRotation = false;
        bottom.physicsBody!.restitution = 1;
        bottom.physicsBody!.categoryBitMask = TACKSCATEGORY;
        bottom.physicsBody!.collisionBitMask = HEROCATEGORY | BOOKCATEGORY;
        universe.addChild(bottom);
        
        left = SKNode();
        left.zPosition = 20;
        left.position = CGPoint(x: -heroSprite.size.width*2, y: height/2);
        left.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: height));
        left.physicsBody!.isDynamic = true;
        left.physicsBody!.mass = -100;
        left.physicsBody!.affectedByGravity = false;
        left.physicsBody!.allowsRotation = false;
        left.physicsBody!.restitution = 0;
        left.physicsBody!.categoryBitMask = LEFTCATEGORY;
        left.physicsBody!.contactTestBitMask = FIRECATEGORY | GROUNDCATEGORY | BOOKCATEGORY |  FIRECATEGORY | COINCATEGORY | NUMBERCATEGORY | SHIELDCATEGORY | MAGNETCATEGORY;
        universe.addChild(left);
        
        addCoins();
        
        positionX = addPlatform(imageName: ground[Int(1+arc4random_uniform(UInt32(ground.count-1)))], numberOfBlocks: minPlatformLength + arc4random_uniform(maxPlatformLength), x: startingX, y: startingY + initialRandom);
        for i in 0..<UInt8(ceil(scaleX)) {
            
            positionX = addPlatform(imageName: ground[Int(1+arc4random_uniform(UInt32(ground.count-1)))], numberOfBlocks: minPlatformLength + arc4random_uniform(maxPlatformLength), x: positionX, y: startingY + CGFloat(arc4random_uniform(maxRandom)));
            
            positionX = addPlatform(imageName: ground[Int(1+arc4random_uniform(UInt32(ground.count-1)))], numberOfBlocks: minPlatformLength + arc4random_uniform(maxPlatformLength), x: positionX, y: startingY + CGFloat(arc4random_uniform(maxRandom)));
        }
        physicsWorld.contactDelegate = self;
        
        if !UserDefaults.standard.bool(forKey: "notFirstTime") {
            fadeOutText(textString: "Tap anywhere to fly");
            UserDefaults.standard.set(true, forKey: "notFirstTime");
            UserDefaults.standard.synchronize();
        }
    }
    
    func parallaxify(imageName: NSString, time: CGFloat, z: CGFloat) {
        
        var groundImage = SKTexture(imageNamed: imageName as String);
        
        var moveBackground = SKAction.moveBy(x: -groundImage.size().width*scaleX, y: 0, duration: TimeInterval(time * groundImage.size().width*scaleX));
        
        var resetBackGround = SKAction.moveBy(x: groundImage.size().width*scaleX, y: 0, duration: 0.0);
        
        var moveBackgoundForever = SKAction.repeatForever(SKAction.sequence([moveBackground, resetBackGround]));
        
//        for var i:CGFloat = 0; i<2 + frame.size.width / (groundImage.size().width*scaleX); ++i {
//            let sprite = SKSpriteNode(texture: groundImage);
//            sprite.xScale = scaleX;
//            sprite.yScale = scaleY;
//            sprite.zPosition = z;
//            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2);
//            sprite.runAction(moveBackgoundForever);
//            universe.addChild(sprite);
//            parallaxArray.append(sprite);
//        }
    }
    func addPlatform(imageName: NSString, numberOfBlocks: UInt32, x: CGFloat, y: CGFloat) -> CGFloat {
        
        var X: CGFloat = x;
        var obstaclePositionX: UInt32 = arc4random_uniform(numberOfBlocks);
        
        for i in 0...numberOfBlocks {
            var grassGround: SKSpriteNode = SKSpriteNode(imageNamed:imageName as String);
            
            grassGround.position = CGPoint(x:X, y:y);
            
            X += grassGround.size.width;
            grassGround.zPosition = 10;
            platformGroup.addChild(grassGround);
            
            grassGround.physicsBody = SKPhysicsBody(rectangleOf: grassGround.size);
            grassGround.physicsBody!.isDynamic = false;
            
            grassGround.physicsBody!.restitution = 0;
            if imageName != "book" {
                grassGround.physicsBody!.categoryBitMask = GROUNDCATEGORY;
            }
            else {
                grassGround.physicsBody!.categoryBitMask = BOOKCATEGORY;
            }
            grassGround.physicsBody!.collisionBitMask = COINCATEGORY | NUMBERCATEGORY | SHIELDCATEGORY | MAGNETCATEGORY | HEROCATEGORY | TACKSCATEGORY;
            
            var obstacle: SKSpriteNode!;
            var moveObstacleForward: SKAction!;
            var moveObstacleBackward: SKAction!;
            
            if imageName != "book" && i == obstaclePositionX && obstaclePositionX != numberOfBlocks && obstaclePositionX != numberOfBlocks - 1 && obstaclePositionX != numberOfBlocks - 2 && obstaclePositionX != numberOfBlocks - 3 && obstaclePositionX != numberOfBlocks - 4 && addObstacles == true {
                if obstaclePositionX%2 == 0 {
                    obstacle = SKSpriteNode(imageNamed: "protactor_obstacle");
                    obstacle.position = CGPoint(x:X, y:grassGround.position.y + grassGround.size.height/4 + obstacle.size.height/2);
                    
                    moveObstacleForward = SKAction.moveBy(x: obstacle.size.width*0.75, y: 0, duration: 0.5);
                    moveObstacleBackward = SKAction.moveBy(x: -obstacle.size.width*0.75, y: 0, duration: 0.5);
                    
                    var offsetX: CGFloat = obstacle.frame.size.width*obstacle.anchorPoint.x;
                    var offsetY: CGFloat = obstacle.frame.size.height*obstacle.anchorPoint.y;
                    var path: CGMutablePath = CGMutablePath();
//                    CGPathMoveToPoint(path, nil, 0 - offsetX, 0 - offsetY);
//                    CGPathAddLineToPoint(path, nil, 38 - offsetX, 0 - offsetY);
//                    CGPathAddLineToPoint(path, nil, 38 - offsetX, 6 - offsetY);
//                    CGPathAddLineToPoint(path, nil, 36 - offsetX, 10 - offsetY);
//                    CGPathAddLineToPoint(path, nil, 30 - offsetX, 15 - offsetY);
//                    CGPathAddLineToPoint(path, nil, 25 - offsetX, 19 - offsetY);
//                    CGPathAddLineToPoint(path, nil, 19 - offsetX, 19 - offsetY);
//                    CGPathAddLineToPoint(path, nil, 11 - offsetX, 18 - offsetY);
//                    CGPathAddLineToPoint(path, nil, 5 - offsetX, 14 - offsetY);
//                    CGPathAddLineToPoint(path, nil, 1 - offsetX, 7 - offsetY);
                    path.closeSubpath();
                    
                    obstacle.physicsBody = SKPhysicsBody(polygonFrom: path);
                }
                else {
                    obstacle = SKSpriteNode(imageNamed: "pencil_obstacle");
                    obstacle.position = CGPoint(x:X, y:grassGround.position.y + grassGround.size.height);
                    
                    moveObstacleForward = SKAction.moveBy(x: 0, y: obstacle.size.height*0.15, duration: 0.25);
                    moveObstacleBackward = SKAction.moveBy(x: 0, y: -obstacle.size.height*0.15, duration: 0.25);
                    
                    var offsetX: CGFloat = obstacle.frame.size.width*obstacle.anchorPoint.x;
                    var offsetY: CGFloat = obstacle.frame.size.height*obstacle.anchorPoint.y;
                    var path: CGMutablePath = CGMutablePath();
//                    CGPathMoveToPoint(path, nil, 0 - offsetX, 0 - offsetY);
//                    CGPathAddLineToPoint(path, nil, 4 - offsetX, 0 - offsetY);
//                    CGPathAddLineToPoint(path, nil, 4 - offsetX, 25 - offsetY);
//                    CGPathAddLineToPoint(path, nil, 2 - offsetX, 30 - offsetY);
//                    CGPathAddLineToPoint(path, nil, 0 - offsetX, 25 - offsetY);
                    path.closeSubpath();
                    
                    obstacle.physicsBody = SKPhysicsBody(polygonFrom: path);
                }
                
//                var moveObstacleForever: SKAction = SKAction.repeatForever(SKAction.sequence([moveObstacleForward, moveObstacleBackward, moveObstacleBackward, moveObstacleForward]));
//                obstacle.run(moveObstacleForever);
//                obstacle.zPosition = 6;
//                world.addChild(obstacle);
//                obstacle.physicsBody!.isDynamic = false;
//                obstacle.physicsBody!.restitution = 0;
//                obstacle.physicsBody!.categoryBitMask = FIRECATEGORY;
//                obstacle.physicsBody!.contactTestBitMask = COINCATEGORY | NUMBERCATEGORY | SHIELDCATEGORY | MAGNETCATEGORY | HEROCATEGORY | LEFTCATEGORY;
//                obstacle.physicsBody!.collisionBitMask = HEROCATEGORY | LEFTCATEGORY;
            }
        }
        
        return X + heroSprite.size.width*4;
    }
    
    func appendSpriteWalking(textureAtlas: SKTextureAtlas, imageName: NSString) {
        spriteArrayWalking.append(textureAtlas.textureNamed(imageName as String));
    }
    
    func appendSpriteFlying(textureAtlas: SKTextureAtlas, imageName: NSString) {
        spriteArrayFlying.append(textureAtlas.textureNamed(imageName as String));
    }
    
    func appendCoins(textureAtlas: SKTextureAtlas, imageName: NSString) {
        coinsArray.append(textureAtlas.textureNamed(imageName as String));
    }
    
    func appendShield(textureAtlas: SKTextureAtlas, imageName: NSString) {
        shieldArray.append(textureAtlas.textureNamed(imageName as String));
    }
    
    func appendMagnet(textureAtlas: SKTextureAtlas, imageName: NSString) {
        magnetArray.append(textureAtlas.textureNamed(imageName as String));
    }
    
    func rotateForever(sprite: SKSpriteNode){
        let angle : CGFloat = CGFloat(M_PI);
        let rotate = SKAction.rotate(byAngle: angle, duration: 0.5);
        let repeatAction = SKAction.repeatForever(rotate);
        sprite.run(repeatAction);
    }
    
    func fireRulers(x: CGFloat) {
        
        let sizeRuler: SKSpriteNode = SKSpriteNode(imageNamed: "ruler_fire");
        
        var firstY: UInt32 = arc4random_uniform(UInt32(height));
        var secondY: UInt32 = arc4random_uniform(UInt32(height));
        var yArray = Array<UInt32>();
        
        while abs(Int32(firstY - secondY)) < minDifferenceBetweenRulers/10 {
            firstY = arc4random_uniform(UInt32(sizeRuler.size.height));
            secondY = arc4random_uniform(UInt32(height - sizeRuler.size.height));
        }
        
        yArray.append(firstY);
        yArray.append(secondY);
        
        for i in 0...1 {
            let ruler: SKSpriteNode = SKSpriteNode(imageNamed: "ruler_fire");
            ruler.xScale = scaleX;
            ruler.yScale = scaleY;
            ruler.position = CGPoint(x:x,y:CGFloat(yArray[i]));
            ruler.zPosition = 11;
            world.addChild(ruler);
            rotateForever(sprite: ruler);
            ruler.physicsBody = SKPhysicsBody(rectangleOf: ruler.size);
            ruler.physicsBody!.isDynamic = false;
            ruler.physicsBody!.allowsRotation = false;
            ruler.physicsBody!.restitution = 0;
            ruler.physicsBody!.categoryBitMask = FIRECATEGORY;
            ruler.physicsBody!.contactTestBitMask = COINCATEGORY | NUMBERCATEGORY | SHIELDCATEGORY | MAGNETCATEGORY | HEROCATEGORY | LEFTCATEGORY;
            ruler.physicsBody!.collisionBitMask = HEROCATEGORY | LEFTCATEGORY;
            ruler.physicsBody?.usesPreciseCollisionDetection = false;
            
            rulerFireArray.append(ruler);
        }
    }
    
    func goToGameScene() {
        
        let transition = SKTransition.reveal(with: SKTransitionDirection.left, duration: 2);
        
        let scene = MathScene(size: size, score: score, coins: coins, bannerHeight: CGFloat(UserDefaults.standard.float(forKey: "bannerHeight")), bannerView: adMobBannerView);
        scene.scaleMode = .aspectFill;
        
        view?.presentScene(scene, transition: transition);
    }
    
    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchLeft = true;
    }
    #else
    override func keyDown(theEvent: NSEvent) {
        if theEvent.keyCode == 49 {
            touchLeft = true;
        }
    }
    #endif
    
    func pauseGame() {
        
        appDelegate.backgroundMusicPlayer.stop();
        
        effectsNode.shouldEnableEffects = true;
        
        universe.removeFromParent();
        effectsNode.addChild(universe);
        addChild(effectsNode);
        
        finalmeters = SKLabelNode(fontNamed:"ChalkboardSE-Bold");
        finalmeters.text = "Game paused!";
        finalmeters.fontSize = 50;
        finalmeters.fontColor = gameOverColor;
        finalmeters.position = CGPoint(x:width/2, y:height/2+finalmeters.fontSize/2);
        finalmeters.zPosition = 13;
        addChild(finalmeters);
        
        buttonHome = GGButton(scaleX: 0.5, scaleY: 0.5, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "Home", textColor: gameOverColor, buttonAction: goToHomeScene);
        buttonHome.position = CGPoint(x: width/2-buttonHome.defaultButton.size.width,
                                      y: height/2-buttonHome.defaultButton.size.height/2);
        addChild(buttonHome);
        
        buttonResume = GGButton(scaleX: 0.5, scaleY: 0.5, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "Resume", textColor: gameOverColor, buttonAction: resumeGame);
        buttonResume.position = CGPoint(x: width/2,
                                        y: height/2-buttonResume.defaultButton.size.height/2);
        addChild(buttonResume);
        
        buttonRetry = GGButton(scaleX: 0.5, scaleY: 0.5, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "Retry", textColor: gameOverColor, buttonAction: retry);
        buttonRetry.position = CGPoint(x: width/2+buttonRetry.defaultButton.size.width,
                                       y: height/2-buttonRetry.defaultButton.size.height/2);
        addChild(buttonRetry);
        
        pauseButton.removeFromParent();
        isPaused = true;
    }
    func resumeGame() {
        
        appDelegate.backgroundMusicPlayer.play();
        
        isPaused = false;
        
        finalmeters.removeFromParent();
        buttonHome.removeFromParent();
        buttonResume.removeFromParent();
        buttonRetry.removeFromParent();
        universe.removeFromParent();
        effectsNode.removeFromParent();
        addChild(universe);
        addChild(pauseButton);
    }
    func retry() {
        
        let transition = SKTransition.reveal(with: SKTransitionDirection.left, duration: 2);
        
        let scene = GameScene(size: size, bannerHeight: CGFloat(UserDefaults.standard.float(forKey: "bannerHeight")), bannerView: adMobBannerView);
        scene.scaleMode = .aspectFill;
        
        view?.presentScene(scene, transition: transition);
    }
    func goToHomeScene() {
        
        let transition = SKTransition.reveal(with: SKTransitionDirection.right, duration: 2);
        
        let scene = Home(size: size, bannerHeight: CGFloat(UserDefaults.standard.float(forKey: "bannerHeight")), bannerView: adMobBannerView);
        scene.scaleMode = .aspectFill;
        
        view?.presentScene(scene, transition: transition);
    }
    
    func playSound(soundName: NSString) {
        if !soundOff {
            run(SKAction.playSoundFileNamed(soundName as String+".wav", waitForCompletion: false));
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody!;
        var secondBody: SKPhysicsBody!;
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA;
            secondBody = contact.bodyB;
        }
        else {
            secondBody = contact.bodyB;
            firstBody = contact.bodyA;
        }
        
        if firstBody.categoryBitMask == HEROCATEGORY {
            if secondBody.categoryBitMask == FIRECATEGORY || secondBody.categoryBitMask == TACKSCATEGORY {
                if !shield && !magnet {
                    playSound(soundName: "Died");
                    
                    gameOver = true;
                }
                else if shield {
                    playSound(soundName: "Pop");
                    
                    heroSprite.physicsBody!.velocity.dy = 0;
                    heroSprite.physicsBody!.applyImpulse(CGVector(dx: 0, dy: jumpHeight/3));
                    
                    shield = false;
                    shieldSprite.removeFromParent();
                }
                else if magnet {
                    playSound(soundName: "Pop");
                    
                    heroSprite.physicsBody!.velocity.dy = 0;
                    heroSprite.physicsBody!.applyImpulse(CGVector(dx: 0, dy: jumpHeight/3));
                    
                    magnet = false;
                    magnetSprite.removeFromParent();
                    
                    var animateAction: SKAction = SKAction.animate(with: coinsArray, timePerFrame: 0.1);
                    var group: SKAction = SKAction.group([ animateAction ]);
                    coinAction = SKAction.repeatForever(group);
                    
                    for singleCoin in coinSpriteArray {
                        singleCoin.physicsBody?.usesPreciseCollisionDetection = false;
                        singleCoin.removeAllActions();
                        singleCoin.run(coinAction);
                    }
                }
                if secondBody.categoryBitMask == FIRECATEGORY {
                    secondBody.node?.removeFromParent();
                }
            }
                
            else if secondBody.categoryBitMask == GROUNDCATEGORY {
                heroSprite.removeAllActions();
                heroSprite.run(repeatActionWalking);
            }
                
            else if secondBody.categoryBitMask == BOOKCATEGORY {
                heroSprite.removeAllActions();
                heroSprite.run(repeatActionWalking);
                secondBody.isDynamic = true;
            }
                
            else if secondBody.categoryBitMask == COINCATEGORY {
                coins += 1;
                secondBody.node?.removeFromParent();
                
                playSound(soundName: "Coin");
            }
                
            else if secondBody.categoryBitMask == NUMBERCATEGORY {
                
                let description = secondBody.node?.description;
                whichNumber = description!.components(separatedBy: "'")[3] as NSString;
                
                secondBody.node?.removeFromParent();
            }
                
            else if secondBody.categoryBitMask == SHIELDCATEGORY {
                
                playSound(soundName: "Shield");
                
                if magnetSprite != nil {
                    magnetSprite.removeFromParent();
                }
                magnet = false;
                
                if shieldSprite != nil {
                    shieldSprite.removeFromParent();
                }
                shield = true;
                shieldSprite = SKSpriteNode(texture: shieldArray[0]);
                var animateAction = SKAction.animate(with: shieldArray, timePerFrame: 0.1);
                var group = SKAction.group([ animateAction ]);
                shieldAction = SKAction.repeatForever(group);
                shieldSprite.run(shieldAction);
                
                shieldSprite.position = heroSprite.position;
                
                shieldSprite.zPosition = 12;
                universe.addChild(shieldSprite);
                
                secondBody.node?.removeFromParent();
            }
                
            else if secondBody.categoryBitMask == MAGNETCATEGORY {
                
                playSound(soundName: "Magnet");
                
                if shieldSprite != nil {
                    shieldSprite.removeFromParent();
                }
                shield = false;
                
                if magnetSprite != nil {
                    magnetSprite.removeFromParent();
                }
                magnet = true;
                magnetSprite = SKSpriteNode(texture: magnetArray[0]);
                var animateAction = SKAction.animate(with: magnetArray, timePerFrame: 0.1);
                var group = SKAction.group([ animateAction ]);
                magnetAction = SKAction.repeatForever(group);
                magnetSprite.run(magnetAction);
                
                magnetSprite.position = heroSprite.position;
                
                magnetSprite.zPosition = 9;
                universe.addChild(magnetSprite);
                
                secondBody.node?.removeFromParent();
            }
        }
        else if firstBody.categoryBitMask == LEFTCATEGORY {
            secondBody.node?.removeFromParent();
        }
        else if secondBody.categoryBitMask == LEFTCATEGORY {
            firstBody.node?.removeFromParent();
        }
        else if firstBody.categoryBitMask == FIRECATEGORY || secondBody.categoryBitMask == FIRECATEGORY {
        }
        else {
            secondBody.node?.removeFromParent();
        }
    }
    
    func addCoins() {
        
        for i in 0...minPlatformLength/2 {
            coinSprite = SKSpriteNode(texture:coinsArray[0]);
            coinSprite.position = CGPoint(x:positionX + CGFloat(i)*3*coinSprite.size.width + CGFloat(arc4random_uniform(UInt32(width/8))),y:coinSprite.size.height + CGFloat(arc4random_uniform(UInt32(height-2*coinSprite.size.height))));
            
            coinSprite.position = CGPoint(x:positionX + 3*coinSprite.size.width + CGFloat(arc4random_uniform(UInt32(width/8))),y:coinSprite.size.height + CGFloat(arc4random_uniform(UInt32(height-2*coinSprite.size.height))));
            
            let animateAction: SKAction = SKAction.animate(with: coinsArray, timePerFrame: 0.1);
            var group: SKAction = SKAction.group([ animateAction ]);
            coinAction = SKAction.repeatForever(group);
            coinSprite.run(coinAction);
            coinSprite.zPosition = 12;
            world.addChild(coinSprite);
            
            coinSprite.physicsBody = SKPhysicsBody(rectangleOf: coinSprite.size);
            coinSprite.physicsBody!.isDynamic = true;
            coinSprite.physicsBody!.mass = -100;
            coinSprite.physicsBody!.affectedByGravity = false;
            coinSprite.physicsBody!.allowsRotation = false;
            coinSprite.physicsBody!.restitution = 0;
            coinSprite.physicsBody!.categoryBitMask = COINCATEGORY;
            coinSprite.physicsBody!.contactTestBitMask = FIRECATEGORY;
            coinSprite.physicsBody!.collisionBitMask = GROUNDCATEGORY | BOOKCATEGORY | NUMBERCATEGORY | SHIELDCATEGORY | MAGNETCATEGORY | HEROCATEGORY;
            
            coinSpriteArray.append(coinSprite);
        }
    }
    
    func addPositiveNumber() {
        
        let numberSprite: SKSpriteNode = SKSpriteNode(imageNamed: positiveNumbers[Int(arc4random_uniform(UInt32(positiveNumbers.count)))] as String);
        
        numberSprite.position = CGPoint(x:positionX + CGFloat(arc4random_uniform(UInt32(width/8))),y:numberSprite.size.height + CGFloat(arc4random_uniform(UInt32(height-2*numberSprite.size.height))));
        
        numberSprite.zPosition = 12;
        world.addChild(numberSprite);
        
        numberSprite.physicsBody = SKPhysicsBody(rectangleOf: numberSprite.size);
        numberSprite.physicsBody!.isDynamic = true;
        numberSprite.physicsBody!.mass = -100;
        numberSprite.physicsBody!.affectedByGravity = false;
        numberSprite.physicsBody!.allowsRotation = false;
        numberSprite.physicsBody!.restitution = 0;
        numberSprite.physicsBody!.categoryBitMask = NUMBERCATEGORY;
        numberSprite.physicsBody!.collisionBitMask = GROUNDCATEGORY | BOOKCATEGORY | COINCATEGORY | SHIELDCATEGORY | MAGNETCATEGORY | HEROCATEGORY;
        numberSprite.physicsBody!.contactTestBitMask = FIRECATEGORY;
    }
    
    func addNegativeNumber() {
        
        let numberSprite: SKSpriteNode = SKSpriteNode(imageNamed: negativeNumbers[Int(arc4random_uniform(UInt32(negativeNumbers.count)))] as String);
        
        numberSprite.position = CGPoint(x:positionX + CGFloat(arc4random_uniform(UInt32(width/8))),y:numberSprite.size.height + CGFloat(arc4random_uniform(UInt32(height-2*numberSprite.size.height))));
        
        numberSprite.zPosition = 12;
        world.addChild(numberSprite);
        
        numberSprite.physicsBody = SKPhysicsBody(rectangleOf: numberSprite.size);
        numberSprite.physicsBody!.isDynamic = true;
        numberSprite.physicsBody!.mass = -100;
        numberSprite.physicsBody!.affectedByGravity = false;
        numberSprite.physicsBody!.allowsRotation = false;
        numberSprite.physicsBody!.restitution = 0;
        numberSprite.physicsBody!.categoryBitMask = NUMBERCATEGORY;
        numberSprite.physicsBody!.collisionBitMask = GROUNDCATEGORY | BOOKCATEGORY | COINCATEGORY | SHIELDCATEGORY | MAGNETCATEGORY | HEROCATEGORY;
        numberSprite.physicsBody!.contactTestBitMask = FIRECATEGORY;
    }
    
    func addShield() {
        
        let shieldSprite = SKSpriteNode(texture: shieldArray[0]);
        let animateAction = SKAction.animate(with: shieldArray, timePerFrame: 0.1);
        let group = SKAction.group([ animateAction ]);
        shieldAction = SKAction.repeatForever(group);
        shieldSprite.run(shieldAction);
        
        shieldSprite.position = CGPoint(x:positionX + CGFloat(arc4random_uniform(UInt32(width/8))),y:shieldSprite.size.height + CGFloat(arc4random_uniform(UInt32(height-2*shieldSprite.size.height))));
        
        shieldSprite.zPosition = 12;
        world.addChild(shieldSprite);
        
        shieldSprite.physicsBody = SKPhysicsBody(rectangleOf: shieldSprite.size);
        shieldSprite.physicsBody!.isDynamic = true;
        shieldSprite.physicsBody!.mass = -100;
        shieldSprite.physicsBody!.affectedByGravity = false;
        shieldSprite.physicsBody!.allowsRotation = false;
        shieldSprite.physicsBody!.restitution = 0;
        
        shieldSprite.physicsBody!.categoryBitMask = SHIELDCATEGORY;
        shieldSprite.physicsBody!.collisionBitMask = GROUNDCATEGORY | BOOKCATEGORY | COINCATEGORY | NUMBERCATEGORY | MAGNETCATEGORY | HEROCATEGORY;
        shieldSprite.physicsBody!.contactTestBitMask = FIRECATEGORY;
    }
    
    func addMagnet() {
        
        let shieldSprite = SKSpriteNode(texture: magnetArray[0]);
        let animateAction = SKAction.animate(with: magnetArray, timePerFrame: 0.1);
        let group = SKAction.group([ animateAction ]);
        shieldAction = SKAction.repeatForever(group);
        shieldSprite.run(shieldAction);
        
        shieldSprite.position = CGPoint(x:positionX + CGFloat(arc4random_uniform(UInt32(width/8))),y:shieldSprite.size.height + CGFloat(arc4random_uniform(UInt32(height-2*shieldSprite.size.height))));
        
        shieldSprite.zPosition = 9;
        world.addChild(shieldSprite);
        
        shieldSprite.physicsBody = SKPhysicsBody(rectangleOf: shieldSprite.size);
        shieldSprite.physicsBody!.isDynamic = true;
        shieldSprite.physicsBody!.mass = -100;
        shieldSprite.physicsBody!.affectedByGravity = false;
        shieldSprite.physicsBody!.allowsRotation = false;
        shieldSprite.physicsBody!.restitution = 0;
        
        shieldSprite.physicsBody!.categoryBitMask = MAGNETCATEGORY;
        shieldSprite.physicsBody!.contactTestBitMask = FIRECATEGORY;
        shieldSprite.physicsBody!.collisionBitMask = GROUNDCATEGORY | BOOKCATEGORY | COINCATEGORY | NUMBERCATEGORY | SHIELDCATEGORY | HEROCATEGORY;
    }
    
    func rememberYourScore() {
        showScore = false;
        if !UserDefaults.standard.bool(forKey: "notFirstTimeRememberScore") {
            fadeOutText(textString: "Remember your score!");
            UserDefaults.standard.set(true, forKey: "notFirstTimeRememberScore");
            UserDefaults.standard.synchronize();
        }
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        
        if !isPaused {
            if !gameOver {
                
                if touchLeft {
                    touchLeft = false;
                    heroSprite.removeAllActions();
                    heroSprite.run(repeatActionFlying);
                    heroSprite.physicsBody!.velocity.dy = 0;
                    heroSprite.physicsBody!.applyImpulse(CGVector(dx: 0, dy: jumpHeight));
                }
                
                if shield {
                    shieldSprite.position = heroSprite.position;
                }
                else if magnet {
                    magnetSprite.position = heroSprite.position;
                    
                    var moveTowardsPlayer = SKAction.moveTo(y: heroSprite.position.y, duration: 0.1);
                    
                    for singleCoin in coinSpriteArray {
                        singleCoin.physicsBody?.usesPreciseCollisionDetection = true;
                        singleCoin.run(moveTowardsPlayer);
                    }
                    
                    moveTowardsPlayer = SKAction.moveTo(x: heroSprite.position.x, duration: 10);
                    for singleCoin in coinSpriteArray {
                        singleCoin.physicsBody?.usesPreciseCollisionDetection = true;
                        singleCoin.run(moveTowardsPlayer);
                    }
                }
                
                heroSprite.position.x = startingX;
                left.position = CGPoint(x: -heroSprite.size.width*2, y: height/2);
                world.position.x -= playerVelocity;
                for ruler in rulerFireArray {
                    ruler.position.x -= 1.2*playerVelocity;
                }
                distanceMoved += playerVelocity;
                
                if whichNumber == "plus1" {
                    playSound(soundName: "PositiveNumber");
                    score += 1;
                    rememberYourScore();
                }
                else if whichNumber == "plus10" {
                    playSound(soundName: "PositiveNumber");
                    score += 10;
                    rememberYourScore();
                }
                else if whichNumber == "plus100" {
                    playSound(soundName: "PositiveNumber");
                    score += 100;
                    rememberYourScore();
                }
                else if whichNumber == "minus1" {
                    playSound(soundName: "NegativeNumber");
                    if score > 0 {
                        score -= 1;
                    }
                    rememberYourScore();
                }
                else if whichNumber == "minus10" {
                    playSound(soundName: "NegativeNumber");
                    if score > 9 {
                        score -= 10;
                    }
                    rememberYourScore();
                }
                else if whichNumber == "minus100" {
                    playSound(soundName: "NegativeNumber");
                    if score > 99 {
                        score -= 100;
                    }
                    rememberYourScore();
                }
                else if whichNumber == "multiply10" {
                    playSound(soundName: "PositiveNumber");
                    score *= 10;
                    rememberYourScore();
                }
                else if whichNumber == "multiply100" {
                    playSound(soundName: "PositiveNumber");
                    score *= 100;
                    rememberYourScore();
                }
                else if whichNumber == "divide10" {
                    playSound(soundName: "NegativeNumber");
                    score /= 10;
                    rememberYourScore();
                }
                else if whichNumber == "divide100" {
                    playSound(soundName: "NegativeNumber");
                    score /= 100;
                    rememberYourScore();
                }
                else if whichNumber == "showScore" {
                    showScore = true;
                    fadeOutText(textString: "Score: "+String(score) as NSString);
                }
                whichNumber = "";
                
                if showScore == true {
                    progressLabel.text = "Score: " + String(score) + "     Coins: " + String(coins) + "     Distance: " + String(meters) + " feet";
                }
                else {
                    progressLabel.text = "Coins: " + String(coins) + "     Distance: " + String(meters) + " feet";
                }
                if distanceMoved > width/2 && platformGroup.children.count <= Int(maxPlatformLength*3)*Int(ceil(scaleX)) {
                    playerVelocity += 0.01;
                    distanceMoved = 0;
                    meters += 1;
                    timeSinceRuler += 1;
                    timeSinceShield += 1;
                    
                    addObstacles = true;
                    
                    addCoins();
                    for i in 0..<UInt8(ceil(scaleX)) {
                        positionX = addPlatform(imageName: ground[Int(arc4random_uniform(UInt32(ground.count)))], numberOfBlocks: minPlatformLength + arc4random_uniform(maxPlatformLength), x: positionX, y: startingY + CGFloat(arc4random_uniform(maxRandom)));
                    }
                    
                    if !UserDefaults.standard.bool(forKey: "notFirstTimeGoldenNumbers") {
                        fadeOutText(textString: "Collect golden numbers");
                        UserDefaults.standard.set(true, forKey: "notFirstTimeGoldenNumbers");
                        UserDefaults.standard.synchronize();
                    }
                    
                    if score >= 100 {
                        let randomBoolean = arc4random() % 2;
                        if randomBoolean == 0 {
                            addNegativeNumber();
                        }
                        else if randomBoolean == 1 {
                            addPositiveNumber();
                        }
                    }
                    else {
                        addPositiveNumber();
                    }
                    
                    if timeSinceShield >= 5 {
                        timeSinceShield = 0;
                        minDifferenceBetweenRulers -= 1;
                        let randomBoolean = arc4random() % 2;
                        if shield == false {
                            if randomBoolean == 0 {
                                addShield();
                            }
                        }
                        if magnet == false {
                            if randomBoolean == 1 {
                                addMagnet();
                            }
                        }
                    }
                    if timeSinceRuler >= 3 {
                        timeSinceRuler = 0;
                        fireRulers(x: positionX+width);
                    }
                }
            }
            else {
                if !executed {
                    
                    appDelegate.backgroundMusicPlayer.stop();
                    
                    world.removeAllChildren();
                    pauseButton.removeFromParent();
                    
                    effectsNode.shouldEnableEffects = true;
                    
                    universe.removeFromParent();
                    effectsNode.addChild(universe);
                    addChild(effectsNode);
                    
                    let finalmeters = SKLabelNode(fontNamed:"ChalkboardSE-Bold");
                    finalmeters.text = "You ran " + String(meters) + " feet!";
                    finalmeters.fontSize = 50;
                    finalmeters.fontColor = gameOverColor;
                    finalmeters.position = CGPoint(x:width/2, y:height/2+finalmeters.fontSize/2);
                    finalmeters.zPosition = 13;
                    addChild(finalmeters);
                    
                    var button: GGButton = GGButton(scaleX: 1, scaleY: 1, defaultButtonImage: "button_default", activeButtonImage: "button_pressed", text: "Math", textColor: gameOverColor, buttonAction: goToGameScene);
                    button.position = CGPoint(x: width/2,
                                              y: height/2-button.defaultButton.size.height/2);
                    addChild(button);
                    
                    executed = true;
                    for parallaxElement in parallaxArray {
                        parallaxElement.removeAllActions();
                    }
//                    paused = true;
                }
            }
        }
    }
}
