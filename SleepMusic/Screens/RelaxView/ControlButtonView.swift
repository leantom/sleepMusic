//
//  ControlButtonView.swift
//  MusicSleep
//
//  Created by QuangHo on 13/10/24.
//

import SwiftUI

import SwiftUI

struct MediaControlView: View {
    @ObservedObject var audioPlayer = AudioPlayer.shared
    @State private var animate = false
    @State private var animateGradient = false

    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: 30) {
                    // Shuffle Button
                    Button(action: {
                        audioPlayer.toggleShuffle()
                    }) {
                        Image(systemName: audioPlayer.isShuffleEnabled ? "shuffle.circle.fill" : "shuffle")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    // Previous Button
                    Button(action: {
                        audioPlayer.previousTrack()
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
                        withAnimation {
                            audioPlayer.togglePlayPause()
                        }
                        
                    }) {
                        Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 25))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(LinearGradient(gradient: Gradient(colors: [.purple, .blue]),
                                                       startPoint: .top, endPoint: .bottom))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    
                    // Next Button
                    Button(action: {
                        audioPlayer.nextTrack()
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
                        audioPlayer.toggleRepeat()
                    }) {
                        Image(systemName: audioPlayer.isRepeatEnabled ? "repeat.circle.fill" : "repeat")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                
                Text(audioPlayer.currentTrack?.name ?? "Unknown Track")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .padding(.horizontal)
            }
            
        }
        .onAppear {
            if audioPlayer.isPlaying {
                animate = true
            }
        }
        .onChange(of: audioPlayer.isPlaying) { newValue in
            animate = newValue
        }
    }
}


struct WrapperMediaControlView: View {
    @State var isPlaying: Bool = false
    var body: some View {
        MediaControlView()
    }
}

struct MediaControlView_Previews: PreviewProvider {
    static var previews: some View {
        WrapperMediaControlView()
    }
}
