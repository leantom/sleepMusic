//
//  AlarmModel.swift
//  SleepMusic
//
//  Created by QuangHo on 22/10/24.
//
import Foundation

struct AlarmSound: Identifiable {
    var id: String = UUID().uuidString
    let name: String // Display name of the sound
    var fileURL: URL?
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
        if let url = Bundle.main.url(forResource: id, withExtension: "WAV") {
            // Use `url` as the file URL for the alarm sound
            self.fileURL = url
        }
        
    }
}
