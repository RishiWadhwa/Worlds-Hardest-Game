//
//  GameOver.swift
//  Worlds Hardest Game
//
//  Created by Rishi Wadhwa on 6/16/21.
//

import Foundation
import SpriteKit

class GameOver: SKScene {
    var homeButton: SKNode?
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        homeButton = childNode(withName: "homeButton")
        homeButton?.zPosition = 1000
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let loc = touch.location(in: self)
            
            if (homeButton!.contains(loc)) {
                let title = SKScene(fileNamed: "Title")
                let trans = SKTransition.doorsCloseVertical(withDuration: 0.25)
                
                title?.scaleMode = .aspectFill
                
                self.view?.presentScene(title!, transition: trans)
            }
        }
    }
}
