//
//  RelaxingMusicView.swift
//  MusicSleep
//
//  Created by QuangHo on 13/10/24.
//

import SwiftUI

struct RelaxingMusicView: View {
    
    
    @State var isPlaying: Bool = false
    @ObservedObject var tracklistManager = TracklistManager.shared
    @State var selectedTracklist: Tracklist?
    @Environment(\.dismiss) var dismiss
    @ObservedObject var objectState: UIStateModel = UIStateModel()
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [.purple, .black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            
            VStack {
                VStack {
                    HStack {
                        ZStack {
                            Text("RELAXING ZEN MUSIC")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.top)
                            HStack {
                                Button {
                                   dismiss()
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 20))
                                        .frame(width: 35, height: 35)
                                        .foregroundColor(.white)
                                        .background(Color(red: 0.104, green: 0.082, blue: 0.243))
                                        .clipShape(Circle())
                                        .shadow(color: .gray, radius: 5, x: 2, y: 2)
                                }
                                .padding()
                                Spacer()
                            }
                        }
                    }
                }
                // Album Art Section
                SnapCarousel(tracklists: tracklistManager.tracklists, selectedTracklist: $selectedTracklist)
                    .environmentObject(objectState)
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.vertical, 20)
                    
                // Control Buttons
                MediaControlView()
                    .frame(height: 88)
                ScrollView(.vertical, showsIndicators: false) {
                    HStack {
                        HStack(spacing: 10) {
                            Image(systemName: "music.note")
                                .foregroundColor(.black)
                                .frame(width: 20)
                                .background(Color.white)
                                .cornerRadius(5)
                            if let selectedTracklist = selectedTracklist,
                               let songs = selectedTracklist.numberOfTracks {
                                Text("\(songs) songs")
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                            }
                            
                        }
                        
                        Spacer()
                        if let selectedTracklist = selectedTracklist {
                            Text(formatSecondsToHoursMinutes(selectedTracklist.totalDuration))
                                .foregroundColor(.white)
                                .font(.subheadline)
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)
                    if let _ = selectedTracklist {
                        VStack(spacing: 10) {
                            ForEach(filteredTracks) { track in
                                SongRow(track: track)
                            }
                        }
                        .padding()
                        .animation(.easeInOut)
                    } else {
                        // Optional: Placeholder when no tracklist is selected
                        Text("Select a tracklist to view tracks")
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                }
                .padding(.top)
            }
            
            // Top Title
            
        }
        .onAppear {
            Task {
                try await tracklistManager.fetchAllTracklists()
                selectedTracklist = tracklistManager.tracklists.first
                AudioPlayer.shared.setTracks(filteredTracks)
            }
        }
        .onChange(of: objectState.activeCard) { oldTracklist, newTracklist in
                    // Perform any additional actions when selectedTracklist changes
            selectedTracklist = tracklistManager.tracklists[newTracklist]
            AudioPlayer.shared.setTracks(filteredTracks)
        }
    }
    
    // Computed property to filter tracks by selectedTracklist
    private var filteredTracks: [Track] {
        guard let selectedID = selectedTracklist?.id else { return [] }
        return tracklistManager.allTracks.filter { $0.tracklistID == selectedID }
    }
}

struct SongRow: View {
    var track: Track
    @State var isPlaying: Bool = false
    // Observe the shared AudioPlayer
    @ObservedObject var audioPlayer = AudioPlayer.shared
        
    var body: some View {
        HStack {
            // Artwork Image (if available)
            if let artworkURL = track.artWorkURL, let url = URL(string: artworkURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                // Placeholder image
                Image("img_1")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
                    .background(Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            // Song title and duration
            VStack(alignment: .leading) {
                Text(track.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Duration: \(trackDurationString(duration: track.duration))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.3))
                .font(.system(size: 15))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .shadow(radius: 5)
        )
        .overlay(content: {
            if audioPlayer.currentTrack  == track {
                HStack {
                    Spacer()
                    LoadingView()
                        .frame(width: 150)
                }
            }
        })
        .padding(.horizontal)
        .onTapGesture {
            isPlaying.toggle()
            AudioPlayer.shared.playTrack(for: track)
        }
    }

    // Helper function to format duration
    private func trackDurationString(duration: Int) -> String {
        let minutes = duration / 60
        let seconds = duration % 60
        return "\(minutes)m \(seconds)s"
    }
}


#Preview {
    RelaxingMusicView()
}