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
    private var listener: ListenerRegistration? // Holds reference to the listener to remove later
    
    private init() {}
    
    func addTracklistObserver() {
        // Start listening to the trackLists collection, ordered by rating and viewCount
        listener = db.collection("trackLists")
            .order(by: "rating", descending: true)
            .order(by: "views", descending: true)
            .addSnapshotListener { (snapshot, error) in
                guard let documents = snapshot?.documents else {
                    print("Error fetching documents: \(String(describing: error))")
                    return
                }
                
                // Clear previous data
                self.tracklists.removeAll()
                self.allTracks.removeAll()
                
                // Decode each tracklist document
                for document in documents {
                    if var tracklist = try? document.data(as: Tracklist.self) {
                        self.tracklists.append(tracklist)
                        
                        // Fetch tracks for each tracklist document
                        self.db.collection("trackLists").document(document.documentID).collection("tracks").getDocuments { (snapshot, error) in
                            guard let tracksSnapshot = snapshot else {
                                print("Error fetching tracks: \(String(describing: error))")
                                return
                            }
                            
                            // Decode each track and append to the tracks array
                            let tracks: [Track] = tracksSnapshot.documents.compactMap { doc in
                                var track = try? doc.data(as: Track.self)
                                track?.tracklistID = document.documentID
                                track?.nameOfTracklist = tracklist.title
                                return track
                            }
                            tracklist.tracks = tracks
                            // Append tracks to allTracks array
                            self.allTracks.append(contentsOf: tracks)
                        }
                    }
                }
            }
    }
    
    // Function to fetch a tracklist and its tracks using async/await
    func fetchAllTracklists() async throws {
        let tracklistCollection = db.collection("trackLists")
        
        // Step 1: Fetch all tracklists, ordered by rating and viewCount
        let tracklistsSnapshot = try await tracklistCollection
            .order(by: "views", descending: true)
            .getDocuments()
        
        self.tracklists.removeAll()
        self.allTracks.removeAll()
        
        // Step 2: For each tracklist, fetch the tracks subcollection
        for document in tracklistsSnapshot.documents {
            // Decode the tracklist
            if var tracklist = try? document.data(as: Tracklist.self) {
                // Append the tracklist to the tracklists array
               
                self.tracklists.append(tracklist)
                
                // Fetch the tracks for this tracklist, ordered by rating and viewCount
                let tracksSnapshot = try await tracklistCollection
                    .document(document.documentID)
                    .collection("tracks")
                    .getDocuments()
                
                // Decode the tracks and assign tracklistID
                let tracks: [Track] = tracksSnapshot.documents.compactMap { doc in
                    var track = try? doc.data(as: Track.self)
                    track?.tracklistID = document.documentID
                    track?.nameOfTracklist = tracklist.title
                    return track
                }
                tracklist.tracks = tracks
                DispatchQueue.main.async {
                    self.allTracks.append(contentsOf: tracks)
                }
                
                
            }
        }
    }
    
    func incrementViewCount(for tracklistID: String) {
        let tracklistRef = db.collection("trackLists").document(tracklistID)
        
        // Increment the "views" field by 1
        tracklistRef.updateData([
            "views": FieldValue.increment(Int64(1))
        ]) { error in
            if let error = error {
                print("Error incrementing view count: \(error)")
            } else {
                print("View count incremented successfully for tracklist \(tracklistID)")
            }
        }
    }
    
    func getTracks(by id: String) -> [Track] {
        guard let selectedID = selectedTracklist?.id else { return [] }
        return allTracks.filter { $0.tracklistID == selectedID }
    }
    
    
    func fetchTracklistNotSync(tracklistID: String) async throws {
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
    
    
    
    
    
}
