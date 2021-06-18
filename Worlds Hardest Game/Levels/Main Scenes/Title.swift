//
//  Title.swift
//  Worlds Hardest Game
//
//  Created by Rishi Wadhwa on 6/16/21.
//

import Foundation
import SpriteKit

class Title: SKScene {
    var playButton: SKNode?
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        playButton = childNode(withName: "playButton")
        playButton?.zPosition = 1000
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let loc = touch.location(in: self)
            
            if playButton!.contains(loc) {
                let gameover = SKScene(fileNamed: "Level1")
                let trans = SKTransition.doorsOpenVertical(withDuration: 0.25)
                
                gameover?.scaleMode = .aspectFill
                self.view?.presentScene(gameover!, transition: trans)
            }
        }
    }
}
