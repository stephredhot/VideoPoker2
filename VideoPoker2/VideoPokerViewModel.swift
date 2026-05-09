//
//  VideoPokerViewModel.swift
//  VideoPoker2
//
//  Created by Stephane Bertin on 02/04/2026.
//

import SwiftUI

@MainActor @Observable
final class VideoPokerViewModel {
    
    // MARK: - États publics
    var credits: Int = 1000
    var bet: Int = 1
    var hand: [Card] = []
    var heldIndices: Set<Int> = []
    
    var gamePhase: GamePhase = .betting
    var lastWin: Int = 0
    var message: String = "Placez votre mise et cliquez sur DEAL"
    
    var showDoubleScreen: Bool = false
    var doubleWin: Int = 0
    var doubleCount: Int = 0
    
    var winningHandType: HandType? = nil
    
    var faceUpCards: Set<Int> = []
    
    var lastDoubleCard: Card? = nil
    var isFlippingDoubleCard: Bool = false
    var showRoyalFlushEffect: Bool = false
    
    var isDoubleAnimating: Bool {
        lastDoubleCard != nil && !isFlippingDoubleCard
    }
    
    var canDouble: Bool {
        doubleWin > 0 && doubleCount < 4 && !isDoubleAnimating
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
        deck.shuffle()
        faceUpCards.removeAll()
        
        hand = (0..<5).compactMap { _ in deck.deal() }
        
        gamePhase = .dealt
        message = "Distribution..."

        Task {
            try? await Task.sleep(for: .seconds(0.3))
            await revealInitialCards()
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
        let handType = evaluateHandLogic(hand)
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
            if handType == .royalFlush {
                showRoyalFlushEffect = true
            }
        } else {
            message = "Perdu - \(handType.rawValue)"
            winningHandType = nil
        }
        
        gamePhase = .result
    }
    
    // MARK: - évaluation des mains
    nonisolated func evaluateHandLogic(_ cards: [Card]) -> HandType {
        guard cards.count == 5 else {
            return .highCard
        }
        
        // Tri descendant (Ace haut)
        let sortedCards = cards.sorted { $0.rank > $1.rank }
        let ranks = sortedCards.map { $0.rank }
        let suits = sortedCards.map { $0.suit }
        
        let isFlush = Set(suits).count == 1
        
        // Détection du Straight
        let isStraight = isStraightHand(ranks)
        
        // === Priorité des mains (du plus fort au plus faible) ===
        
        if isFlush && isStraight && ranks[0] == .ace && ranks[4] == .ten {
            return .royalFlush
        }
        
        if isFlush && isStraight { return .straightFlush }
        
        // Comptage des fréquences de chaque rang
        var rankCount: [Rank: Int] = [:]
        for rank in ranks {
            rankCount[rank, default: 0] += 1
        }
        
        let counts = rankCount.values.sorted(by: >)
        
        if counts.first == 4 { return .fourOfAKind }
        if counts == [3, 2] { return .fullHouse }
        if isFlush { return .flush }
        if isStraight { return .straight }
        if counts.first == 3 { return .threeOfAKind }
        if counts == [2, 2, 1] { return .twoPair }
        
        if counts.first == 2 {
            if let pairRank = rankCount.first(where: { $0.value == 2 })?.key,
               pairRank.rawValue >= 11 {
                return .jacksOrBetter
            }
        }
        
        return .highCard
    }
    
    nonisolated func isStraightHand(_ ranks: [Rank]) -> Bool {
        guard ranks.count == 5 else { return false }
        
        let values = ranks.map { $0.rawValue }
        
        // Straight normal : 5 cartes consécutives sans doublon
        if Set(values).count == 5 && values[0] - values[4] == 4 {
            return true
        }
        
        // Wheel Straight : A-5-4-3-2
        if ranks[0] == .ace &&
           ranks[1] == .five &&
           ranks[2] == .four &&
           ranks[3] == .three &&
           ranks[4] == .two {
            return true
        }
        
        return false
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
        showDoubleScreen = true
    }
    
    func doubleOnColor(choiceIsRed: Bool) {
        guard doubleCount < 4 && doubleWin > 0 else { return }
        
        SoundManager.shared.playButton()
        
        deck.reset()
        deck.shuffle()
        guard let drawnCard = deck.deal() else { return }
        
        lastDoubleCard = drawnCard
        isFlippingDoubleCard = false
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isFlippingDoubleCard = true
        }
        
        Task {
            try? await Task.sleep(for: .seconds(0.6))
            let isCorrect = (choiceIsRed && drawnCard.isRed) || (!choiceIsRed && !drawnCard.isRed)
            
            if isCorrect {
                doubleWin *= 2
                doubleCount += 1
                message = "Gagné ! \(drawnCard.rank.displayString)\(drawnCard.suit.rawValue.uppercased())"
            } else {
                doubleWin = 0
                lastWin = 0
                message = "Perdu sur \(drawnCard.rank.displayString)\(drawnCard.suit.rawValue.uppercased())"
                
                try? await Task.sleep(for: .seconds(1.5))
                showDoubleScreen = false
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
        lastWin = 0
    }
    
    func autoHold() {
        guard gamePhase == .dealt else { return }
        SoundManager.shared.playButton()
        heldIndices.removeAll()
        
        let handType = evaluateHandLogic(hand)
        
        switch handType {
        case .royalFlush, .straightFlush, .fullHouse, .flush, .straight:
            heldIndices = Set(0..<5)
            return
        default:
            break
        }
        
        if handType != .highCard {
            var seen: [Rank: [Int]] = [:]
            for (i, card) in hand.enumerated() {
                seen[card.rank, default: []].append(i)
            }
            for indices in seen.values where indices.count >= 2 {
                for idx in indices {
                    heldIndices.insert(idx)
                }
            }
            return
        }
        
        // Pas de main payante — chercher 4 cartes vers un flush
        let suitGroups = Dictionary(grouping: hand.indices, by: { hand[$0].suit })
        if let group = suitGroups.values.first(where: { $0.count >= 4 }) {
            heldIndices = Set(group)
            return
        }
        
        // Chercher 4 cartes vers un straight
        for skip in 0..<5 {
            let kept = (0..<5).filter { $0 != skip }
            let values = kept.map { hand[$0].rank.rawValue }.sorted()
            if Set(values).count == 4 && values[3] - values[0] == 3 {
                heldIndices = Set(kept)
                return
            }
        }
        
        // Garder les figures (Jack ou mieux)
        for (i, card) in hand.enumerated() {
            if card.rank.rawValue >= Rank.jack.rawValue {
                heldIndices.insert(i)
            }
        }
    }
}

