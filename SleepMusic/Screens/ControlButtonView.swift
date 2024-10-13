//
//  ControlButtonView.swift
//  MusicSleep
//
//  Created by QuangHo on 13/10/24.
//

import SwiftUI

struct MediaControlView: View {
    @State private var isPlaying: Bool = false
    
    var body: some View {
        HStack(spacing: 30) {
            // Shuffle Button
            Button(action: {
                // Action for shuffle
            }) {
                Image(systemName: "shuffle")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            
            // Previous Button
            Button(action: {
                // Action for previous
            }) {
                Image(systemName: "backward.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            
            // Play/Pause Button
            Button(action: {
                isPlaying.toggle()
            }) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 25))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom))
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            
            // Next Button
            Button(action: {
                // Action for next
            }) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            
            // Repeat Button
            Button(action: {
                // Action for repeat
            }) {
                Image(systemName: "repeat")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.2))
        .cornerRadius(30)
    }
}

struct MediaControlView_Previews: PreviewProvider {
    static var previews: some View {
        MediaControlView()
            .preferredColorScheme(.dark)
    }
}
