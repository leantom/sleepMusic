//
//  TracklistModel.swift
//  SleepMusic
//
//  Created by QuangHo on 16/10/24.
//

import Foundation
import FirebaseFirestore

// Tracklist model
struct Tracklist: Identifiable, Codable, Equatable {
    @DocumentID var id: String?             // Firestore document ID
    let title: String                       // Title of the tracklist
    let description: String                 // Description of the tracklist
    let coverImageURL: String?              // URL for the cover image
    let totalDuration: Int                  // Total duration of all tracks in the tracklist
    let numberOfTracks: Int?                // Total duration of all tracks in the tracklist
    var rating: Double?                 // Description of the tracklist
    var viewCount: Int?
    var tracks:[Track]?
}

// Track model
struct Track: Identifiable, Codable, Equatable {
    @DocumentID var id: String?             // Firestore document ID
    let name: String                        // Name of the track
    let duration: Int                       // Duration of the track in seconds
    let audioFileURL: String                // URL of the audio file
    let trackNumber: Int                    // The order number of the track in the tracklist
    let artWorkURL: String?
    var tracklistID: String? // Add this property
    var nameOfTracklist: String?
}
