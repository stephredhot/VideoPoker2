//
//  CasinoButtonStyle.swift
//  VideoPoker2
//
//  Created by Stephane Bertin on 06/04/2026.
//

import SwiftUI

struct CasinoButtonStyle: ButtonStyle {
    var color: Color
    var size: ButtonSize = .large
    @Environment(\.isEnabled) private var isEnabled
    
    enum ButtonSize { case large, medium, small }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size == .large ? .title2.bold() : size == .medium ? .headline : .subheadline)
            .foregroundStyle(.white)
            .frame(width: size == .small ? 140 : nil, height: size == .small ? 40 : nil)
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .padding(.horizontal, size == .large ? 48 : size == .medium ? 32 : 0)
            .padding(.vertical, size == .large ? 18 : size == .medium ? 14 : 0)
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(color)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.white.opacity(configuration.isPressed ? 0.15 : 0.08))
                    )
            }
            .shadow(color: color.opacity(0.5), radius: configuration.isPressed ? 4 : 10, y: configuration.isPressed ? 2 : 8)
            .opacity(isEnabled ? 1.0 : 0.5)
            .animation(.spring(), value: configuration.isPressed)
    }
}
