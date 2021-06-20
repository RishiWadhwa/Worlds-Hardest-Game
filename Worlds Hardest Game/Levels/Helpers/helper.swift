//
//  helper.swift
//  Worlds Hardest Game
//
//  Created by Rishi Wadhwa on 6/19/21.
//

import Foundation
import AVFoundation

class helper {
    static func stopMusic() {
        AudioPlayer.stop()
    }
    
    static func playDungeon() {
        stopMusic()
        AudioPlayer = try! AVAudioPlayer(contentsOf: dungeonUrl as URL)
        AudioPlayer.prepareToPlay()
        AudioPlayer.numberOfLoops = -1
        AudioPlayer.play()
    }
    
    static func playLoseLife() {
        stopMusic()
        AudioPlayer = try! AVAudioPlayer(contentsOf: deathUrl as URL)
        AudioPlayer.prepareToPlay()
        AudioPlayer.numberOfLoops = 0
        AudioPlayer.play()
    }
    
    static func playNextLevel() {
        stopMusic()
        AudioPlayer = try! AVAudioPlayer(contentsOf: levelUrl as URL)
        AudioPlayer.prepareToPlay()
        AudioPlayer.numberOfLoops = 0
        AudioPlayer.play()
    }
}
