//
//  PaytableView.swift
//  VideoPoker2
//
//  Created by Stephane Bertin on 05/04/2026.
//

import SwiftUI

struct PaytableView: View {
    let paytable: [PaytableEntry]
    let currentBet: Int
    let winningHand: HandType?

    private let colWidth: CGFloat = 110
    
    var body: some View {
        VStack(spacing: 0) {
            // En-tête de la table (Mises 1 à 5)
            HStack(spacing: 0) {
                Text("CREDITS")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.gold)
                
                ForEach(1...5, id: \.self) { betIndex in
                    Text("\(betIndex)")
                        .frame(width: colWidth)
                        .foregroundColor(currentBet == betIndex ? .white : .gold)
                        .background(currentBet == betIndex ? Color.gold.opacity(0.3) : Color.clear)
                        .bold(currentBet == betIndex)
                }
            }
            .font(.caption.bold())
            .padding(.bottom, 10)

            // Liste des mains et gains
            ForEach(paytable) { entry in
                // CORRECTION ICI : Ajout du paramètre columnWidth
                PaytableRow(
                    entry: entry,
                    isCurrentBet: currentBet,
                    isWinningRow: winningHand == entry.hand,
                    columnWidth: colWidth
                )
            }
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gold.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

#Preview("Mise 3 - Flush gagnant") {
    let paytable = HandType.allCases
        .filter { $0 != .highCard }
        .map { handType in
            let base = handType.basePayout
            return PaytableEntry(hand: handType, payouts: [
                base, base*2, base*3, base*4, (handType == .royalFlush ? 4000 : base*5)
            ])
        }
    
    ZStack {
        Color.black.ignoresSafeArea()
        PaytableView(paytable: paytable, currentBet: 3, winningHand: .flush)
            .padding(.horizontal, 80)
    }
}

#Preview("Mise 5 - Royal Flush") {
    let paytable = HandType.allCases
        .filter { $0 != .highCard }
        .map { handType in
            let base = handType.basePayout
            return PaytableEntry(hand: handType, payouts: [
                base, base*2, base*3, base*4, (handType == .royalFlush ? 4000 : base*5)
            ])
        }
    
    ZStack {
        Color.black.ignoresSafeArea()
        PaytableView(paytable: paytable, currentBet: 5, winningHand: .royalFlush)
            .padding(.horizontal, 80)
    }
}

// MARK: - Sous-vue pour une ligne de la table
struct PaytableRow: View {
    let entry: PaytableEntry
    let isCurrentBet: Int
    let isWinningRow: Bool
    let columnWidth: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            Text(entry.hand.rawValue.uppercased())
                .font(.system(size: 12, weight: isWinningRow ? .black : .medium))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(isWinningRow ? .yellow : .white)

            ForEach(0..<5, id: \.self) { index in
                // Appel d'une fonction d'aide pour soulager le compilateur
                cellView(for: index)
            }
        }
        .padding(.vertical, 4)
        .background(isWinningRow ? Color.yellow.opacity(0.2) : Color.clear)
    }
    
    // Extraire la cellule dans une fonction simplifie énormément le travail du compilateur
    @ViewBuilder
    private func cellView(for index: Int) -> some View {
        let multiplier = index + 1
        let payout = entry.payouts[index]
        let isTargetCell = isWinningRow && isCurrentBet == multiplier
        let isSelectedCol = isCurrentBet == multiplier
        
        Text("\(payout)")
            .font(.system(size: 12, weight: (isSelectedCol || isWinningRow) ? .bold : .regular))
            .frame(width: columnWidth)
            .foregroundColor(isTargetCell ? .black : (isWinningRow ? .yellow : .white))
            .background(isTargetCell ? Color.yellow : (isSelectedCol ? Color.white.opacity(0.1) : Color.clear))
    }
}
