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
            .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
            .frame(width: size == .small ? 140 : nil, height: size == .small ? 40 : nil)
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .padding(.horizontal, size == .large ? 48 : size == .medium ? 32 : 0)
            .padding(.vertical, size == .large ? 18 : size == .medium ? 14 : 0)
            .offset(y: configuration.isPressed ? 4 : 0)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color)
                    
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.3)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.6), .white.opacity(0.05)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: geo.size.height * 0.5)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.8), .white.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1.5
                        )
                    
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.black.opacity(configuration.isPressed ? 0.35 : 0.0))
                }
            }
            .shadow(
                color: color.opacity(isEnabled ? 0.6 : 0.2),
                radius: configuration.isPressed ? 2 : 12,
                y: configuration.isPressed ? 2 : 8
            )
            .opacity(isEnabled ? 1.0 : 0.5)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
