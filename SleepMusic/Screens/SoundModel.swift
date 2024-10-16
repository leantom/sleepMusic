//
//  SoundModel.swift
//  MusicSleep
//
//  Created by QuangHo on 13/10/24.
//

import SwiftUI

struct Sound: Identifiable, Codable {
    let id = UUID() // Unique ID for each sound
    let name: String
    let icon: String
    let audioFile: String? // Optional: Add the sound file name if you have it
    
    // Initialize sound with name and icon
    init(name: String, icon: String, audioFile: String? = nil) {
        self.name = name
        self.icon = icon
        self.audioFile = audioFile
    }
}

struct SoundCategory: Identifiable {
    let id = UUID() // Unique ID for each category
    let name: String // Category name (e.g., "Nature", "White Noise", etc.)
    let sounds: [Sound] // List of Sound objects belonging to this category
    
    // Initialize with a category name and a list of sounds
    init(name: String, sounds: [Sound]) {
        self.name = name
        self.sounds = sounds
    }
    
    // Function to get sounds for each specific category
    func getSounds() -> [Sound] {
        return sounds
    }
    
    // Static categories for each type
    static let natureSounds = SoundCategory(name: "Nature Sounds", sounds: [
        Sound(name: "Rainfall", icon: "cloud.rain", audioFile: "rainfall"),
        Sound(name: "Ocean Waves", icon: "waveform", audioFile: "ocean_waves"),
        Sound(name: "Forest Sounds", icon: "leaf", audioFile: "forest_sounds"),
        Sound(name: "Water Stream", icon: "drop.fill", audioFile: "water_stream"),
        Sound(name: "Wind", icon: "wind", audioFile: "wind")
    ])
    
    static let whitePinkNoise = SoundCategory(name: "White and Pink Noise", sounds: [
        Sound(name: "White Noise", icon: "waveform.path.ecg", audioFile: "white_noise"),
        Sound(name: "Pink Noise", icon: "waveform.path", audioFile: "pink_noise"),
        Sound(name: "Brown Noise", icon: "waveform.path.ecg.rectangle", audioFile: "brown_noise")
    ])
    
    static let instrumentalMusic = SoundCategory(name: "Instrumental Music", sounds: [
        Sound(name: "Soft Piano", icon: "pianokeys", audioFile: "soft_piano"),
        Sound(name: "Acoustic Guitar", icon: "guitars", audioFile: "acoustic_guitar"),
        Sound(name: "Harp", icon: "moon.dust", audioFile: "harp"),
        Sound(name: "Ambient Pads", icon: "cloud", audioFile: "ambient_pads")
    ])
    
    static let binauralBeats = SoundCategory(name: "Binaural Beats", sounds: [
        Sound(name: "Delta Binaural Beats", icon: "circle.grid.cross", audioFile: "delta_beats"),
        Sound(name: "Theta Binaural Beats", icon: "circle", audioFile: "delta_beats")
    ])
    
    static let meditationSounds = SoundCategory(name: "Meditation Sounds", sounds: [
        Sound(name: "Tibetan Singing Bowls", icon: "circle.hexagonpath.fill", audioFile: "tibetan_bowls"),
        Sound(name: "Chimes", icon: "bell", audioFile: "chimes")
    ])
    
    static let allSounds = SoundCategory(name: "All", sounds: [])
    
    // Function to get all sounds
    static func getAllSounds() -> [Sound] {
        return natureSounds.sounds + whitePinkNoise.sounds + instrumentalMusic.sounds + binauralBeats.sounds + meditationSounds.sounds
    }
    
    static func getCategories() -> [SoundCategory] {
        return [allSounds, natureSounds, whitePinkNoise, instrumentalMusic, binauralBeats, meditationSounds]
    }
}
