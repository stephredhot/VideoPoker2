//
//  SoundManager.swift
//  VideoPoker2
//
//  Created by Stephane Bertin on 06/04/2026.
//

import AVFoundation

final class SoundManager {
    
    static let shared = SoundManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    private init() {
        preloadSounds()
    }
    
    private func preloadSounds() {
        let soundNames = [
            "button", "flip", "payout", "win"
        ]
        
        for name in soundNames {
            loadSound(named: name)
        }
    }
    
    private func loadSound(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") ??
                        Bundle.main.url(forResource: name, withExtension: "wav") else {
            print("⚠️ Son non trouvé : \(name)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            audioPlayers[name] = player
            print("✅ Son chargé : \(name)")
        } catch {
            print("❌ Erreur chargement son \(name) : \(error.localizedDescription)")
        }
    }
    
    func play(_ soundName: String, volume: Float = 1.0) {
        guard let player = audioPlayers[soundName] else {
            print("Son non chargé : \(soundName)")
            return
        }
        
        player.volume = volume
        player.currentTime = 0
        player.play()
    }
    
    func playCardFlip() { play("flip", volume: 0.85) }
    func playWin() { play("win", volume: 1.0) }
    func playPayout() { play("payout", volume: 0.9) }
    func playButton() { play("button", volume: 0.7) }
}
