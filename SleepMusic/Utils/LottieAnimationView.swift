//
//  LottieAnimationView.swift
//  SleepMusic
//
//  Created by QuangHo on 24/10/24.
//
import SwiftUI
import Lottie

import SwiftUI

struct BlinkingView: View {
    @State private var isAnimating = false
    @Binding var isStopAnimating: Bool
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                // Radiant effect around the circle
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 20)
                    .scaleEffect(isAnimating ? 1.5 : 1) // Pulsating effect
                    .opacity(isAnimating ? 0 : 1) // Fading effect
                    .animation(
                        Animation.easeInOut(duration: 3).repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                // Main circle
                Circle()
                    .fill(Color.white)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
            .onAppear {
                isAnimating = true
            }
        }
        .opacity(isStopAnimating ? 0 : 1)
    }
}

struct WrapperBlinkView: View {
    @State var isAnimate = false
    
    var body: some View {
        BlinkingView(isStopAnimating:  $isAnimate)
            .frame(width: 200, height: 200)
            
    }
}

struct BlinkingView_Previews: PreviewProvider {
    static var previews: some View {
        WrapperBlinkView()
    }
}
