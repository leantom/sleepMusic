//
//  AudioPlayer.swift
//  SleepMusic
//
//  Created by QuangHo on 16/10/24.
//

import AVFoundation
import Combine

class AudioPlayer: ObservableObject {
    static let shared = AudioPlayer()
    
    private var player: AVPlayer?
    @Published var isPlaying: Bool = false
    @Published var currentTrack: Track?
    private var tracks: [Track] = []
    private var currentIndex: Int = 0
    @Published var isShuffleEnabled: Bool = false
    @Published var isRepeatEnabled: Bool = false
    
    private init() {
        // Observe when the player finishes playing
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func configureAudioSession() {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    func setTracks(_ tracks: [Track], startIndex: Int = 0) {
        self.tracks = tracks
        self.currentIndex = startIndex
        playTrack(at: currentIndex)
    }
    
    func playTrack(at index: Int) {
        guard tracks.indices.contains(index) else { return }
        currentIndex = index
        currentTrack = tracks[currentIndex]
        guard let url = URL(string: currentTrack?.audioFileURL ?? "") else {
            print("Invalid audio URL")
            return
        }
        if AudioMixer.shared.isPlaying {
            AudioMixer.shared.stopMixedAudio()
        }
        
        player = AVPlayer(url: url)
        player?.play()
        isPlaying = true
    }
    
    func playTrack(for track: Track) {
        guard let index = tracks.firstIndex(of: track) else {return}
        currentIndex = index
        currentTrack = tracks[currentIndex]
        guard let url = URL(string: currentTrack?.audioFileURL ?? "") else {
            print("Invalid audio URL")
            return
        }
        if AudioMixer.shared.isPlaying {
            AudioMixer.shared.stopMixedAudio()
        }
        
        player = AVPlayer(url: url)
        player?.play()
        isPlaying = true
    }
    
    
    func play() {
        if AudioMixer.shared.isPlaying {
            AudioMixer.shared.stopMixedAudio()
        }
        
        configureAudioSession()
        if player == nil {
            currentTrack = tracks[currentIndex]
            guard let url = URL(string: currentTrack?.audioFileURL ?? "") else {
                print("Invalid audio URL")
                return
            }
            
            player = AVPlayer(url: url)
        }
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
        if let currentItem = player?.currentItem {
                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: currentItem)
            }
        player = nil
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func nextTrack() {
        if isShuffleEnabled {
            currentIndex = Int.random(in: 0..<tracks.count)
        } else {
            currentIndex = (currentIndex + 1) % tracks.count
        }
        playTrack(at: currentIndex)
    }
    
    func previousTrack() {
        if isShuffleEnabled {
            currentIndex = Int.random(in: 0..<tracks.count)
        } else {
            currentIndex = (currentIndex - 1 + tracks.count) % tracks.count
        }
        playTrack(at: currentIndex)
    }
    
    func toggleShuffle() {
        isShuffleEnabled.toggle()
    }
    
    func toggleRepeat() {
        isRepeatEnabled.toggle()
    }
    
    @objc private func playerDidFinishPlaying() {
        if AudioMixer.shared.isPlaying {
            return
        }
        if tracks.isEmpty {
            return
        }
        if isRepeatEnabled {
            playTrack(at: currentIndex)
        } else {
            nextTrack()
        }
    }
}
