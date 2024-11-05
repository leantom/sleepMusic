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
                
                SnapCarousel(tracklists: tracklistManager.tracklists)
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
                            if let selectedTracklist = tracklistManager.selectedTracklist,
                               let songs = selectedTracklist.numberOfTracks {
                                Text("\(songs) songs")
                                    .foregroundColor(.white)
                                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                            }
                            
                        }
                        
                        Spacer()
                        if let selectedTracklist = tracklistManager.selectedTracklist {
                            Text(formatSecondsToHoursMinutes(selectedTracklist.totalDuration))
                                .foregroundColor(.white)
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)
                    
                    if let selectedTracklist = tracklistManager.selectedTracklist ,
                       let tracks = selectedTracklist.tracks {
                        VStack(spacing: 10) {
                            ForEach(tracks) { track in
                                SongRow(track: track, listTrack: tracks)
                            }
                        }
                        .padding()
                        .animation(.easeInOut)
                    } else {
                        // Optional: Placeholder when no tracklist is selected
                        Text("Select a tracklist to view tracks")
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                            .padding()
                        ProgressView(value: 0.5)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color.purple))
                            .padding(.horizontal, 60)
                            .padding(.top, 20)
                    }
                    
                }
                .padding(.top)
                
            }
            
            // Top Title
            
        }
        .onAppear {
            Task {
                if tracklistManager.tracklists.isEmpty {
                    try await tracklistManager.fetchTracklist()
                    tracklistManager.selectedTracklist = tracklistManager.tracklists.first
                }
                
                if AppSetting.shared.isOpenFromWidget {
                    if let tracklist = tracklistManager.getTracklist(by: AppSetting.shared.trackId),
                       let tracks = tracklist.tracks,
                       let index = tracklistManager.tracklists.firstIndex(of: tracklist) {
                        AudioPlayer.shared.setTracks(tracks)
                        objectState.activeCard = index
                    }
                } else {
                    if AudioPlayer.shared.isPlaying {
                        return
                    }
                    if let selectedTracklist = tracklistManager.selectedTracklist ,
                       let tracks = selectedTracklist.tracks {
                        AudioPlayer.shared.setTracks(tracks)
                    }
                }
            }
        }
        .onDisappear(perform: {
            AppSetting.shared.isOpenFromWidget = false
        })
        .onChange(of: objectState.activeCard) { newTracklist in
                    // Perform any additional actions when selectedTracklist changes
            // Ensure the index is within bounds
            guard newTracklist >= 0 && newTracklist < tracklistManager.tracklists.count else { return }
                
                
            tracklistManager.selectedTracklist = tracklistManager.tracklists[newTracklist]
            if let id = tracklistManager.tracklists[newTracklist].id {
                tracklistManager.incrementViewCount(for: id)
            }
            
        }
    }
    
    // Computed property to filter tracks by selectedTracklist
    private var filteredTracks: [Track] {
        guard let selectedID = tracklistManager.selectedTracklist?.id else { return [] }
        return tracklistManager.allTracks.filter { $0.tracklistID == selectedID }
    }
}

struct SongRow: View {
    var track: Track
    var listTrack: [Track]
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
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Text("Duration: \(trackDurationString(duration: track.duration))")
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
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
            AudioPlayer.shared.setTracks(listTrack)
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
