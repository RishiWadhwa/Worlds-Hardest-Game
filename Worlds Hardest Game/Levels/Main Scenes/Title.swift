//
//  Title.swift
//  Worlds Hardest Game
//
//  Created by Rishi Wadhwa on 6/16/21.
//

import Foundation
import SpriteKit
import AVFoundation

var AudioPlayer = AVAudioPlayer()
let levelUrl = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Next Level", ofType: "mp3")!)
let deathUrl = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Life Lost", ofType: "mp3")!)
let dungeonUrl = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Dungeon Vibe", ofType: "mp3")!)

class Title: SKScene {
    var playButton: SKNode?
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        playButton = childNode(withName: "playButton")
        playButton?.zPosition = 1000
        
        helper.playDungeon()
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
