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
    private var listener: ListenerRegistration?
    private let groupUserDefaults = UserDefaults(suiteName: "group.vn.cyme.SleepMusic")
      
    private init() {}
    
    func addTracklistObserver(completion: @escaping () -> Void) {
        // Start listening to the trackLists collection, ordered by rating and viewCount
        listener = db.collection("trackLists")
            .order(by: "rating", descending: false)
            .addSnapshotListener { (snapshot, error) in
                guard let documents = snapshot?.documents else {
                    print("Error fetching documents: \(String(describing: error))")
                    return
                }
                
                // Clear previous data
                self.tracklists.removeAll()
                self.allTracks.removeAll()
                
                let dispatchGroup = DispatchGroup() // Create a Dispatch Group to track loading completion
                
                var index = 0
                for document in documents {
                    if var tracklist = try? document.data(as: Tracklist.self) {
                        tracklist.id = document.documentID
                        tracklist.idShow = index
                        
                        // Enter the Dispatch Group for each tracklist document
                        dispatchGroup.enter()
                        
                        // Fetch tracks for each tracklist document
                        self.db.collection("trackLists").document(document.documentID).collection("tracks").getDocuments { (snapshot, error) in
                            guard let tracksSnapshot = snapshot else {
                                print("Error fetching tracks: \(String(describing: error))")
                                dispatchGroup.leave() // Leave group even if error occurs
                                return
                            }
                            
                            // Decode each track and append to the tracks array
                            let tracks: [Track] = tracksSnapshot.documents.compactMap { doc in
                                var track = try? doc.data(as: Track.self)
                                track?.id = doc.documentID
                                track?.tracklistID = document.documentID
                                track?.nameOfTracklist = tracklist.title
                                return track
                            }
                            tracklist.tracks = tracks
                            
                            // Append tracks to allTracks array
                            self.allTracks.append(contentsOf: tracks)
                            self.tracklists.append(tracklist)
                            
                            // Leave the Dispatch Group after tracks are loaded
                            dispatchGroup.leave()
                        }
                        index += 1
                    }
                }
                
                // Notify when all tasks in the Dispatch Group are complete
                dispatchGroup.notify(queue: .main) {
                    completion() // All tracklists and their tracks are loaded
                }
            }
    }
    
    func fetchAndSaveLikedTracks()  throws {
        // Fetch liked tracks from Firestore
        
        // Save to UserDefaults
        do {
            let encodedTracks = try JSONEncoder().encode(allTracks)
            groupUserDefaults?.set(encodedTracks, forKey: "likedTracks")
            
            let encodedTracklists = try JSONEncoder().encode(tracklists)
            groupUserDefaults?.set(encodedTracklists, forKey: "tracklists")
            
        } catch {
            print("Failed to encode liked tracks: \(error)")
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
    
    func getTracklist(by idTrack: String) -> Tracklist? {
        guard let track = allTracks.filter({ $0.id == idTrack }).first else { return nil }
        guard let trackList = tracklists.filter({ $0.id == track.tracklistID }).first else { return nil }
        return trackList
    }
    
    func getTracks(by id: String) -> [Track]? {
        guard let selectedID = selectedTracklist?.id else { return nil}
        return allTracks.filter { $0.tracklistID == selectedID }
    }
    
    
    func fetchTracklist() async throws {
        // Local collections to store data
        var localTracklists: [Tracklist] = []
        var localAllTracks: [Track] = []

        // Fetch all tracklist documents
        let tracklistsSnapshot = try await db.collection("trackLists").getDocuments()
        let now = Date()
        
        // Use a throwing task group to fetch tracks concurrently
        try await withThrowingTaskGroup(of: Tracklist?.self) { group in
            
            for document in tracklistsSnapshot.documents {
                group.addTask {
                    var tracklist = try? document.data(as: Tracklist.self)
                    tracklist?.id = document.documentID

                    
                    // Fetch associated tracks
                    let tracksSnapshot = try await self.db.collection("trackLists").document(document.documentID).collection("tracks").getDocuments()
                    let tracks: [Track] = tracksSnapshot.documents.compactMap { doc in
                        var track = try? doc.data(as: Track.self)
                        track?.id = doc.documentID
                        track?.tracklistID = document.documentID
                        track?.nameOfTracklist = tracklist?.title
                        return track
                    }
                    tracklist?.tracks = tracks
                    
                    return tracklist
                }
            }

            // Collect results from the task group
            for try await tracklist in group {
                if let tracklist = tracklist {
                    localTracklists.append(tracklist)
                    localAllTracks.append(contentsOf: tracklist.tracks ?? [])
                }
            }
        }

        // Update properties on the main thread
        DispatchQueue.main.async {
            self.tracklists = localTracklists.sorted { $0.rating ?? 0 > $1.rating ?? 0 }
            self.allTracks = localAllTracks
        }
        print("total loaded time loaded : \(Date().timeIntervalSince1970 - now.timeIntervalSince1970)")
        // Save liked tracks in the background
        DispatchQueue.global().async {
            do {
                try self.fetchAndSaveLikedTracks()
            } catch {
                print("Failed to save liked tracks: \(error)")
            }
        }
    }
    
    func likeTracklist(_ tracklistID: String) {
        var likedTracklistIDs = groupUserDefaults?.array(forKey: "likedTracklists") as? [String] ?? []
        if !likedTracklistIDs.contains(tracklistID) {
            likedTracklistIDs.append(tracklistID)
            groupUserDefaults?.set(likedTracklistIDs, forKey: "likedTracklists")
        }
    }

    func unlikeTracklist(_ tracklistID: String) {
        var likedTracklistIDs = groupUserDefaults?.array(forKey: "likedTracklists") as? [String] ?? []
        if let index = likedTracklistIDs.firstIndex(of: tracklistID) {
            likedTracklistIDs.remove(at: index)
            groupUserDefaults?.set(likedTracklistIDs, forKey: "likedTracklists")
        }
    }

    func isTracklistLiked(_ tracklistID: String) -> Bool {
        let likedTracklistIDs = groupUserDefaults?.array(forKey: "likedTracklists") as? [String] ?? []
        return likedTracklistIDs.contains(tracklistID)
    }

}
