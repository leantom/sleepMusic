//
//  CreateSoundView.swift
//  MusicSleep
//
//  Created by QuangHo on 13/10/24.
//

import SwiftUI
import FirebaseAnalytics

struct ZenMusicView: View {
    @ObservedObject var soundMixManager = SoundMixManager.shared
    @State private var isSaveCombinationViewPresented = false
    @ObservedObject var audioMixer: AudioMixer = AudioMixer.shared
    let categories = SoundCategory.getCategories()
    @State private var inputText: String = ""
    // Filtered sounds based on selected category
    var filteredSounds: [Sound] {
        if selectedCategory == "All" {
            return SoundCategory.getAllSounds()
        }
        if let category = categories.first(where: { $0.name == selectedCategory }) {
            return category.sounds
        } else {
            return categories.flatMap { $0.sounds }
        }
    }
    
    @State private var selectedTab: String = "Sounds" // Track selected tab

    @State private var selectedCategory = "All" // Tracks the currently selected category
    @State private var isControlPanelVisible: Bool = true // Track visibility of the control panel
    @State private var animateOffset: CGFloat = 0
    @State private var isRelaxingMusicViewPresented = false // New state variable
    
    @State private var isShowAlarmViewPresented = false // New state variable
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.black]),
                           startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                .overlay {
                    Image("bg_create_sound")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        
                }
            
            VStack {
               
                Spacer()
                
                VStack {
                    HStack {
                        Button {
                            withAnimation {
                                Analytics.logEvent("alarm_view_opened", parameters: nil)
                                isShowAlarmViewPresented.toggle()
                            }
                            
                        } label: {
                            Image(systemName: "alarm.waves.left.and.right.fill")
                                .font(.system(size: 23))
                                .foregroundStyle(.white)
                                .frame(width: 35, height: 35)
                                
                        }
                        .padding()

                        Spacer()
                        Text("For when counting sheep isn’t enough.")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .padding()
                    }
                    HStack(spacing: 0) {
                        
                        // Sounds Button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTab = "Sounds"
                                Analytics.logEvent("tab_selected", parameters: ["tab": "Sounds"])
                            }
                        }) {
                            ZStack {
                                Rectangle()
                                    .fill( selectedTab == "Sounds" ? Color.purple : Color.clear)
                                    .cornerRadius(20)
                                    .opacity(selectedTab == "Sounds" ? 1 : 0)
                                    .offset(x: selectedTab == "Sounds" ? 0 : 200)
                                
                                Text("Sounds")
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    .foregroundColor(selectedTab == "Sounds" ? .white : .gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                
                            }
                        }
                        
                        Spacer().frame(width: 10)
                        
                        // Saved Button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTab = "Saved"
                                Analytics.logEvent("tab_selected", parameters: ["tab": "Saved"])
                            }
                        }) {
                            ZStack {
                                Rectangle()
                                    .fill( selectedTab == "Saved" ? Color.purple : Color.clear)
                                    .cornerRadius(20)
                                    .opacity(selectedTab == "Saved" ? 1 : 0)
                                    .offset(x: selectedTab == "Saved" ? 0 : -200)
                                
                                Text("Saved")
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    .foregroundColor(selectedTab == "Saved" ? .white : .gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.2))
                    )
                    .frame(height: 48)
                    .padding(.horizontal)
                }
                .padding(.top, 44)
                //MARK: Horizontal category selection
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        //MARK: selected tab
                        if selectedTab == "Saved" {
                            HStack {
                                Text("Your Saved Songs")
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.horizontal)
                                    .foregroundStyle(.white)
                            }
                        } else {
                            HStack(spacing: 16) {
                                ForEach(categories) { category in
                                    Button(action: {
                                        //MARK: Update selected category
                                        withAnimation {
                                            selectedCategory = category.name
                                        }
                                        
                                    }) {
                                        Text(category.name)
                                            .font(.system(size: 14, weight: .regular, design: .monospaced))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                selectedCategory == category.name ? Color.purple : Color.clear
                                            )
                                            .foregroundColor(
                                                selectedCategory == category.name ? .white : .gray
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color.purple, lineWidth: 1)
                                            )
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                    }
                    .padding()
                    //MARK: Sound Option Buttons
                    if selectedTab == "Saved" {
                        
                        VStack(spacing: 10) {
                            if soundMixManager.savedCombinations.isEmpty {
                                Text("No saved combinations yet.")
                                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                                    .foregroundStyle(.white)
                            } else {
                                ForEach(soundMixManager.savedCombinations) { track in
                                    SoundMixRow(soundMix: track, onDelete: {
                                        delete(soundMix: track)
                                    })
                                    .transition(.fade)
                                }
                            }
                            
                        }
                        .padding()
                        .animation(.easeInOut)
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 20) {
                            ForEach(filteredSounds) { sound in
                                SoundButton(sound: sound, audioMixer: audioMixer)
                            }
                        }
                        .padding()
                        .animation(.easeInOut)
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
            VStack {
                Spacer()
                
                CollapsibleControlPanel(audioMixer: audioMixer, isRelaxingMusicViewPresented: $isRelaxingMusicViewPresented,
                                        isSavedViewPresented: $isSaveCombinationViewPresented)
                .padding()
                
            }
        }
        .sheet(isPresented: $isRelaxingMusicViewPresented) {
          
            RelaxingMusicView()
        }
        .fullScreenCover(isPresented: $isShowAlarmViewPresented) {
            SetAlarmView()
                
        }
        
        .sheet(isPresented: $isSaveCombinationViewPresented) {
            SleepMixView(sounds: $audioMixer.selectedSounds)
                .presentationBackground(Color.clear)
                .presentationBackgroundInteraction(.disabled)
        }
        .onAppear {
            Task {
                try await TracklistManager.shared.fetchAllTracklists()
            }
        }
       
    }
    
    private func delete(soundMix: SoundMix) {
           withAnimation {
               SoundMixManager.shared.removeCombination(soundMix: soundMix)
           }
    }
    
}

