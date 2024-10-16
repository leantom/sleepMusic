//
//  TracklistManager.swift
//  SleepMusic
//
//  Created by QuangHo on 16/10/24.
//

import FirebaseFirestore

class TracklistManager:ObservableObject {
    
    static let shared = TracklistManager()
    private let db = Firestore.firestore()
    @Published var tracklists: [Tracklist] = []
    @Published var tracks: [Track] = []
    @Published var allTracks: [Track] = []
    @Published var selectedTracklist: Tracklist?
    private init() {}
    
    // Function to fetch a tracklist and its tracks using async/await
    func fetchTracklist(tracklistID: String) async throws {
        let db = Firestore.firestore()
        let tracklistRef = db.collection("trackLists").document(tracklistID)

        // Step 1: Fetch the tracklist document asynchronously
        let documentSnapshot = try await tracklistRef.getDocument()

        // Step 2: Decode the tracklist from the document snapshot
        let tracklist = try documentSnapshot.data(as: Tracklist.self)
        
        // Step 3: Fetch the tracks from the "tracks" subcollection asynchronously
        let tracksSnapshot = try await tracklistRef.collection("tracks").getDocuments()
        
        // Step 4: Decode the tracks from the snapshot
        let tracks: [Track] = tracksSnapshot.documents.compactMap { doc in
            return try? doc.data(as: Track.self)
        }
        
        self.tracklists.append(tracklist)
        self.tracks.append(contentsOf: tracks)
    }
    
    func fetchAllTracklists() async throws {
            let tracklistCollection = db.collection("trackLists")
            
            // Step 1: Fetch all tracklists
            let tracklistsSnapshot = try await tracklistCollection.getDocuments()
            
            // Clear previous data
        DispatchQueue.main.async {
            self.tracklists.removeAll()
            self.allTracks.removeAll()
        }
            
            
            // Step 2: For each tracklist, fetch the tracks subcollection
            for document in tracklistsSnapshot.documents {
                // Decode the tracklist
                if let tracklist = try? document.data(as: Tracklist.self) {
                    // Append the tracklist to the tracklists array
                    DispatchQueue.main.async {
                        self.tracklists.append(tracklist)
                    }
                    
                    // Fetch the tracks for this tracklist
                    let tracksSnapshot = try await tracklistCollection.document(document.documentID).collection("tracks").getDocuments()
                    
                    // Decode the tracks and assign tracklistID
                    let tracks: [Track] = tracksSnapshot.documents.compactMap { doc in
                        var track = try? doc.data(as: Track.self)
                        track?.tracklistID = document.documentID // Assign the tracklistID
                        return track
                    }
                    DispatchQueue.main.async {
                        self.allTracks.append(contentsOf: tracks)
                    }
                    
                }
            }
        }
    
    
    
}
