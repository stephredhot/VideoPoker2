//
//  BetSelectorView.swift
//  VideoPoker2
//
//  Created by Stephane Bertin on 05/04/2026.
//

import SwiftUI

struct BetSelectorView: View {
    let bet: Int
    let increase: () -> Void
    let decrease: () -> Void
    let maxBet: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            ActionButton(systemName: "minus", action: {
                decrease()
            })
            
            VStack(spacing: 2) {
                Text("BET")
                    .font(.title.bold())
                    .foregroundColor(.gold.opacity(0.8))
                
                Text("\(bet)")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 80)
            }
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.2))
            )
            
            ActionButton(systemName: "plus", action: {
                increase()
            })
            
            Button(action: {
                maxBet()
            }) {
                Text("MAX")
                    .font(.caption.bold())
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(CasinoButtonStyle(color: .gold.opacity(0.8), size: .small))
        }
        .padding(10)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.4))
                .overlay(Capsule().stroke(Color.gray.opacity(0.2), lineWidth: 1))
        )
    }
}

// MARK: - Sous-composant pour les boutons +/-
private struct ActionButton: View {
    let systemName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .bold))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(CasinoButtonStyle(color: .gray.opacity(0.5), size: .small))
    }
}

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()
        BetSelectorView(bet: 3, increase: {}, decrease: {}, maxBet: {})
    }
}
