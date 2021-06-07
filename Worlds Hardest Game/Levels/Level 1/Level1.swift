//
//  Level1.swift
//  Worlds Hardest Game
//
//  Created by Rishi Wadhwa on 6/6/21.
//

import SpriteKit
import GameplayKit

class Level1: SKScene, SKPhysicsContactDelegate {
    
    //player
    var player: SKNode?
    let playerSpeed = 4
    var playerIsRight = true
    
    //joystick
    var joystickAction = false
    var joystick: SKNode?
    var knob: SKNode?
    var knobRadius: CGFloat = 50
    
    //dead stuff
    var startPoint: CGPoint?
    
    //lives
    var heartArray = [SKSpriteNode]()
    let heartContainer = SKSpriteNode()
    
    //state machine
    var playerStateMachine: GKStateMachine!
    
    //trap contacts
    var isHit = false
    
    override func didMove(to view: SKView) {
        scene?.scaleMode = .aspectFill
        physicsWorld.contactDelegate = self
        
        player = childNode(withName: "player")
        
        joystick = childNode(withName: "joystick")
        knob = joystick!.childNode(withName: "knob")
        
        startPoint = player!.position
        
        heartContainer.position = CGPoint(x: (-200), y: 140)
        heartContainer.zPosition = 100
        fillHeartContainer(5)
        
        playerStateMachine = GKStateMachine(states: [
            jumpingState(playerNode: player!),
            walkingState(playerNode: player!),
            landingState(playerNode: player!),
            idleState(playerNode: player!),
            stunnedState(playerNode: player!)
        ])
        
        playerStateMachine.enter(idleState.self)
    }
}

//MARK: Lives - Lose + Gain
extension Level1 {
    func fillHeartContainer(_ count: Int) {
        for index in 1...count {
            let heart = SKSpriteNode(imageNamed: "heart")
            let xPos = heart.size.width*CGFloat(index-1)
            heart.position = CGPoint(x: xPos, y: 0)
            heartArray.append(heart)
            heartContainer.addChild(heart)
        }
    }
    
    func loseLife() {
        if isHit {
            let lastElementIndex = heartArray.count-1
            if heartArray.indices.contains(lastElementIndex-1) {
                let lastHeart = heartArray[lastElementIndex]
                lastHeart.removeFromParent()
                
                heartArray.remove(at: lastElementIndex)
                
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
                    self.isHit = false
                }
            } else {
                showGameOver()
            }
            self.invincible()
        }
    }
    
    func invincible() {
        playerStateMachine.enter(landingState.self)
        playerStateMachine.enter(idleState.self)
        
        player?.physicsBody?.categoryBitMask = 0
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
            self.player?.physicsBody?.categoryBitMask = 2
        }
        
        player?.run(
            SKAction.repeat(
                SKAction.sequence([
                    .fadeAlpha(to: 0.75, duration: 0.2),
                    .wait(forDuration: 0.1),
                    .fadeAlpha(to: 1, duration: 0.2)
                ]), count: 4)
        )
    }
    
    func showGameOver() {
        let gameOver = Level1(fileNamed: "Level1")
        self.view?.presentScene(gameOver)
    }
}

//MARK: Touches
extension Level1 {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let joystickKnob = knob {
                let location = touch.location(in: joystick!)
                joystickAction = joystickKnob.frame.contains(location)
            }
            
            let location = touch.location(in: self)
            if !(joystick?.contains(location))! {
                playerStateMachine.enter(jumpingState.self)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let joystick = joystick else {return}

        guard let jsKnob = knob else {return}
        
        if !joystickAction {return}
        
        for touch in touches {
            let position = touch.location(in: joystick)
            
            let length = sqrt(pow(position.y, 2) + pow(position.x, 2))
            let angle = atan2(position.y, position.x)
            
            if knobRadius > length {
                jsKnob.position = position
            } else {
                jsKnob.position = CGPoint(x: cos(angle)*knobRadius, y: sin(angle)*knobRadius)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let xJoystickCoord = touch.location(in: joystick!).x
            let xLimit: CGFloat = 200
            
            if xJoystickCoord > -xLimit && xJoystickCoord < xLimit {
                resetKnobPosition()
            }
        }
    }
}

//MARK: Action Methods
extension Level1 {
    func resetKnobPosition() {
        let initialPoint: CGPoint = CGPoint(x: 0, y: 0)
        let moveBack = SKAction.move(to: initialPoint, duration: 0.1)
        moveBack.timingMode = .linear
        knob?.run(moveBack)
        joystickAction = false
    }
    
    func dead() {
        player?.position = startPoint!
    }
}

//MARK: Physics Methods
extension Level1 {
    struct Collision {
        enum Masks: Int {
            case trap, player, ground
            
            var bitmask: UInt32 {return 1 << self.rawValue}
        }
        
        let mask: (first: UInt32, second: UInt32)
        
        func matches(_ first: Masks, _ second: Masks) -> Bool {
            return (first.bitmask == mask.first && second.bitmask == mask.second || first.bitmask == mask.second && second.bitmask == mask.first)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = Collision(mask: (contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask))
        
        if (collision.matches(.trap, .player)) {
            playerStateMachine.enter(landingState.self)
            
            let die = SKAction.move(to: CGPoint(x: -404, y: 29), duration: 0)
            player?.run(die)
            
            isHit = true
            loseLife()
            
            playerStateMachine.enter(idleState.self)
        } else if (collision.matches(.ground, .player)) {
            playerStateMachine.enter(landingState.self)
        }
    }
}
