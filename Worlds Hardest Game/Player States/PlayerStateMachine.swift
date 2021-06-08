//
//  PlayerStateMachine.swift
//  AdventureGame
//
//  Created by Rishi Wadhwa on 3/29/21.
//

 import GameplayKit

fileprivate let characterAnimationKey = String("Sprite Animation")

class playerState: GKState {
    unowned var player: SKNode
    
    init(playerNode: SKNode) {
        player = playerNode
        
        super.init()
    }
}

class jumpingState: playerState {
    var hasFinished: Bool = false
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass is stunnedState.Type {
            return true
        }
        
        if hasFinished && stateClass is landingState.Type {
            return true
        }
        
        return false
    }
    
    var jumpArray = [SKTexture]()
    lazy var action = {SKAction.repeatForever(.animate(with: jumpArray, timePerFrame: 0.1))} ()
    
    override func didEnter(from previousState: GKState?) {
        let set = (0..<2).map({return "jump/\($0)"})
        for img in set {
            jumpArray.append(SKTexture.init(imageNamed: img))
        }
        
        player.removeAction(forKey: characterAnimationKey)
        player.run(action, withKey: characterAnimationKey)
        
        hasFinished = false
        player.run(.applyForce(CGVector(dx: 0, dy: 2000), duration: 0.1))
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
            self.hasFinished = true
        }
    }
}

class landingState: playerState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is landingState.Type, is jumpingState.Type:
            return false
        default:
            return true
        }
    }
    
    override func didEnter(from previousState: GKState?) {
        stateMachine?.enter(idleState.self)
    }
}

class idleState: playerState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is landingState.Type, is idleState.Type:
            return false
        default:
            return true
        }
    }
    
    let textures = SKTexture(imageNamed: "walk/0")
    lazy var action = {SKAction.animate(with: [textures], timePerFrame: 0.1)} ()
    
    override func didEnter(from previousState: GKState?) {
        player.removeAction(forKey: characterAnimationKey)
        player.run(action, withKey: characterAnimationKey)
    }
}

class walkingState: playerState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is landingState.Type, is walkingState.Type:
            return false
        default:
            return true
        }
    }
    
    var walkArray = [SKTexture]()
    lazy var action = {SKAction.repeatForever(.animate(with: walkArray, timePerFrame: 0.1))} ()
    
    override func didEnter(from previousState: GKState?) {
        let set = (0..<6).map({return "walk/\($0)"})
        for img in set {
            walkArray.append(SKTexture.init(imageNamed: img))
        }
        
        player.removeAction(forKey: characterAnimationKey)
        player.run(action, withKey: characterAnimationKey)
    }
}

class stunnedState: playerState {
    var isStunned = false
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if isStunned {
            return false
        }
        
        switch stateClass {
        case is idleState.Type:
            return true
        default:
            return false
        }
    }
    
    let action = SKAction.repeat(SKAction.sequence([
        SKAction.fadeAlpha(to: 0.5, duration: 0.01),
        SKAction.wait(forDuration: 0.25),
        SKAction.fadeAlpha(to: 1, duration: 0.01),
        SKAction.wait(forDuration: 0.25)
    ]), count: 5)
    
    override func didEnter(from previousState: GKState?) {
        isStunned = true
        
        player.run(action)
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) {timer in
            self.isStunned = false
            self.stateMachine?.enter(idleState.self)
        }
    }
}
