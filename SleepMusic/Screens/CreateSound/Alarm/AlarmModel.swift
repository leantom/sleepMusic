//
//  AlarmModel.swift
//  SleepMusic
//
//  Created by QuangHo on 22/10/24.
//
import Foundation

struct AlarmSound: Identifiable {
    let id = UUID() // Unique ID for each alarm sound
    let name: String
    let fileName: String
    let duration: Int // Duration of the sound in seconds
    
    var fileURL: URL? {
        // Get the URL of the file from the bundle
        return Bundle.main.url(forResource: fileName, withExtension: "mp3") // assuming mp3 format
    }
}
