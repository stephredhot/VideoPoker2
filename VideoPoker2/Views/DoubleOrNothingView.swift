//
//  DoubleOrNothingView.swift
//  VideoPoker2
//
//  Created by Stephane Bertin on 05/04/2026.
//

import SwiftUI

struct DoubleOrNothingView: View {
    let viewModel: VideoPokerViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            // Titre et Progression
            VStack(spacing: 15) {
                Text("QUITTE OU DOUBLE ?")
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(.gold)
                
                // BARRE DE PROGRESSION (CAPSULES)
                HStack(spacing: 12) {
                    ForEach(1...4, id: \.self) { step in
                        Capsule()
                            .fill(step <= viewModel.doubleCount ? Color.gold : Color.white.opacity(0.2))
                            .frame(width: 50, height: 10)
                            .shadow(color: step <= viewModel.doubleCount ? .gold : .clear, radius: 5)
                    }
                }
            }
            
            // CARTE CENTRALE
            ZStack {
                if let card = viewModel.lastDoubleCard {
                    CardView(
                        card: card,
                        isHeld: false,
                        isFaceUp: viewModel.isFlippingDoubleCard
                    )
                    .id(card.id) // Force l'animation à chaque nouvelle carte
                } else {
                    // Placeholder (Dos de carte) avant de jouer
                    Image("back")
                        .resizable()
                        .aspectRatio(2/3, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 10)
                        .opacity(0.6)
                }
            }
            .frame(height: 220)
            
            // INFOS GAINS ET BOUTONS
            VStack(spacing: 20) {
                Text("Gain à gagner : \(viewModel.doubleWin * 2) pts")
                    .font(.title3.bold())
                    .foregroundColor(.gold)
                    .opacity(viewModel.doubleWin > 0 ? 1 : 0)

                HStack(spacing: 30) {
                    DoubleColorButton(title: "ROUGE", color: .red) {
                        viewModel.doubleOnColor(choiceIsRed: true)
                    }
                    
                    DoubleColorButton(title: "NOIR", color: .gray) {
                        viewModel.doubleOnColor(choiceIsRed: false)
                    }
                }
                .disabled(!viewModel.canDouble)
            }
            
            // BOUTON COLLECTER
            Button(action: {
                viewModel.collectDouble()
            }) {
                Text("ENCAISSER \(viewModel.doubleWin) CRÉDITS")
                    .font(.headline.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.doubleWin > 0 ? Color.green : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.doubleWin == 0)
        }
        .padding(50)
        .background(
            ZStack {
                Color.black.ignoresSafeArea()
                // Halo doré en fond
                RadialGradient(colors: [Color.gold.opacity(0.15), .clear], center: .center, startRadius: 0, endRadius: 500)
            }
        )
    }
}

// Bouton réutilisable pour le Rouge/Noir
struct DoubleColorButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(width: 130, height: 60)
        }
        .buttonStyle(CasinoButtonStyle(color: color, size: .medium))
    }
}
