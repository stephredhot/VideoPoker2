//
//  CardView.swift
//  VideoPoker2
//
//  Created by Stephane Bertin on 05/04/2026.
//

import SwiftUI

struct CardView: View {
    let card: Card?
    let isHeld: Bool
    let isFaceUp: Bool

    var body: some View {
        ZStack {
            if isFaceUp, let card = card {
                // FACE DE LA CARTE
                Image(card.imageName)
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fit)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 8)
            } else {
                // DOS DE LA CARTE
                Image("back")
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 8)
            }
        }
        .rotation3DEffect(
            .degrees(isFaceUp ? 180 : 0),
            axis: (x: 0.0, y: 1.0, z: 0.0),
            perspective: 0.5
        )
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isFaceUp)
        
        // Utilisation de l'overlay personnalisé défini plus bas
        .overlay(alignment: .top) {
            if isHeld {
                HeldOverlay()
            }
        }
    }
}

// MARK: - Composant Interne
// On le place ici car il est spécifique à la CardView
struct HeldOverlay: View {
    @State private var pulse = 1.0
    @State private var glowOpacity = 0.7
    
    var body: some View {
        ZStack {
            // Cadre doré lumineux
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gold, lineWidth: 8)
                .shadow(color: .gold, radius: 12)
            
            // Étiquette "HELD"
            Text("HELD")
                .font(.caption.bold())
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(.yellow)
                .foregroundColor(.black)
                .cornerRadius(4)
                .offset(y: -10)
        }
        .scaleEffect(pulse)
        .opacity(glowOpacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                pulse = 1.03
            }
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true).delay(0.3)) {
                glowOpacity = 1.0
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CardView(card: Card(rank: .ace, suit: .spades), isHeld: true, isFaceUp: true)
            .frame(width: 150)
    }
}
