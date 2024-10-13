//
//  RelaxingMusicView.swift
//  MusicSleep
//
//  Created by QuangHo on 13/10/24.
//

import SwiftUI

struct RelaxingMusicView: View {
    
    let songs = [
            ("Lantern Festival", "Gloria", "img_1"),
            ("Magical City", "Regina", "img_2"),
            ("Deep Sleep", "Jenny", "img_3"),
            ("Tropical Vibes", "Alene", "img_4")
        ]
    var totalSongs: String = "12 Songs"
    var duration: String = "1 hr 32 min"
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [.purple, .black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    // Top Title
                    Text("RELAXING ZEN MUSIC")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    // Album Art Section
                    CarouselView()
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.vertical, 20)
                    
                    // Control Buttons
                    MediaControlView()
                    .padding(.bottom, 20)
                    
                    HStack {
                        HStack(spacing: 5) {
                            Image(systemName: "music.note")
                                .foregroundColor(.white)
                            
                            Text(totalSongs)
                                .foregroundColor(.white)
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        Text(duration)
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)
                    // Song List Section
                    VStack(spacing: 10) {
                        ForEach(songs, id: \.0) { song in
                            SongRow(songTitle: song.0, artist: song.1, artwork: song.2)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct SongRow: View {
    var songTitle: String
    var artist: String
    var artwork: String
    
    var body: some View {
            HStack {
                // Artwork Image
                Image(artwork)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                // Song title and artist
                VStack(alignment: .leading) {
                    Text(songTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(artist)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.2)) // Adjust the background opacity and color
                    .shadow(radius: 5) // Add shadow to mimic depth
            )
            .padding(.horizontal)
        }
}

#Preview {
    RelaxingMusicView()
}
