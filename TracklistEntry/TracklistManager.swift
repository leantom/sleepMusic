//
//  TracklistManager.swift
//  TracklistEntryExtension
//
//  Created by QuangHo on 31/10/24.
//

import Foundation
import FirebaseFirestore
import Firebase

class TracklistManager:ObservableObject {
    
    static let shared = TracklistManager()
    private let db = Firestore.firestore()
    @Published var tracklists: [Tracklist] = []
    @Published var tracks: [Track] = []
    @Published var allTracks: [Track] = []
    @Published var selectedTracklist: Tracklist?
    private var listener: ListenerRegistration? // Holds reference to the listener to remove later
    private let groupUserDefaults = UserDefaults(suiteName: "group.vn.cyme.SleepMusic") // Use your App Group identifier
    
    init() {
        
    }
    
    func likedTracks() -> [Track] {
        // Check if there's valid data for "likedTracks" in UserDefaults
        
        guard let tracklists = groupUserDefaults?.data(forKey: "tracklists"), !tracklists.isEmpty else {
            print("No data found or data is empty for key 'likedTracks'")
            return []
        }
        
        guard let savedData = groupUserDefaults?.data(forKey: "likedTracks"), !savedData.isEmpty else {
            print("No data found or data is empty for key 'likedTracks'")
            return []
        }
        
        do {
            // Try decoding the data
            let decodeTrack = try JSONDecoder().decode([Track].self, from: savedData)
            return decodeTrack
        } catch {
            print("Error decoding liked tracks: \(error)")
            
            // Optionally clear the corrupted data to prevent repeated errors
            groupUserDefaults?.removeObject(forKey: "likedTracks")
            return []
        }
    }
    
    func getTracklist(by idTrack: String) -> Tracklist? {
        guard let track = allTracks.filter({ $0.id == idTrack }).first else { return nil }
        guard let trackList = tracklists.filter({ $0.id == track.tracklistID }).first else { return nil }
        return trackList
    }
}
