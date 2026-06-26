//
//  VideoPokerViewModel.swift
//  VideoPoker2
//
//  Created by Stephane Bertin on 02/04/2026.
//

import SwiftUI

@MainActor @Observable
final class VideoPokerViewModel {
    
    // MARK: - Constantes
    private static let maxDoubleAttempts = 4

    // MARK: - États publics
    var credits: Int = UserDefaults.standard.object(forKey: "playerCredits") as? Int ?? 1000 {
        didSet { UserDefaults.standard.set(credits, forKey: "playerCredits") }
    }
    var bet: Int = UserDefaults.standard.object(forKey: "playerBet") as? Int ?? 1 {
        didSet { UserDefaults.standard.set(bet, forKey: "playerBet") }
    }
    var hand: [Card] = []
    var heldIndices: Set<Int> = []
    
    var gamePhase: GamePhase = .betting
    var lastWin: Int = 0
    var message: String = "Placez votre mise et cliquez sur DEAL"
    
    var showDoubleScreen: Bool = false
    var doubleWin: Int = 0
    var doubleCount: Int = 0
    
    var winningHandType: HandType? = nil
    var winningCardIndices: Set<Int> = []
    
    var faceUpCards: Set<Int> = []
    
    var lastDoubleCard: Card? = nil
    var isFlippingDoubleCard: Bool = false
    var showRoyalFlushEffect: Bool = false
    var isDoubleEvaluating: Bool = false
    
    var isDoubleAnimating: Bool {
        lastDoubleCard != nil && !isFlippingDoubleCard
    }
    
    var canDouble: Bool {
        doubleWin > 0 && doubleCount < Self.maxDoubleAttempts && !isDoubleAnimating && !isDoubleEvaluating
    }
    
    //MARK: - Etats privés
    private var deck = Deck()
    
    let paytable: [PaytableEntry] = HandType.allCases
        .filter { $0 != .highCard }
        .map { handType in
            let base = handType.basePayout
            return PaytableEntry(hand: handType, payouts: [
                base, base*2, base*3, base*4, (handType == .royalFlush ? 4000 : base*5)
            ])
        }
    
    //MARK: - GamePhase
    enum GamePhase {
        case betting
        case dealing
        case dealt
        case drawing
        case result
    }
    
    // MARK: - Actions principales
    func increaseBet() {
        guard gamePhase == .betting || gamePhase == .result else { return }
        SoundManager.shared.playButton()
        bet = min(5, bet + 1)
    }
    
    func decreaseBet() {
        guard gamePhase == .betting || gamePhase == .result else { return }
        SoundManager.shared.playButton()
        bet = max(1, bet - 1)
    }
    
    func maxBet() {
        guard gamePhase == .betting || gamePhase == .result else { return }
        SoundManager.shared.playButton()
        bet = 5
    }
    
    func deal() {
        guard gamePhase == .betting || gamePhase == .result else { return }
        guard credits >= bet else {
            message = "Crédits insuffisants !"
            return
        }

        SoundManager.shared.playButton()
        
        credits -= bet
        resetHand()
        deck.reset()
        faceUpCards.removeAll()
        
        hand = (0..<5).compactMap { _ in deck.deal() }
        
        gamePhase = .dealing
        message = "Distribution..."

        Task {
            try? await Task.sleep(for: .seconds(0.3))
            await revealInitialCards()
            gamePhase = .dealt
        }
    }

    // MARK: - Animation Helper pour deal()

    private func revealInitialCards() async {
        for i in 0..<5 {
            // Délai progressif entre chaque carte (0.10s d'intervalle)
            try? await Task.sleep(for: .seconds(Double(i) * 0.10))
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                _ = faceUpCards.insert(i)
            }
            SoundManager.shared.playCardFlip()
        }
        
