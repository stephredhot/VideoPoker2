//
//  HoldButton.swift
//  VideoPoker2
//
//  Created by Stephane Bertin on 05/04/2026.
//

import SwiftUI

struct HoldButton: View {
    let isHeld: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            SoundManager.shared.playButton()
            action()
        }){
            Text(isHeld ? "HELD" : "HOLD")
                .font(.system(size: 14, weight: .black))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 140, height: 40)
        .buttonStyle(CasinoButtonStyle(
            color: isHeld ? .gold : .gray.opacity(0.3),
            size: .medium
        ))
        // Petite animation de rebond quand l'état change
        .scaleEffect(isHeld ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHeld)
    }
}

#Preview {
    VStack(spacing: 20) {
        HoldButton(isHeld: true) {}
        HoldButton(isHeld: false) {}
    }
    .padding()
    .background(Color.black)
}
