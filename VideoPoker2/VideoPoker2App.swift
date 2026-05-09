//
//  VideoPoker2App.swift
//  VideoPoker2
//
//  Created by Stephane Bertin on 02/04/2026.
//

import SwiftUI

@main
struct VideoPoker2App: App {
    init() {
            // Force le chargement du SoundManager au démarrage
            _ = SoundManager.shared
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentMinSize)
    }
}
