//
//  BackgroundView.swift
//  VideoPoker2
//
//  Created by Stephane Bertin on 05/04/2026.
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
        ZStack {
            // L'image principale
            Image("fond")
                .resizable()
                .aspectRatio(contentMode: .fill)
                // On s'assure qu'elle prend tout l'espace disponible
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .ignoresSafeArea()
                .blur(radius: 1.5)
                .opacity(0.85)
                .clipped() // Très important pour le plein écran sur Mac
            
            // L'overlay sombre pour faire ressortir les cartes et le texte
            Color.black.opacity(0.35)
                .ignoresSafeArea()
            
            // Optionnel : Vous pouvez ajouter ici un dégradé subtil
            // pour simuler l'éclairage d'une table de casino
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.5)],
                startPoint: .center,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

#Preview {
    BackgroundView()
}
