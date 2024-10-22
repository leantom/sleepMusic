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
    @State var isShowTimer: Bool = false
    
    var body: some View {
        ZStack {
//            LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.8)]),
//                           startPoint: .top, endPoint: .bottom)
//            .edgesIgnoringSafeArea(.all)
            if isShowTimer {
                TimerSettingsView(isPresented: $isShowTimer)

            } else {
                VStack(spacing: 10) {
                    // Sounds Section
                    
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 18))
                                .foregroundStyle(.white)
                        }
                        .padding(.leading)
                        .frame(width: 50, height: 50)
                        Spacer()
                        Button {
                            withAnimation {
                                sounds.removeAll()
                            }
                        } label: {
                            Text("Clear All")
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                .foregroundStyle(.white)
                        }
                        .padding(.leading)
                        .frame(width: 100, height: 50)
                    }
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("SOUNDS PRO FOR YOU")
                                .font(.system(size: 18 , weight: .medium, design: .monospaced))
                                .foregroundStyle(.white)
                            Spacer()
                            
                        }
                        if sounds.count == 0 {
                            Text("No sounds added yet.")
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                .foregroundStyle(.white)
                        } else {
                            ScrollView(showsIndicators: false) {
                                ForEach($sounds) { $sound in
                                    SoundSlider(sound: $sound)
                                        .padding(.bottom, 10)
                                }
                            }
                            .frame(height: 350)
                        }
                        
                    }
                    .padding(.horizontal)
                    // Brainwave Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Add Name")
                            .foregroundStyle(.white)
                            .font(.system(size: 18 , weight: .medium, design: .monospaced))
                        HStack {
                            TextField(text: $titleMix) {
                                Text(isShowErr ? "Please enter a name" : "Ex:  Turn up the sleep vibes!")
                                    .foregroundStyle(isShowErr ? .red : .white)
                                    .font(.system(size: 13 , weight: .medium, design: .monospaced))
                            }
                            .focused($isTextFieldFocused)
                            .foregroundStyle(.white)
                            .font(.system(size: 13 , weight: .medium, design: .monospaced))
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10) // Rounded border with a corner radius
                                .stroke(isShowErr ? Color.red.opacity(0.5) : Color.gray.opacity(0.5), lineWidth: 1)
                        )
                    }
                    .padding()
                    Spacer()
                    
                    // Footer controls
                    HStack {
                        Button(action: {
                            // Set Timer logic
                            withAnimation {
                                isShowTimer.toggle()
                            }
                        }) {
                            
                            VStack(spacing: 10) {
                                Image(systemName: "clock")
                                    .font(.system(size: 25))
                                    .foregroundStyle(.white.opacity(0.5))
                                    .padding()
                                    .background(.gray.opacity(0.1))
                                    .clipShape(Circle())
                                Text("Set Timer")
                                    .frame(maxWidth: .infinity)
                                    .foregroundStyle(.white)
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
                                    .foregroundStyle(.white.opacity(0.5))
                                    .padding()
                                    .background(.gray.opacity(0.1))
                                    .clipShape(Circle())
                                Text("Try it out")
                                    .frame(maxWidth: .infinity)
                                    .foregroundStyle(.white)
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
                                    .foregroundStyle(.white.opacity(0.5))
                                    .padding()
                                    .background(.gray.opacity(0.4))
                                    .clipShape(Circle())
                                Text("Save Mix")
                                    .frame(maxWidth: .infinity)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 13 , weight: .medium, design: .monospaced))
                            }.padding()
                            
                        }
                    }
                    .background(.white.opacity(0.2))
                    .cornerRadius(20)
                    .padding()
                }
                .safeAreaInset(edge: .top) {
                    Color.clear.frame(height: 34)
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 44)
                }
                .background(Color.black.opacity(0.8))
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
                .foregroundStyle(.white)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            VStack (alignment:.leading) {
                Text(sound.name)
                    .font(.system(size: 14 , weight: .medium, design: .monospaced))
                    .foregroundStyle(.white)
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
