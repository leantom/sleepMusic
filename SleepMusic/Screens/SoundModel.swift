//
//  SoundModel.swift
//  MusicSleep
//
//  Created by QuangHo on 13/10/24.
//

import SwiftUI

struct Sound: Identifiable {
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
    let name: String // Category name (e.g., "Rain", "Water", etc.)
    let sounds: [Sound] // List of Sound objects belonging to this category
    
    // Initialize with a category name and a list of sounds
    init(name: String, sounds: [Sound]) {
        self.name = name
        self.sounds = sounds
    }
    
    
    static func getCategories() -> [SoundCategory] {
           return [
               SoundCategory(name: "All", sounds: [
                    Sound(name: "Air Flow", icon: "wind", audioFile: "waves_close_up"),
                    Sound(name: "Bird", icon: "bird", audioFile: "bird"),
                   Sound(name: "Guitar", icon: "guitars")
               ]),
               SoundCategory(name: "Rain", sounds: [
                   Sound(name: "Light Rain", icon: "cloud.drizzle.fill", audioFile: "rainfall"),
                   Sound(name: "Heavy Rain", icon: "cloud.heavyrain.fill", audioFile: "rainfall")
               ]),
               SoundCategory(name: "Water", sounds: [
                   Sound(name: "Creek", icon: "drop"),
                   Sound(name: "Sea", icon: "waveform.path.ecg")
               ]),
               SoundCategory(name: "Wind", sounds: [
                   Sound(name: "Breeze", icon: "wind"),
                   Sound(name: "Typhoon", icon: "tornado")
               ]),
               SoundCategory(name: "Instrument", sounds: [
                   Sound(name: "Guitar", icon: "guitars"),
                   Sound(name: "Piano", icon: "pianokeys.inverse", audioFile: "piano"),
                   Sound(name: "Harp", icon: "music.note")
               ])
           ]
       }
    func getSounds() -> [Sound] {
        switch name {
        case "Rain":
            return rainSounds
        case "Water":
            return waterSounds
        case "Instrument":
            return instrumentSounds
        case "Wind":
            return windSounds
        default:
            return forestSounds
        }
    }
    
     static func getAllSounds() -> [Sound] {
        rainSounds + waterSounds + windSounds + instrumentSounds + forestSounds
    }

    
}


let rainSounds = [
    Sound(name: "Light Rain", icon: "cloud.drizzle.fill", audioFile: "rainfall"),
    Sound(name: "Heavy Rain", icon: "cloud.heavyrain.fill", audioFile: "rainfall")
]

let waterSounds = [
    Sound(name: "Creek", icon: "drop", audioFile: "waves"),
    Sound(name: "Sea", icon: "waveform.path.ecg", audioFile: "waves_close_up")
]
 
let instrumentSounds = [
    Sound(name: "Creek", icon: "drop", audioFile: "piano"),
    Sound(name: "Sea", icon: "waveform.path.ecg", audioFile: "piano")
]

let windSounds = [
    Sound(name: "Creek", icon: "drop", audioFile: "bird.mp3"),
    Sound(name: "Sea", icon: "waveform.path.ecg", audioFile: "sea.mp3")
]

let forestSounds = [
    Sound(name: "Creek", icon: "drop", audioFile: "creek"),
    Sound(name: "Sea", icon: "waveform.path.ecg", audioFile: "sea")
]
