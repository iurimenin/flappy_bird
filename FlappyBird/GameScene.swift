//
//  GameScene.swift
//  FlappyBird
//
//  Created by Iuri Menin on 16/08/16.
//  Copyright (c) 2016 Iuri Menin. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode()
    var background = SKSpriteNode()
    var pipe1 = SKSpriteNode()
    var pipe2 = SKSpriteNode()
    var gameOver = false
    var score = 0
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    var movingObjects = SKSpriteNode()
    var labelContainer = SKSpriteNode()
    
    enum ColliderType: UInt32 {
        
        case Bird = 1
        case Object = 2
        case Gap = 4
    }
    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        self.addChild(movingObjects)
        self.addChild(labelContainer)
        
        let ground = SKNode()
        ground.position = CGPointMake(0, 0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1))
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        
        makeBackground()
        
        let birdTexture1 = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        let animation = SKAction.animateWithTextures([birdTexture1, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatActionForever(animation)
        
        bird = SKSpriteNode(texture: birdTexture1)
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        bird.runAction(makeBirdFlap)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture1.size().height/2)
        bird.physicsBody?.dynamic = true;
        bird.physicsBody?.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        bird.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        bird.physicsBody?.allowsRotation = false
        
        _ = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(GameScene.makePipes), userInfo: nil, repeats: true)
        
        scoreLabel.fontName = "Helvetia"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: self.frame.size.height - 70)
        
        self.addChild(bird)
        self.addChild(ground)
        self.addChild(scoreLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    
        if gameOver == false {
            bird.physicsBody?.velocity = CGVectorMake(0, 0)
            bird.physicsBody?.applyImpulse(CGVectorMake(0, 50))
        } else {
            
            score = 0
            scoreLabel.text = "0"
            bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
            bird.physicsBody?.velocity = CGVectorMake(0, 0)
            movingObjects.removeAllChildren()
            makeBackground()
            gameOver = false
            self.speed = 1
            labelContainer.removeAllChildren()
        }
    }
   
    func didBeginContact(contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue ||  contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
            score += 1
            scoreLabel.text = String(score)
        } else {
         
            if gameOver == false {
                gameOver = true
                self.speed = 0
                gameOverLabel.fontName = "Helvetica"
                gameOverLabel.fontSize = 20
                gameOverLabel.text = "Fim de Jogo! Toque para jogar novamente."
                gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
                labelContainer.addChild(gameOverLabel)
            }
        }
    }
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func makeBackground() {
    
        let bgTexture = SKTexture(imageNamed: "bg.png")
        let moveBg = SKAction.moveByX(-bgTexture.size().width, y: 0, duration: 9)
        let replaceBg = SKAction.moveByX(bgTexture.size().width , y: 0, duration: 0)
        let moveBgForever = SKAction.repeatActionForever(SKAction.sequence([moveBg, replaceBg]))
        
        for i in 0 ..< 3 {
            
            background = SKSpriteNode(texture: bgTexture)
            background.position = CGPoint(x: bgTexture.size().width / 2 + bgTexture.size().width * CGFloat(i), y: CGRectGetMidY(self.frame))
            background.size.height = self.frame.height
            background.zPosition = -5
            background.runAction(moveBgForever)
            self.addChild(background)
        }
    }
    
    func makePipes (){
        
        let gapHeight = bird.size.height * 4
        let movementAmount = arc4random() % UInt32(self.frame.size.height / 2)
        let pipeOffSet = CGFloat(movementAmount) - self.frame.size.height / 4
        let movePipes = SKAction.moveByX(-self.frame.size.width  * 2, y: 0, duration: NSTimeInterval(self.frame.size.width / 100))
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        let pipeTexture1 = SKTexture(imageNamed: "pipe1.png")
        pipe1 = SKSpriteNode(texture: pipeTexture1)
        pipe1.position = CGPointMake(CGRectGetMidX(self.frame) + self.frame.size.width, CGRectGetMidY(self.frame) + pipeTexture1.size().height / 2 + gapHeight / 2 + pipeOffSet)
        pipe1.runAction(moveAndRemovePipes)
        pipe1.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTexture1.size())
        pipe1.physicsBody?.dynamic = false
        pipe1.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        
        let pipeTexture2 = SKTexture(imageNamed: "pipe2.png")
        pipe2 = SKSpriteNode(texture: pipeTexture2)
        pipe2.position = CGPointMake(CGRectGetMidX(self.frame) + self.frame.size.width, CGRectGetMidY(self.frame) - pipeTexture2.size().height / 2 - gapHeight / 2 + pipeOffSet)
        pipe2.runAction(moveAndRemovePipes)
        pipe2.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTexture2.size())
        pipe2.physicsBody?.dynamic = false
        pipe2.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        
        let gap = SKNode()
        gap.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeOffSet)
        gap.runAction(moveAndRemovePipes)
        gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipe1.size.width / 2 , gapHeight))
        gap.physicsBody?.dynamic = false
        gap.physicsBody?.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody?.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody?.collisionBitMask = ColliderType.Gap.rawValue
        
        movingObjects.addChild(pipe1)
        movingObjects.addChild(pipe2)
        movingObjects.addChild(gap)
    }
}
