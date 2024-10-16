//
//  SoundMixView.swift
//  SleepMusic
//
//  Created by QuangHo on 16/10/24.
//

import SwiftUI

struct SaveCombinationView: View {
    @Binding var isPresented: Bool
    @ObservedObject var audioMixer: AudioMixer
    @ObservedObject var soundMixManager = SoundMixManager.shared
    
    @State private var combinationName: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Save Combination")
                .font(.title)
            TextField("Combination Name", text: $combinationName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .padding()
                Button("Save") {
                    saveCombination()
                    isPresented = false
                }
                .padding()
            }
        }
        .padding()
    }
    
    func saveCombination() {
//        let selectedSounds = $audioMixer.loadedSounds
//        let newCombination = SoundMix(name: combinationName, sounds: selectedSounds, dateSaved: Date())
//        soundMixManager.addCombination(newCombination)
    }
}

struct WrapperSoundCombine: View {
    @State var isPresented: Bool = false
    var body: some View {
        SaveCombinationView(isPresented: $isPresented, audioMixer: AudioMixer.shared)
    }
}

#Preview {
    WrapperSoundCombine()
}
