//
//  SongInfoView.swift
//  MusicSleep
//
//  Created by QuangHo on 13/10/24.
import SwiftUI

struct SoundMixRow: View {
    var soundMix: SoundMix
    @State var isPlaying: Bool = false
    // Observe the shared AudioPlayer
    @ObservedObject var audioPlayer = AudioPlayer.shared
    var onDelete: () -> Void
    var body: some View {
        HStack {
            // Artwork Image (if available)
            Image("img_1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
                .background(Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            // Song title and duration
            VStack(alignment: .leading) {
                Text(soundMix.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Sounds: \(soundMix.sounds.count)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button {
                //MARK: -- delete item
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.white.opacity(0.3))
                    .font(.system(size: 15))
            }
            .padding()

            
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .shadow(radius: 5)
        )
        .padding(.horizontal)
        .onTapGesture {
            isPlaying.toggle()
            withAnimation {
                AudioMixer.shared.resetMixedAudio()
                AudioMixer.shared.loadAudioFilesSound(soundMix.sounds)
                AudioMixer.shared.playMixedAudio()
                AudioMixer.shared.isPlaySaved = true
            }
        }
    }

}