        // Message final une fois toutes les cartes révélées
        try? await Task.sleep(for: .seconds(0.1))
        message = "Choisissez les cartes à garder (HOLD)"
    }
    
    func toggleHold(at index: Int) {
        guard gamePhase == .dealt else { return }
        SoundManager.shared.playButton()
        if heldIndices.contains(index) {
            heldIndices.remove(index)
        } else {
            heldIndices.insert(index)
        }
    }
    
    func draw() {
        guard gamePhase == .dealt else { return }
        
        SoundManager.shared.playButton()
        gamePhase = .drawing
        message = "Tirage en cours..."
        
        Task {
            await flipDownDiscardedCards()
            
            await replaceDiscardedCards()
            await revealNewCards()
            evaluateHand()
        }
    }

    // MARK: - Animation Helpers (privées)

    private func flipDownDiscardedCards() async {
        for index in 0..<5 where !heldIndices.contains(index) {
            withAnimation(.easeInOut(duration: 0.25)) {
                _ = faceUpCards.remove(index)   // ← on ignore explicitement le résultat du Set
            }
        }
        try? await Task.sleep(for: .seconds(0.35))
    }

    private func replaceDiscardedCards() async {
        for index in 0..<5 where !heldIndices.contains(index) {
            if let newCard = deck.deal() {
                hand[index] = newCard
            }
            SoundManager.shared.playCardFlip()
        }
        try? await Task.sleep(for: .seconds(0.1))
    }

    private func revealNewCards() async {
        for index in 0..<5 where !heldIndices.contains(index) {
            try? await Task.sleep(for: .seconds(0.15))
            
            withAnimation(.spring(response: 0.52, dampingFraction: 0.68)) {
                _ = faceUpCards.insert(index)   // ← on ignore explicitement
            }
            SoundManager.shared.playCardFlip()
        }
        try? await Task.sleep(for: .seconds(0.25))
    }

    private func evaluateHand() {
        let handType = PokerEngine.evaluateHand(hand)
        let totalWin: Int
        if let entry = paytable.first(where: { $0.hand == handType }) {
            totalWin = entry.payouts[bet - 1]
        } else {
            totalWin = 0
        }
        
        lastWin = totalWin
        winningHandType = handType
        
        if totalWin > 0 {
            message = "\(handType.rawValue) ! +\(totalWin) crédits"
            SoundManager.shared.playWin()
            winningCardIndices = PokerEngine.determineWinningCardIndices(for: handType, in: hand)
            if handType == .royalFlush {
                showRoyalFlushEffect = true
            }
        } else {
            message = "Perdu - \(handType.rawValue)"
            winningHandType = nil
            winningCardIndices = []
        }
        
        heldIndices.removeAll()
        gamePhase = .result
    }


    
    // MARK: - Collecte et Doublage
    
    func collectWin() {
        guard lastWin > 0 else { return }
        SoundManager.shared.playPayout()
        let amount = lastWin
        message = "Collecté : +\(amount) crédits"
        lastWin = 0
        winningHandType = nil
        showRoyalFlushEffect = false
        Task { await animateCredits(adding: amount) }
    }
    
    func startDouble() {
        guard lastWin > 0 else { return }
        SoundManager.shared.playButton()
        doubleWin = lastWin
        doubleCount = 0
        lastWin = 0
        winningHandType = nil
        showRoyalFlushEffect = false
        lastDoubleCard = nil
        isFlippingDoubleCard = false
        showDoubleScreen = true
    }
    
    func doubleOnColor(choiceIsRed: Bool) {
        guard doubleCount < Self.maxDoubleAttempts && doubleWin > 0 && !isDoubleEvaluating else { return }
        
        SoundManager.shared.playButton()
        isDoubleEvaluating = true
        
        deck.reset()
        guard let drawnCard = deck.deal() else {
            isDoubleEvaluating = false
            return
        }
        
        lastDoubleCard = drawnCard
        isFlippingDoubleCard = false
        
        Task {
            // Laisse le temps à SwiftUI d'afficher la nouvelle carte face cachée
            try? await Task.sleep(for: .milliseconds(50))
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isFlippingDoubleCard = true
            }
            
            try? await Task.sleep(for: .seconds(0.6))
            let isCorrect = (choiceIsRed && drawnCard.isRed) || (!choiceIsRed && !drawnCard.isRed)
            
            if isCorrect {
                doubleWin *= 2
                doubleCount += 1
                message = "Gagné ! \(drawnCard.rank.displayString)\(drawnCard.suit.rawValue.uppercased())"
                isDoubleEvaluating = false
            } else {
                doubleWin = 0
                lastWin = 0
                message = "Perdu sur \(drawnCard.rank.displayString)\(drawnCard.suit.rawValue.uppercased())"
                
                try? await Task.sleep(for: .seconds(1.5))
                showDoubleScreen = false
                isDoubleEvaluating = false
            }
        }
    }
    
    func collectDouble() {
        guard doubleWin > 0 else {
            showDoubleScreen = false
            return
        }
        
        SoundManager.shared.playPayout()
        
        let amountWon = doubleWin
        showDoubleScreen = false
        doubleWin = 0
        doubleCount = 0
        lastWin = 0
        winningHandType = nil
        message = "Collecté : +\(amountWon) crédits"
        Task { await animateCredits(adding: amountWon) }
    }
    
    // MARK: - Animation compteur
    
    private func animateCredits(adding amount: Int) async {
        let steps = max(1, min(amount, 25))
        let perStep = amount / steps
        let remainder = amount - (perStep * steps)
        let delay = amount > 100 ? 0.03 : 0.05
        
        for i in 0..<steps {
            try? await Task.sleep(for: .seconds(delay))
            credits += perStep + (i < remainder ? 1 : 0)
        }
    }
    
    // MARK: - Utilitaires
    
    func resetCreditsIfBroke() {
        guard credits <= 0 else { return }
        credits = 100
        message = "Bonus de relance : +100 crédits !"
    }
    
    private func resetHand() {
        hand.removeAll()
        heldIndices.removeAll()
        winningHandType = nil
        winningCardIndices = []
        lastWin = 0
    }
    
    func autoHold() {
        guard gamePhase == .dealt else { return }
        SoundManager.shared.playButton()
        heldIndices = PokerEngine.suggestHolds(for: hand)
    }
}

