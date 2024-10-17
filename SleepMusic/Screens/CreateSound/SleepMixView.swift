//
//  SleepMixView.swift
//  SleepMusic
//
//  Created by QuangHo on 17/10/24.
//

import SwiftUI

struct SleepMixView: View {
    @Binding var sounds: [Sound]
    @Environment(\.dismiss) var dismiss
    @State var titleMix: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State var isPlaying: Bool = false
    @State var isShowErr: Bool = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.5), Color.gray.opacity(0.5), Color.gray.opacity(0.2)]),
                           startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 10) {
                // Sounds Section
               
                HStack {
                    Button {
                        dismiss()
                        AudioMixer.shared.stopMixedAudio()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .foregroundStyle(.black)
                    }
                    .padding(.leading)
                    .frame(width: 50, height: 50)
                    Spacer()
                }
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("SOUNDS PRO FOR YOU")
                            .font(.headline)
                        Spacer()
                        
                    }
                    ScrollView(showsIndicators: false) {
                        ForEach($sounds) { $sound in
                            SoundSlider(sound: $sound)
                                .padding(.bottom, 10)
                        }
                    }
                    .frame(height: 350)
                }
                .padding(.horizontal)
                // Brainwave Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Add Name")
                        .font(.headline)
                    
                    HStack {
                        TextField(text: $titleMix) {
                            Text(isShowErr ? "Please enter a name" : "Ex:  Turn up the sleep vibes!")
                                .foregroundStyle(isShowErr ? .red : .gray)
                        }
                        .focused($isTextFieldFocused)
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
                Spacer()
                
                // Footer controls
                HStack {
                    Button(action: {
                        // Set Timer logic
                    }) {
                        
                        VStack(spacing: 10) {
                            Image(systemName: "clock")
                                .font(.system(size: 25))
                                .foregroundStyle(.gray.opacity(0.5))
                                .padding()
                                .background(.gray.opacity(0.1))
                                .clipShape(Circle())
                            Text("Set Timer")
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.gray)
                                .font(.system(size: 13 , weight: .medium, design: .monospaced))
                        }
                        
                    }
                    
                    Button(action: {
                        // Save Mix logic
                        withAnimation {
                            isPlaying.toggle()
                            if isPlaying {
                                AudioMixer.shared.loadAudioFilesSound(sounds)
                                AudioMixer.shared.playMixedAudio()
                                
                            } else {
                                AudioMixer.shared.stopMixedAudio()
                            }
                        }
                    }) {
                        VStack(spacing: 10) {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 25))
                                .foregroundStyle(.gray.opacity(0.5))
                                .padding()
                                .background(.gray.opacity(0.1))
                                .clipShape(Circle())
                            Text("Try it out")
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.gray)
                                .font(.system(size: 13 , weight: .medium, design: .monospaced))
                        }
                        .padding()
                        
                    }
                    
                    Button(action: {
                        // Save Mix logic
                        if titleMix.isEmpty {
                            isShowErr = true
                            return
                        }
                        isShowErr = false
                        let soundMix = SoundMix(name: titleMix, sounds: self.sounds)
                        SoundMixManager.shared.addCombination(soundMix)
                        withAnimation {
                            self.dismiss()
                        }
                    }) {
                        VStack(spacing: 10) {
                            Image(systemName: "heart")
                                .font(.system(size: 25))
                                .foregroundStyle(.gray.opacity(0.5))
                                .padding()
                                .background(.gray.opacity(0.1))
                                .clipShape(Circle())
                            Text("Save Sounds")
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.gray)
                                .font(.system(size: 13 , weight: .medium, design: .monospaced))
                        }.padding()
                        
                    }
                }
                .background(.white.opacity(0.3))
                .cornerRadius(20)
                .padding()
            }
            .safeAreaInset(edge: .top) {
                Color.clear.frame(height: 34)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 44)
            }
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
}

struct SoundSlider: View {
    
    @Binding var sound: Sound
    
    var body: some View {
        HStack (spacing: 10){
            Image(systemName: sound.icon)
                .frame(width: 48, height: 48)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            VStack (alignment:.leading) {
                Text(sound.name)
                    .font(.system(size: 13, weight: .medium))
                Slider(value: $sound.volume, in: 0...1)
                    .accentColor(.purple)
            }
            
            
        }
    }
}

struct WrapperSleepViewMix: View {
    @State var sounds:[Sound] = SoundCategory.getAllSounds()
    var body: some View {
        SleepMixView(sounds: $sounds)
    }
}

#Preview {
    WrapperSleepViewMix()
}
