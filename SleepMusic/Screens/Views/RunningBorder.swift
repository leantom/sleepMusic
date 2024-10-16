//
//  RunningBorder.swift
//  SleepMusic
//
//  Created by QuangHo on 16/10/24.
//

import SwiftUI

struct RunningBorder: AnimatableModifier {
    var phase: CGFloat
    var lineWidth: CGFloat
    var isPlaying: Bool

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func body(content: Content) -> some View {
        content.overlay(
            RoundedRectangle(cornerRadius: 30)
                .trim(from: 0, to: 1)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, dash: [10, 5], dashPhase: phase)
                )
                .cornerRadius(30)
                .opacity(isPlaying ? 1 : 0)
        )
    }
}
