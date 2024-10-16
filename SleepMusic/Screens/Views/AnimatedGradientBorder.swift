//
//  AnimatedGradientBorder.swift
//  SleepMusic
//
//  Created by QuangHo on 16/10/24.
//

import SwiftUI
struct AnimatedGradientBorder: AnimatableModifier {
    var startAngle: Double
    var lineWidth: CGFloat
    var isPlaying: Bool

    var animatableData: Double {
        get { startAngle }
        set { startAngle = newValue }
    }

    func body(content: Content) -> some View {
        content.overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]),
                        center: .center,
                        startAngle: .degrees(startAngle),
                        endAngle: .degrees(startAngle + 360)
                    ),
                    lineWidth: lineWidth
                )
                .opacity(isPlaying ? 1 : 0)
        )
    }
}

