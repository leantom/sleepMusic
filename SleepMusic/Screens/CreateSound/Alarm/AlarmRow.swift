//
//  AlarmRow.swift
//  SleepMusic
//
//  Created by QuangHo on 22/10/24.
//
import SwiftUI

struct AlarmRow: View {
    var alarm: AlarmSound
    @State var isPlaying: Bool = false
    @ObservedObject var audioPlayer = AudioPlayer.shared

    var body: some View {
        HStack {
            // Placeholder for alarm sound icon or artwork
            Image("img_1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
                .background(Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // Alarm name and duration
            VStack(alignment: .leading) {
                Text(alarm.name)
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
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
        .padding(.horizontal)
        
    }
    
    // Helper function to format duration
    private func trackDurationString(duration: Int) -> String {
        let minutes = duration / 60
        let seconds = duration % 60
        return "\(minutes)m \(seconds)s"
    }
}

