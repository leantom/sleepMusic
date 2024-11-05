//
//  TracklistModel.swift
//  SleepMusic
//
//  Created by QuangHo on 16/10/24.
//

import Foundation
import FirebaseFirestore

import Foundation

struct Tracklist: Identifiable, Codable, Equatable {
    var id: String?                   // Firestore document ID
    let title: String                 // Title of the tracklist
    let description: String           // Description of the tracklist
    let coverImageURL: String?        // URL for the cover image
    let totalDuration: Int            // Total duration of all tracks in the tracklist
    let numberOfTracks: Int?          // Number of tracks in the tracklist
    var rating: Double?               // Rating of the tracklist
    var viewCount: Int?               // View count of the tracklist
    var tracks: [Track]?              // Array of tracks
    var idShow: Int = 0               // Additional ID for display purposes

    // Custom initializer to decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        coverImageURL = try container.decodeIfPresent(String.self, forKey: .coverImageURL)
        totalDuration = try container.decode(Int.self, forKey: .totalDuration)
        numberOfTracks = try container.decodeIfPresent(Int.self, forKey: .numberOfTracks)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        viewCount = try container.decodeIfPresent(Int.self, forKey: .viewCount)
        tracks = try container.decodeIfPresent([Track].self, forKey: .tracks)
        idShow = 0
    }

    // Method to encode the struct back to JSON
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encodeIfPresent(coverImageURL, forKey: .coverImageURL)
        try container.encode(totalDuration, forKey: .totalDuration)
        try container.encodeIfPresent(numberOfTracks, forKey: .numberOfTracks)
        try container.encodeIfPresent(rating, forKey: .rating)
        try container.encodeIfPresent(viewCount, forKey: .viewCount)
        try container.encodeIfPresent(tracks, forKey: .tracks)
        try container.encode(idShow, forKey: .idShow)
    }

    // CodingKeys to match the property names
    private enum CodingKeys: String, CodingKey {
        case id, title, description, coverImageURL, totalDuration, numberOfTracks, rating, viewCount, tracks, idShow
    }
}

import Foundation

struct Track: Identifiable, Codable, Equatable {
    var id: String?                 // Firestore document ID
    let name: String                // Name of the track
    let duration: Int               // Duration of the track in seconds
    let audioFileURL: String        // URL of the audio file
    let trackNumber: Int            // The order number of the track in the tracklist
    let artWorkURL: String?         // URL for the artwork of the track
    var tracklistID: String?        // ID of the associated tracklist
    var nameOfTracklist: String?    // Name of the associated tracklist

    // Custom initializer to decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        duration = try container.decode(Int.self, forKey: .duration)
        audioFileURL = try container.decode(String.self, forKey: .audioFileURL)
        trackNumber = try container.decode(Int.self, forKey: .trackNumber)
        artWorkURL = try container.decodeIfPresent(String.self, forKey: .artWorkURL)
        tracklistID = try container.decodeIfPresent(String.self, forKey: .tracklistID)
        nameOfTracklist = try container.decodeIfPresent(String.self, forKey: .nameOfTracklist)
    }

    // Method to encode the struct back to JSON
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(duration, forKey: .duration)
        try container.encode(audioFileURL, forKey: .audioFileURL)
        try container.encode(trackNumber, forKey: .trackNumber)
        try container.encodeIfPresent(artWorkURL, forKey: .artWorkURL)
        try container.encodeIfPresent(tracklistID, forKey: .tracklistID)
        try container.encodeIfPresent(nameOfTracklist, forKey: .nameOfTracklist)
    }

    // CodingKeys to match the property names
    private enum CodingKeys: String, CodingKey {
        case id, name, duration, audioFileURL, trackNumber, artWorkURL, tracklistID, nameOfTracklist
    }
}
