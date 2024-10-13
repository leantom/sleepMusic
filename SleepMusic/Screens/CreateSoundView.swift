//
//  CreateSoundView.swift
//  MusicSleep
//
//  Created by QuangHo on 13/10/24.
//

import SwiftUI

struct ZenMusicView: View {
    
    let sounds: [Sound] = [
        Sound(name: "Air Flow", icon: "wind"), // Replace with actual SF symbols or custom icons
        Sound(name: "Audio", icon: "waveform.path.ecg"),
        Sound(name: "Bird", icon: "bird"),
        Sound(name: "Breeze", icon: "wind"),
        Sound(name: "Creek", icon: "drop"),
        Sound(name: "Flood", icon: "cloud.rain.fill"),
        Sound(name: "Guitar", icon: "guitars"),
        Sound(name: "Harp", icon: "music.note"),
        Sound(name: "Noise", icon: "speaker.wave.3.fill"),
        Sound(name: "Play", icon: "play.circle.fill"),
        Sound(name: "Rainfall", icon: "cloud.rain"),
        Sound(name: "Sea", icon: "waveform.path.ecg")
    ]
    
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
                        .opacity(0.2)
                }
            
            VStack {
                // Top Section: Foreground image and Upgrade button
                HStack {
                    Button(action: {
                        // Upgrade action
                    }) {
                        Image(systemName: "star.circle")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                   
                }
                Spacer()
                HStack(spacing: 0) {
                    // Sounds Button
                    Button(action: {
                        selectedTab = "Sounds"
                    }) {
                        Text("Sounds")
                            .font(.headline)
                            .foregroundColor(selectedTab == "Sounds" ? .white : .gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                selectedTab == "Sounds" ? Color.purple : Color.clear
                            )
                            .cornerRadius(20)
                    }
                    
                    Spacer().frame(width: 10)
                    
                    // Saved Button
                    Button(action: {
                        selectedTab = "Saved"
                    }) {
                        Text("Saved")
                            .font(.headline)
                            .foregroundColor(selectedTab == "Saved" ? .white : .gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                selectedTab == "Saved" ? Color.purple : Color.clear
                            )
                            .cornerRadius(20)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.2))
                )
                .padding(.horizontal)
                
              
                // Horizontal category selection
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(categories) { category in
                                Button(action: {
                                    // Update selected category
                                    selectedCategory = category.name
                                }) {
                                    Text(category.name)
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
                    // Sound Option Buttons
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 20) {
                        ForEach(filteredSounds) { sound in
                            SoundButton(sound: sound)
                        }
                    }
                    .padding()
                    Spacer()
                }
                .frame(height: 450)
                             
                Spacer()
                
                // Music Player Controls
                HStack(spacing: 20) {
                    // Pause Button
                    Button(action: {
                        // Pause action
                        print("Pause tapped")
                    }) {
                        Image(systemName: "pause.fill")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.purple)
                            .clipShape(Circle())
                    }
                    
                    // Additional Buttons
                    Button(action: {
                        // Some other action
                        print("Button 1 tapped")
                    }) {
                        Image(systemName: "rectangle.3.offgrid.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        // Another action
                        print("Button 2 tapped")
                    }) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    // Close Button
                    Button(action: {
                        // Close action
                        print("Close tapped")
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.4))
                )
                .padding(.horizontal, 30) // Adjust padding as needed
                
            }
        }
    }
}

struct SoundButton: View {
    let sound: Sound
    @State private var audioMixer: AudioMixer? = nil
    
    @State private var isHighlighted = false // State to track highlight status

    var body: some View {
        Button(action: {
            // Toggle highlight on button press
            isHighlighted.toggle()
            playSound(sound: sound.audioFile ?? "") // Play the sound when pressed
        }) {
            VStack {
                Image(systemName: sound.icon) // Replace with your custom icons if needed
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(isHighlighted ? .yellow.opacity(0.6) : .gray) // Highlight color on press
                Text(sound.name)
                    .foregroundColor(.white)
                    .font(.caption)
            }
            .frame(width: 80, height: 100)
            .background(isHighlighted ? Color.purple.opacity(0.7) : Color.gray.opacity(0.3)) // Background changes when highlighted
            .cornerRadius(12)
        }
    }
    
    // Function to trigger sound
    func playSound(sound: String) {
        if audioMixer == nil {
            // Initialize AudioMixer with the selected sound
            audioMixer = AudioMixer(audioFileNames: [sound])
        } else {
            // Add new sound to the mixer
            audioMixer?.loadAudioFile(sound)
        }
        
        // Play the sound using AudioMixer
        audioMixer?.playMixedAudio()
    }
}

struct ZenMusicView_Previews: PreviewProvider {
    static var previews: some View {
        ZenMusicView()
    }
}
