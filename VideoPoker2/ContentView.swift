import SwiftUI

struct ContentView: View {
    // MARK: - Data
    @State private var viewModel = VideoPokerViewModel()
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // MARK: BackgroundView
            BackgroundView()

            VStack(spacing: 20) {
                // MARK: HeaderView
                HeaderView(credits: viewModel.credits)

                // MARK: PaytableView
                PaytableView(
                    paytable: viewModel.paytable,
                    currentBet: viewModel.bet,
                    winningHand: viewModel.winningHandType
                )
                .padding(.horizontal, 80)
                
                Spacer()
                
                // ZONE DES CARTES ET BOUTONS HOLD ALIGNÉS
                HStack(spacing: 16) {
                    ForEach(0..<5, id: \.self) { index in
                        VStack(spacing: 15) {
                            // 1. La Carte
                            CardView(
                                card: viewModel.hand.count > index ? viewModel.hand[index] : nil,
                                isHeld: viewModel.heldIndices.contains(index),
                                isFaceUp: viewModel.faceUpCards.contains(index)
                            )
                            .onTapGesture {
                                if viewModel.hand.count > index {
                                    viewModel.toggleHold(at: index)
                                }
                            }
                            .frame(minWidth: 140) // Largeur fixe identique pour tout l'alignement
                            
                            // 2. Le Bouton Hold (centré sous la carte)
                            // On utilise l'opacité pour garder l'espace même si caché
                            HoldButton(isHeld: viewModel.heldIndices.contains(index)) {
                                viewModel.toggleHold(at: index)
                            }
                            .opacity(viewModel.gamePhase == .dealt ? 1.0 : 0.0)
                            .disabled(viewModel.gamePhase != .dealt)
                        }
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Contrôles de mise et actions
                VStack(spacing: 16) {
                    // Sélecteur de mise (Fichier séparé)
                    if viewModel.gamePhase == .betting || viewModel.gamePhase == .result {
                        BetSelectorView(
                            bet: viewModel.bet,
                            increase: viewModel.increaseBet,
                            decrease: viewModel.decreaseBet,
                            maxBet: viewModel.maxBet
                        )
                    }
                    
                    HStack(spacing: 24) {
                        if viewModel.gamePhase == .result && viewModel.lastWin > 0 {
                            Button("COLLECTER") {
                                viewModel.collectWin()
                            }
                            .buttonStyle(CasinoButtonStyle(color: .green, size: .large))
                            
                            Button("DOUBLER") {
                                viewModel.startDouble()
                            }
                            .buttonStyle(CasinoButtonStyle(color: .orange, size: .large))
                        } else if viewModel.gamePhase == .betting || viewModel.gamePhase == .result {
                            if viewModel.credits <= 0 {
                                Button("RELANCE") {
                                    viewModel.resetCreditsIfBroke()
                                }
                                .buttonStyle(CasinoButtonStyle(color: .orange, size: .large))
                            } else {
                                Button("DEAL") {
                                    viewModel.deal()
                                }
                                .buttonStyle(CasinoButtonStyle(
                                    color: viewModel.credits >= viewModel.bet ? .green : .gray,
                                    size: .large
                                ))
                                .disabled(viewModel.credits < viewModel.bet)
                            }
                        }
                        
                        if viewModel.gamePhase == .dealt {
                            Button("DRAW") {
                                viewModel.draw()
                            }
                            .buttonStyle(CasinoButtonStyle(color: .red))
                            
                            Button("Auto Hold") {
                                viewModel.autoHold()
                            }
                            .buttonStyle(CasinoButtonStyle(color: .orange, size: .medium))
                        }
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $viewModel.showDoubleScreen) {
            DoubleOrNothingView(viewModel: viewModel)
        }
        .overlay(alignment: .top) {
            if !viewModel.message.isEmpty {
                Text(viewModel.message)
                    .font(.title2.bold())
                    .foregroundColor(viewModel.lastWin > 0 ? .gold : .white)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.top, 40)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: viewModel.message)
        .animation(.easeInOut(duration: 0.5), value: viewModel.hand)
        .overlay {
            if viewModel.showRoyalFlushEffect {
                RoyalFlushEffectView()
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: viewModel.showRoyalFlushEffect)
    }
}

// MARK: - Effet Royal Flush

private struct RoyalFlushEffectView: View {
    @State private var phase = 0
    
    var body: some View {
        ZStack {
            Color.gold.opacity(phase >= 1 ? 0.15 : 0)
                .ignoresSafeArea()
            
            ZStack {
                ForEach(0..<40, id: \.self) { _ in
                    RoyalParticle(phase: phase)
                }
            }
            
            if phase >= 1 {
                VStack(spacing: 8) {
                    Text("ROYAL FLUSH")
                        .font(.system(size: 54, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .gold, .orange, .gold, .yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .gold, radius: 20)
                        .shadow(color: .orange, radius: 40)
                        .scaleEffect(phase >= 2 ? 1.0 : 0.3)
                        .opacity(phase >= 2 ? 1 : 0)
                    
                    Text("JACKPOT !")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .opacity(phase >= 2 ? 0.9 : 0)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                phase = 1
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) {
                phase = 2
            }
        }
    }
}

private struct RoyalParticle: View {
    let phase: Int
    
    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var particleScale: CGFloat = 1
    @State private var rotation: Double = 0
    
    private let isSparkle = Bool.random()
    
    var body: some View {
        Group {
            if isSparkle {
                Image(systemName: "sparkle")
                    .font(.system(size: CGFloat.random(in: 10...22), weight: .bold))
            } else {
                Image(systemName: "star.fill")
                    .font(.system(size: CGFloat.random(in: 8...16)))
            }
        }
        .foregroundStyle(
            [Color.gold, .yellow, .orange, .white][Int.random(in: 0...3)]
        )
        .shadow(color: .gold, radius: 8)
        .offset(x: offsetX, y: offsetY)
        .opacity(opacity)
        .scaleEffect(particleScale)
        .rotationEffect(.degrees(rotation))
        .onChange(of: phase) { _, newPhase in
            guard newPhase >= 1 else { return }
            
            opacity = 1
            particleScale = CGFloat.random(in: 0.8...1.8)
            
            let duration = Double.random(in: 1.0...2.5)
            let delay = Double.random(in: 0...0.5)
            
            withAnimation(.easeOut(duration: duration).delay(delay)) {
                offsetX = CGFloat.random(in: -400...400)
                offsetY = CGFloat.random(in: -500...300)
                opacity = 0
                particleScale = 0.1
                rotation = Double.random(in: -360...360)
            }
        }
    }
}

extension Color {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
}