struct SoundButton: View {
    let sound: Sound
    @ObservedObject var audioMixer: AudioMixer
    
    var isHighlighted: Bool {
        audioMixer.selectedSounds.contains(where: { $0.name == sound.name })
    }
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        
        
        
        ZStack {
//            LinearGradient(
//                gradient: Gradient(colors: isHighlighted ? gradientColorsBasedOnOffset() : [Color.gray.opacity(0.3), Color.gray.opacity(0.1)]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .frame(width: 80, height: min(100 + dragOffset.height, 100))
                        
            VStack {
                Spacer()
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: isHighlighted ? [Color.purple.opacity(0.6), Color.gray.opacity(0.1)] : [Color.gray.opacity(0.3), Color.gray.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: isHighlighted ? min(100 - dragOffset.height, 100) : 100)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                
                    
            }
            Button(action: {
                //MARK: Toggle highlight on button press
                if isHighlighted {
                    // Remove the sound when unselected
                    removeSound(sound: sound.audioFile ?? "")
                    Analytics.logEvent("sound_removed", parameters: [
                        "sound_name": sound.name,
                    ])
                } else {
                    // Play the sound when selected
                    playSound(sound: sound.audioFile ?? "")
                    Analytics.logEvent("sound_selected", parameters: [
                        "sound_name": sound.name,
                    ])
                }
            }) {
                VStack(spacing: 10) {
                    Image(systemName: sound.icon) // Replace with your custom icons if needed
                        .font(.system(size: 20))
                        .foregroundColor(isHighlighted ? .white : .gray) // Highlight color on press
                    Text(sound.name)
                        .foregroundColor(isHighlighted ? .white : .gray)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                }
                .frame(width: 80, height: 100)
                .cornerRadius(12)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            self.dragOffset = CGSize(width: 0, height: gesture.translation.height)
                        }
                        .onEnded { _ in
                            // Optionally, add logic to snap back or limit movement
                        }
                )
            }
        }
        .frame(height: 100)
    }
    
    func gradientColorsBasedOnOffset() -> [Color] {
        let offsetFactor = dragOffset.height / 300 // Adjust the divisor to control sensitivity
        let startColor = Color.purple.opacity(0.7 - Double(offsetFactor)) // Start color becomes darker as you drag
        let endColor = Color.blue.opacity(0.7 + Double(offsetFactor)) // End color becomes lighter as you drag
        
        return [startColor, endColor]
    }
    
    //MARK:  Function to trigger sound
    func playSound(sound: String) {
        if audioMixer.isPlaySaved {
            audioMixer.resetMixedAudio()
        }
        audioMixer.loadAudioFile(sound)
        audioMixer.selectedSounds.append(self.sound)
        // Play the sound using AudioMixer
        audioMixer.playMixedAudio()
    }
    
    //MARK:  Function to remove sound
    func removeSound(sound: String) {
        // Remove the sound from the AudioMixer
        audioMixer.removeAudioFile(sound)
        audioMixer.selectedSounds.removeAll { sound1 in
            return sound1.id == self.sound.id
        }
    }
    
}

struct ZenMusicView_Previews: PreviewProvider {
    static var previews: some View {
        ZenMusicView()
    }
}
