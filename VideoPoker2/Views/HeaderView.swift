//
//  HeaderView.swift
//  VideoPoker2
//
//  Created by Stephane Bertin on 05/04/2026.
//

import SwiftUI

struct HeaderView: View {
    let credits: Int
    
    @State private var goldFlash = false
    @State private var scale: CGFloat = 1.0
    @State private var particleTrigger = 0
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("VIDEO POKER")
                    .font(.largeTitle.bold())
                    .foregroundColor(.gold)
                Text("Jacks or Better 9/6")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("CRÉDITS")
                    .font(.caption)
                    .foregroundColor(.gold)
                
                Text("\(credits)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(goldFlash ? .gold : .white)
                    .scaleEffect(scale)
                    .contentTransition(.numericText())
                    .overlay {
                        CreditParticleEffect(trigger: particleTrigger)
                            .allowsHitTesting(false)
                    }
                    .onChange(of: credits) { oldValue, newValue in
                        if newValue > oldValue {
                            triggerFlash()
                        }
                    }
            }
        }
        .padding(.horizontal, 40)
        .padding(.top, 20)
    }
    
    private func triggerFlash() {
        particleTrigger += 1
        
        withAnimation(.easeIn(duration: 0.1)) {
            goldFlash = true
            scale = 1.2
        }
        
        withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
            goldFlash = false
            scale = 1.0
        }
    }
}

// MARK: - Effet de particules

private struct CreditParticleEffect: View {
    let trigger: Int
    
    var body: some View {
        ZStack {
            ForEach(0..<18, id: \.self) { _ in
                CreditParticle(trigger: trigger)
            }
        }
    }
}

private struct CreditParticle: View {
    let trigger: Int
    
    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var particleScale: CGFloat = 1
    
    private let isStarShape = Bool.random()
    
    var body: some View {
        Group {
            if isStarShape {
                Image(systemName: "sparkle")
                    .font(.system(size: 8, weight: .bold))
            } else {
                Circle()
                    .frame(width: 6, height: 6)
            }
        }
        .foregroundStyle(Color.gold)
        .shadow(color: .gold.opacity(0.8), radius: 6)
        .offset(x: offsetX, y: offsetY)
        .opacity(opacity)
        .scaleEffect(particleScale)
        .onChange(of: trigger) { _, newValue in
            guard newValue > 0 else { return }
            
            offsetX = CGFloat.random(in: -8...8)
            offsetY = CGFloat.random(in: -4...4)
            opacity = 1
            particleScale = CGFloat.random(in: 0.8...1.6)
            
            let targetX = CGFloat.random(in: -130...130)
            let targetY = CGFloat.random(in: -70...50)
            let duration = Double.random(in: 0.5...1.1)
            let delay = Double.random(in: 0...0.2)
            
            withAnimation(.easeOut(duration: duration).delay(delay)) {
                offsetX = targetX
                offsetY = targetY
                opacity = 0
                particleScale = 0.1
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HeaderView(credits: 1000)
    }
}
