//
//  Models.swift
//  VideoPoker2
//
//  Created by Stephane Bertin on 02/04/2026.
//

import Foundation

// MARK: - Rank
enum Rank: Int, CaseIterable, Comparable {
    case two = 2, three, four, five, six, seven, eight, nine, ten
    case jack = 11, queen = 12, king = 13, ace = 14
    
    nonisolated static func < (lhs: Rank, rhs: Rank) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    var displayString: String {
        switch self {
        case .two, .three, .four, .five, .six, .seven, .eight, .nine:
            return "\(rawValue)"
        case .ten: return "T"
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        case .ace: return "A"
        }
    }
    
}

// MARK: - Suit
enum Suit: String, CaseIterable {
    case hearts = "h"
    case diamonds = "d"
    case clubs = "c"
    case spades = "s"
    

}

// MARK: - Card
struct Card: Identifiable, Equatable, Hashable {
    let id = UUID()
    let rank: Rank
    let suit: Suit
    
    var imageName: String {
        rank.displayString + suit.rawValue
    }
    
    var isRed: Bool {
        suit == .hearts || suit == .diamonds
    }
}

// MARK: - HandType
enum HandType: String, CaseIterable {
    case royalFlush = "Royal Flush"
    case straightFlush = "Straight Flush"
    case fourOfAKind = "Four of a Kind"
    case fullHouse = "Full House"
    case flush = "Flush"
    case straight = "Straight"
    case threeOfAKind = "Three of a Kind"
    case twoPair = "Two Pair"
    case jacksOrBetter = "Jacks or Better"
    case highCard = "High Card"
    
    var basePayout: Int {
        switch self {
        case .royalFlush: return 250
        case .straightFlush: return 50
        case .fourOfAKind: return 25
        case .fullHouse: return 9
        case .flush: return 6
        case .straight: return 4
        case .threeOfAKind: return 3
        case .twoPair: return 2
        case .jacksOrBetter: return 1
        case .highCard: return 0
        }
    }
}

// MARK: - Paytable (pour affichage futur)
struct PaytableEntry: Identifiable {
    let hand: HandType
    let payouts: [Int] // index 0 = 1 crédit, ..., index 4 = 5 crédits
    
    var id: HandType { hand }
}

// MARK: - Deck
struct Deck {
    private var cards: [Card] = []
    
    init() {
        reset()
    }
    
    mutating func reset() {
        cards.removeAll()
        for rank in Rank.allCases {
            for suit in Suit.allCases {
                cards.append(Card(rank: rank, suit: suit))
            }
        }
        shuffle()
    }
    
    mutating func shuffle() {
        cards.shuffle()
    }
    
    mutating func deal() -> Card? {
        guard !cards.isEmpty else { return nil }
        return cards.removeFirst()
    }
    
    var remaining: Int { cards.count }
}
