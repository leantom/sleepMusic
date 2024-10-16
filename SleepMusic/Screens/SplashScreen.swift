//
//  SplashScreen.swift
//  MusicSleep
//
//  Created by QuangHo on 13/10/24.
//

import SwiftUI

struct SplashScreenView: View {
    
    var body: some View {
        ZStack {
            // Background Gradient
            
            Image("background_image") // Replace with your image asset name
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .overlay {
                    LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.2), Color.black.opacity(0.4)]),
                                   startPoint: .top,
                                   endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all)
                }
            VStack {
                // Background image
                
                
                Spacer()
                
                // Character image (Sleepie)
                Image("background_image") // Replace with your image asset name
                    .resizable()
                    .frame(width: 100, height: 100) // Adjust size as needed
                    .padding(.bottom, 20)
                
                // Title Text
                Text("Sleeping is a journey")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 8)
                
                // Description Text
                Text("Try bedtime stories, sleep sounds & meditations to help you fall asleep fast.")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Progress Bar
                ProgressView(value: 0.5)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color.purple))
                    .padding(.horizontal, 60)
                    .padding(.top, 20)
            }
            .padding(.bottom, 50)
        }
    }
}

#Preview {
    SplashScreenView()
}
