//
//  Level5.swift
//  Worlds Hardest Game
//
//  Created by Rishi Wadhwa on 6/6/21.
//

import SpriteKit
import GameplayKit

class Level5: SKScene, SKPhysicsContactDelegate {
    
    //reward at the end
    var rewardIsNotTouched = true
    
    //update requirement
    var previousTime: TimeInterval = 0
    
    //player
    var player: SKNode?
    let playerSpeed = 4
    var playerIsRight = true
    
    //fake keys
    var lvl3: SKNode?
    var lvl1: SKNode?
    
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
        
        helper.playDungeon()
        
        player = childNode(withName: "player")
        
        joystick = childNode(withName: "joystick")
        knob = joystick!.childNode(withName: "knob")
        
        startPoint = player!.position
        
        heartContainer.position = CGPoint(x: (-400), y: 200)
        heartContainer.zPosition = 100000
        
        lvl1 = childNode(withName: "key1")
        lvl3 = childNode(withName: "key3")
        
        self.addChild(heartContainer)
        fillHeartContainer(7)
        
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

//MARK: Update For Walking
extension Level5 {
    override func update(_ currentTime: TimeInterval) {
        rewardIsNotTouched = true
        
        let delta = currentTime - previousTime
        previousTime = currentTime
        
        guard let joystickKnob = knob else {return}
        
        let xPosition = Double(joystickKnob.position.x)
        let positivePosition = xPosition > 0 ? -xPosition: xPosition
        
        if floor(positivePosition) != 0 {
            playerStateMachine.enter(walkingState.self )
        } else {
            playerStateMachine.enter(idleState.self)
        }
        let displacement = CGVector(dx: (delta * xPosition * Double(playerSpeed)), dy: 0)
        
        let move = SKAction.move(by: displacement, duration: 0)
        let faceAction: SKAction!
        let movingRight = xPosition > 0
        let movingLeft = xPosition < 0
        
        if movingLeft && playerIsRight {
            playerIsRight = false
            
            let faceMovement = SKAction.scaleX(to: -0.05, duration: 0)
            faceAction = SKAction.sequence([move, faceMovement])
        } else {
            if movingRight && !playerIsRight{
                playerIsRight = true
                
                let faceMovement = SKAction.scaleX(to: 0.05, duration: 0)
                faceAction = SKAction.sequence([move, faceMovement])
            } else {
                faceAction = move
            }
        }
        
        player?.run(faceAction)
        
        if let pos = player?.position {
            let rect1 = CGRect(x: lvl1!.position.x, y: lvl1!.position.y, width: lvl1!.frame.width, height: lvl1!.frame.height)
            let rect2 = CGRect(x: lvl3!.position.x, y: lvl3!.position.y, width: lvl3!.frame.width, height: lvl3!.frame.height)
            
            if (rect1.contains(pos)) {
                let level1 = SKScene(fileNamed: "Level1")
                level1?.scaleMode = .aspectFill
                
                let trans = SKTransition.moveIn(with: .left, duration: 0.5)
                self.view?.presentScene(level1!, transition: trans)
            } else if (rect2.contains(pos)) {
                let level3 = SKScene(fileNamed: "Level3")
                level3?.scaleMode = .aspectFill
                
                let trans = SKTransition.moveIn(with: .left, duration: 0.5)
                self.view?.presentScene(level3!, transition: trans)
            }
        }
    }
}

//MARK: Trapped Locations
extension Level5 {
    //nothing - weird level
}
//MARK: Lives - Lose + Gain
extension Level5 {
    func fillHeartContainer(_ count: Int) {
        for index in 1...count {
            let heart = SKSpriteNode(imageNamed: "heart")
            let xPos = heart.size.width*CGFloat(index-1)
            heart.position = CGPoint(x: xPos, y: 0)
            heart.setScale(1.5)
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
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
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
        
        
        playerStateMachine.enter(landingState.self)
        playerStateMachine.enter(idleState.self)
        
        helper.playDungeon()
    }
    
    func showGameOver() {
        let gameOver = GameOver(fileNamed: "GameOver")
        gameOver?.scaleMode = .aspectFill
        self.view?.presentScene(gameOver)
    }
}

//MARK: Touches
extension Level5 {
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
extension Level5 {
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
extension Level5 {
    struct Collision {
        enum Masks: Int {
            case trap, player, endKey, ground
            
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
            helper.playLoseLife()
            
            let die = SKAction.move(to: CGPoint(x: -404, y: 29), duration: 0)
            player?.run(die)
            
            isHit = true
            loseLife()
            
            playerStateMachine.enter(idleState.self)
        } else if (collision.matches(.ground, .player)) {
            playerStateMachine.enter(landingState.self)
        } else if (collision.matches(.player, .endKey)) {
            nextLevel()
        }
    }
}


//MARK: Next Level
extension Level5 {
    func nextLevel() {
        helper.playNextLevel()
        
        let level2 = Level6(fileNamed: "Level6")
        level2?.scaleMode = .aspectFill
        
        let transition = SKTransition.moveIn(with: .right, duration: 0.5)
        
        self.view?.presentScene(level2!, transition: transition)
    }
}
