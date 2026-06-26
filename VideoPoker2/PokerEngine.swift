//
//  PokerEngine.swift
//  VideoPoker2
//
//  Created by Antigravity on 26/06/2026.
//

import Foundation

struct PokerEngine {
    
    // MARK: - Hand Evaluation
    
    static func evaluateHand(_ cards: [Card]) -> HandType {
        guard cards.count == 5 else {
            return .highCard
        }
        
        // Tri descendant (Ace haut)
        let sortedCards = cards.sorted { $0.rank > $1.rank }
        let ranks = sortedCards.map { $0.rank }
        let suits = sortedCards.map { $0.suit }
        
        let isFlush = Set(suits).count == 1
        let isStraight = isStraightHand(ranks)
        
        // === Priorité des mains ===
        if isFlush && isStraight && ranks[0] == .ace && ranks[4] == .ten {
            return .royalFlush
        }
        
        if isFlush && isStraight { return .straightFlush }
        
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
               pairRank.rawValue >= Rank.jack.rawValue {
                return .jacksOrBetter
            }
        }
        
        return .highCard
    }
    
    static func isStraightHand(_ ranks: [Rank]) -> Bool {
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
    
    // MARK: - Winning Cards Finder
    
    static func determineWinningCardIndices(for handType: HandType, in cards: [Card]) -> Set<Int> {
        guard cards.count == 5 else { return [] }
        
        switch handType {
        case .royalFlush, .straightFlush, .fullHouse, .flush, .straight:
            return Set(0..<5)
            
        case .fourOfAKind:
            var rankCounts: [Rank: Int] = [:]
            for card in cards {
                rankCounts[card.rank, default: 0] += 1
            }
            if let targetRank = rankCounts.first(where: { $0.value == 4 })?.key {
                return Set(cards.enumerated().filter { $0.element.rank == targetRank }.map { $0.offset })
            }
            return []
            
        case .threeOfAKind:
            var rankCounts: [Rank: Int] = [:]
            for card in cards {
                rankCounts[card.rank, default: 0] += 1
            }
            if let targetRank = rankCounts.first(where: { $0.value == 3 })?.key {
                return Set(cards.enumerated().filter { $0.element.rank == targetRank }.map { $0.offset })
            }
            return []
            
        case .twoPair:
            var rankCounts: [Rank: Int] = [:]
            for card in cards {
                rankCounts[card.rank, default: 0] += 1
            }
            let targetRanks = rankCounts.filter { $0.value == 2 }.map { $0.key }
            return Set(cards.enumerated().filter { targetRanks.contains($0.element.rank) }.map { $0.offset })
            
        case .jacksOrBetter:
            var rankCounts: [Rank: Int] = [:]
            for card in cards {
                rankCounts[card.rank, default: 0] += 1
            }
            if let targetRank = rankCounts.first(where: { $0.value == 2 && $0.key.rawValue >= Rank.jack.rawValue })?.key {
                return Set(cards.enumerated().filter { $0.element.rank == targetRank }.map { $0.offset })
            }
            return []
            
        case .highCard:
            return []
        }
    }
    
    // MARK: - Optimal Strategy Auto-Hold
    
    static func suggestHolds(for cards: [Card]) -> Set<Int> {
        guard cards.count == 5 else { return [] }
        
        let handType = evaluateHand(cards)
        
        // 1. Mains déjà faites majeures : Royal Flush, Straight Flush, Four of a Kind
        if handType == .royalFlush || handType == .straightFlush || handType == .fourOfAKind {
            return Set(0..<5)
        }
        
        // 2. Tirage à 4 cartes vers Royal Flush
        if let royalFlushDraw4 = findRoyalFlushDraw(in: cards, count: 4) {
            return royalFlushDraw4
        }
        
        // 3. Brelan (Three of a Kind)
        if handType == .threeOfAKind {
            return determineWinningCardIndices(for: .threeOfAKind, in: cards)
        }
        
        // 4. Mains déjà faites intermédiaires : Straight, Full House, Flush
        if handType == .straight || handType == .fullHouse || handType == .flush {
            return Set(0..<5)
        }
        
        // 5. Tirage à 4 cartes vers Straight Flush
        if let straightFlushDraw4 = findStraightFlushDraw(in: cards, count: 4) {
            return straightFlushDraw4
        }
        
        // 6. Double Paire (Two Pair)
        if handType == .twoPair {
            return determineWinningCardIndices(for: .twoPair, in: cards)
        }
        
        // 7. Paire forte (Jacks or Better)
        if handType == .jacksOrBetter {
            return determineWinningCardIndices(for: .jacksOrBetter, in: cards)
        }
        
        // 8. Tirage à 3 cartes vers Royal Flush
        if let royalFlushDraw3 = findRoyalFlushDraw(in: cards, count: 3) {
            return royalFlushDraw3
        }
        
        // 9. Tirage à 4 cartes vers Couleur (Flush)
        if let flushDraw4 = findFlushDraw(in: cards, count: 4) {
            return flushDraw4
        }
        
        // 10. Paire faible (10 ou moins)
        if let lowPair = findLowPair(in: cards) {
            return lowPair
        }
        
        // 11. Tirage à 4 cartes vers Quinte ouverte (Open-ended Straight)
        if let openEndedStraightDraw4 = findOpenEndedStraightDraw(in: cards) {
            return openEndedStraightDraw4
        }
        
        // 12. Deux cartes hautes assorties (Suited High Cards >= Valet)
        if let suitedHighCards = findSuitedHighCards(in: cards) {
            return suitedHighCards
        }
        
        // 13. Tirage à 3 cartes vers Straight Flush
        if let straightFlushDraw3 = findStraightFlushDraw(in: cards, count: 3) {
            return straightFlushDraw3
        }
        
        // 14. Deux cartes hautes non-assorties (Unsuited High Cards >= Valet)
        if let unsuitedHighCards = findUnsuitedHighCards(in: cards) {
            return unsuitedHighCards
        }
        
        // 15. Combinaisons assorties 10-J, 10-Q ou 10-K
        if let suited10AndHigh = findSuited10AndHighCard(in: cards) {
            return suited10AndHigh
        }
        
        // 16. Une seule carte haute (Jack, Queen, King, Ace)
        if let singleHighCard = findSingleHighCard(in: cards) {
            return [singleHighCard]
        }
        
        // 17. Rien du tout : tout jeter
        return []
    }
    
    // MARK: - Stratégie - Méthodes d'aide privées
    
    private static func findRoyalFlushDraw(in cards: [Card], count: Int) -> Set<Int>? {
        let royalRanks: Set<Rank> = [.ten, .jack, .queen, .king, .ace]
        let royalIndices = cards.indices.filter { royalRanks.contains(cards[$0].rank) }
        let grouped = Dictionary(grouping: royalIndices, by: { cards[$0].suit })
        for (_, indices) in grouped {
            if indices.count == count {
                return Set(indices)
            }
        }
        return nil
    }
    
    private static func findFlushDraw(in cards: [Card], count: Int) -> Set<Int>? {
        let grouped = Dictionary(grouping: cards.indices, by: { cards[$0].suit })
        for (_, indices) in grouped {
            if indices.count == count {
                return Set(indices)
            }
        }
        return nil
    }
    
    private static func findLowPair(in cards: [Card]) -> Set<Int>? {
        var rankGroups: [Rank: [Int]] = [:]
        for (i, card) in cards.enumerated() {
            rankGroups[card.rank, default: []].append(i)
        }
        for (rank, indices) in rankGroups {
            if indices.count == 2 && rank.rawValue < Rank.jack.rawValue {
                return Set(indices)
            }
        }
        return nil
    }
    
    private static func findOpenEndedStraightDraw(in cards: [Card]) -> Set<Int>? {
        for skip in 0..<5 {
            let kept = (0..<5).filter { $0 != skip }
            let keptCards = kept.map { cards[$0] }
            let ranks = keptCards.map { $0.rank }.sorted()
            let values = ranks.map { $0.rawValue }
            
            guard Set(values).count == 4 else { continue }
            
            // Une suite ouverte a un écart de 3 et ne contient aucun As (l'As bloque un bout)
            if values[3] - values[0] == 3 && ranks[0] != .ace && ranks[3] != .ace {
                return Set(kept)
            }
        }
        return nil
    }
    
    private static func findStraightFlushDraw(in cards: [Card], count: Int) -> Set<Int>? {
        let grouped = Dictionary(grouping: cards.indices, by: { cards[$0].suit })
        for (_, indices) in grouped {
            if indices.count >= count {
                let combos = combinations(indices, size: count)
                for combo in combos {
                    if canFormStraight(combo.map { cards[$0] }) {
                        return Set(combo)
                    }
                }
            }
        }
        return nil
    }
    
    private static func canFormStraight(_ subset: [Card]) -> Bool {
        let ranks = subset.map { $0.rank }
        let values = ranks.map { $0.rawValue }
        guard Set(values).count == subset.count else { return false }
        
        // Cas 1 : As considéré comme 14 (haut)
        let span1 = values.max()! - values.min()!
        if span1 <= 4 { return true }
        
        // Cas 2 : As considéré comme 1 (bas)
        if ranks.contains(.ace) {
            let lowValues = values.map { $0 == 14 ? 1 : $0 }
            let span2 = lowValues.max()! - lowValues.min()!
            if span2 <= 4 { return true }
        }
        
        return false
    }
    
    private static func findSuitedHighCards(in cards: [Card]) -> Set<Int>? {
        let highIndices = cards.indices.filter { cards[$0].rank.rawValue >= Rank.jack.rawValue }
        let grouped = Dictionary(grouping: highIndices, by: { cards[$0].suit })
        for (_, indices) in grouped {
            if indices.count == 2 {
                return Set(indices)
            }
        }
        return nil
    }
    
    private static func findUnsuitedHighCards(in cards: [Card]) -> Set<Int>? {
        let highIndices = cards.indices.filter { cards[$0].rank.rawValue >= Rank.jack.rawValue }
        guard highIndices.count >= 2 else { return nil }
        
        // Tri des cartes hautes par rang ascendant
        let sortedIndices = highIndices.sorted { cards[$0].rank < cards[$1].rank }
        
        // On conserve les deux cartes hautes les plus basses (meilleures chances de suite)
        return Set(sortedIndices.prefix(2))
    }
    
    private static func findSuited10AndHighCard(in cards: [Card]) -> Set<Int>? {
        let tenIndices = cards.indices.filter { cards[$0].rank == .ten }
        let highIndices = cards.indices.filter {
            let r = cards[$0].rank
            return r == .jack || r == .queen || r == .king
        }
        
        for tenIdx in tenIndices {
            for highIdx in highIndices {
                if cards[tenIdx].suit == cards[highIdx].suit {
                    return [tenIdx, highIdx]
                }
            }
        }
        return nil
    }
    
    private static func findSingleHighCard(in cards: [Card]) -> Int? {
        return cards.indices.first { cards[$0].rank.rawValue >= Rank.jack.rawValue }
    }
    
    // MARK: - Outil combinatoire réutilisable
    
    private static func combinations<T>(_ array: [T], size: Int) -> [[T]] {
        guard size > 0 else { return [[]] }
        guard let first = array.first else { return [] }
        let rest = Array(array.dropFirst())
        let withFirst = combinations(rest, size: size - 1).map { [first] + $0 }
        let withoutFirst = combinations(rest, size: size)
        return withFirst + withoutFirst
    }
}
