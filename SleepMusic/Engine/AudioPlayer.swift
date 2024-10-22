import AVFoundation
import MediaPlayer
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
        configureRemoteCommandCenter()
    }
    
    // MARK: - Audio Session Configuration
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Setting up the Tracks
    func setTracks(_ tracks: [Track], startIndex: Int = 0) {
        self.tracks = tracks
        self.currentIndex = startIndex
        playTrack(at: currentIndex)
        updateNowPlayingInfo() // Update the Control Center with the current track info
    }
    
    // MARK: - Play a Specific Track by Index
    func playTrack(at index: Int) {
        guard tracks.indices.contains(index) else { return }
        currentIndex = index
        currentTrack = tracks[currentIndex]
        guard let url = URL(string: currentTrack?.audioFileURL ?? "") else {
            print("Invalid audio URL")
            return
        }
        
        stopMixedAudioIfNeeded()
        
        player = AVPlayer(url: url)
        player?.play()
        isPlaying = true
        
        updateNowPlayingInfo() // Update the Now Playing Info
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
    
    
    // MARK: - Play or Pause Toggle
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    // MARK: - Pause Playback
    func pause() {
        player?.pause()
        isPlaying = false
        updateNowPlayingInfo() // Update the Now Playing Info to reflect paused state
    }
    
    // MARK: - Play Current Track
    func play() {
        configureAudioSession()
        
        if player == nil, tracks.indices.contains(currentIndex) {
            currentTrack = tracks[currentIndex]
            guard let url = URL(string: currentTrack?.audioFileURL ?? "") else {
                print("Invalid audio URL")
                return
            }
            player = AVPlayer(url: url)
        }
        
        player?.play()
        isPlaying = true
        updateNowPlayingInfo() // Update the Now Playing Info
    }
    
    // MARK: - Player Did Finish Playing
    @objc private func playerDidFinishPlaying() {
        if isRepeatEnabled {
            playTrack(at: currentIndex)
        } else {
            nextTrack()
        }
    }
    
    // MARK: - Play Next Track
    func nextTrack() {
        currentIndex = (currentIndex + 1) % tracks.count
        playTrack(at: currentIndex)
    }
    
    // MARK: - Play Previous Track
    func previousTrack() {
        currentIndex = (currentIndex - 1 + tracks.count) % tracks.count
        playTrack(at: currentIndex)
    }
    
    // MARK: - Configure Remote Command Center
    func configureRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Play command
        commandCenter.playCommand.addTarget { [weak self] event in
            self?.play()
            return .success
        }
        
        // Pause command
        commandCenter.pauseCommand.addTarget { [weak self] event in
            self?.pause()
            return .success
        }
        
        // Next track command
        commandCenter.nextTrackCommand.addTarget { [weak self] event in
            self?.nextTrack()
            return .success
        }
        
        // Previous track command
        commandCenter.previousTrackCommand.addTarget { [weak self] event in
            self?.previousTrack()
            return .success
        }
    }
    
    // MARK: - Shuffle Mode Toggle
    func toggleShuffle() {
        isShuffleEnabled.toggle()
    }
    
    // MARK: - Repeat Mode Toggle
    func toggleRepeat() {
        isRepeatEnabled.toggle()
    }
    
    // MARK: - Update Now Playing Info
    func updateNowPlayingInfo() {
        guard let currentTrack = currentTrack else { return }
        
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = [String: Any]()
        
        // Set track title, artist, and album info
        nowPlayingInfo[MPMediaItemPropertyTitle] = currentTrack.name
        nowPlayingInfo[MPMediaItemPropertyArtist] = currentTrack.tracklistID ?? ""
        
        // Set track duration and current playback time
        if let duration = player?.currentItem?.asset.duration {
            let durationInSeconds = CMTimeGetSeconds(duration)
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player?.currentTime() ?? CMTime())
        }
        
        // Set playback state
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    // MARK: - Stop Mixed Audio (if it's playing)
    private func stopMixedAudioIfNeeded() {
        if AudioMixer.shared.isPlaying {
            AudioMixer.shared.stopMixedAudio()
        }
    }
}
