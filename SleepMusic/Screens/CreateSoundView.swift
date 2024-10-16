//
//  CreateSoundView.swift
//  MusicSleep
//
//  Created by QuangHo on 13/10/24.
//

import SwiftUI

struct ZenMusicView: View {
    @ObservedObject var soundMixManager = SoundMixManager.shared
    @State private var isSaveCombinationViewPresented = false
    @ObservedObject var audioMixer: AudioMixer = AudioMixer.shared
    let categories = SoundCategory.getCategories()
    
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
                
                HStack(spacing: 0) {
                        // Sounds Button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTab = "Sounds"
                               
                            }
                        }) {
                            ZStack {
                                Rectangle()
                                    .fill( selectedTab == "Sounds" ? Color.purple : Color.clear)
                                    .cornerRadius(20)
                                    .opacity(selectedTab == "Sounds" ? 1 : 0)
                                    .offset(x: selectedTab == "Sounds" ? 0 : 200)
                                
                                Text("Sounds")
                                    .font(.headline)
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
                                isSaveCombinationViewPresented.toggle()
                            }
                        }) {
                            ZStack {
                                Rectangle()
                                    .fill( selectedTab == "Saved" ? Color.purple : Color.clear)
                                    .cornerRadius(20)
                                    .opacity(selectedTab == "Saved" ? 1 : 0)
                                    .offset(x: selectedTab == "Saved" ? 0 : -200)
                                
                                Text("Saved")
                                    .font(.headline)
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
                    .padding(.top, 100)
                    .padding(.horizontal)
                    .frame(height: 126)
                
                Spacer()
                // Horizontal category selection
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(categories) { category in
                                Button(action: {
                                    // Update selected category
                                    withAnimation {
                                        selectedCategory = category.name
                                    }
                                    
                                }) {
                                    Text(category.name)
                                        .font(.system(size: 14, weight: .regular))
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
                    .padding()
                    // Sound Option Buttons
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 20) {
                        ForEach(filteredSounds) { sound in
                            SoundButton(sound: sound, audioMixer: audioMixer)
                        }
                    }
                    .padding()
                    .animation(.easeInOut)
                    Spacer()
                }
                .padding(.top, 30)
                Spacer()
                
                // Music Player Controls
                CollapsibleControlPanel(audioMixer: audioMixer, isRelaxingMusicViewPresented: $isRelaxingMusicViewPresented)
                    .padding()
                Spacer()
            }
            
        }
        .fullScreenCover(isPresented: $isRelaxingMusicViewPresented) {
            RelaxingMusicView()
        }
        .sheet(isPresented: $isSaveCombinationViewPresented) {
            SaveCombinationView(isPresented: $isSaveCombinationViewPresented, audioMixer: audioMixer)
        }
    }
}

struct SoundButton: View {
    let sound: Sound
    @ObservedObject var audioMixer: AudioMixer
    
    @State private var isHighlighted = false // State to track highlight status
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
                // Toggle highlight on button press
                isHighlighted.toggle()
                if isHighlighted {
                    // Play the sound when selected
                    playSound(sound: sound.audioFile ?? "")
                } else {
                    // Remove the sound when unselected
                    removeSound(sound: sound.audioFile ?? "")
                }
                
            }) {
                VStack(spacing: 10) {
                    Image(systemName: sound.icon) // Replace with your custom icons if needed
                        .font(.system(size: 20))
                        .foregroundColor(isHighlighted ? .white : .gray) // Highlight color on press
                    Text(sound.name)
                        .foregroundColor(.white)
                        .font(.caption)
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
    
    // Function to trigger sound
    func playSound(sound: String) {
        audioMixer.loadAudioFile(sound)
        
        // Play the sound using AudioMixer
        audioMixer.playMixedAudio()
    }
    
    // Function to remove sound
        func removeSound(sound: String) {
            // Remove the sound from the AudioMixer
            audioMixer.removeAudioFile(sound)
        }
    
}

struct ZenMusicView_Previews: PreviewProvider {
    static var previews: some View {
        ZenMusicView()
    }
}
