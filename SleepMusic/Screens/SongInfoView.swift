//
//  SongInfoView.swift
//  MusicSleep
//
//  Created by QuangHo on 13/10/24.
import SwiftUI

struct SongInfoView: View {
    var totalSongs: String = "12 Songs"
    var duration: String = "1 hr 32 min"
    
    var body: some View {
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
    }
}

struct SongInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SongInfoView()
            .preferredColorScheme(.dark) // Dark mode preview
    }
}

