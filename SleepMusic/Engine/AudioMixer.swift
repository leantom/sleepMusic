import Foundation
import AVFoundation

class AudioMixer:ObservableObject {
    let engine = AVAudioEngine()
    var audioPlayers: [AVAudioPlayerNode] = []
    var audioBuffers: [AVAudioPCMBuffer] = []
    var volumeNodes: [AVAudioMixerNode] = []
    var audioFileNames: [String] = []
    static let shared = AudioMixer(audioFileNames: [])
    @Published var selectedSounds: [Sound] = []
    @Published var isPlaying: Bool = false
    @Published var isPlaySaved: Bool = false
    var alarmPlayer: AVAudioPlayer? // Independent player for alarm sound
    
    init(audioFileNames: [String]) {
        if audioFileNames.isEmpty {
            return
        }
        for fileName in audioFileNames {
            loadAudioFile(fileName)
        }
    }
    
    func loadAudioFiles(_ audioFileNames: [String]) {
        self.audioFileNames.append(contentsOf: audioFileNames)
        for fileName in audioFileNames {
            loadAudioFile(fileName)
        }
    }
    
    func loadAudioFilesSound(_ sounds: [Sound]) {
        for sound in sounds {
            self.audioFileNames.append(sound.audioFile ?? "")
            loadAudioFile(sound.audioFile ?? "")
        }
    }
    
    func loadAudioFile(_ fileName: String) {
        guard let audioFilePath = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("Audio file not found: \(fileName)")
            return
        }
        
        do {
            let audioFile = try AVAudioFile(forReading: audioFilePath)
            let playerNode = AVAudioPlayerNode()
            let mixerNode = AVAudioMixerNode() // Create a mixer node for volume control
            engine.attach(playerNode)
            engine.attach(mixerNode)
            
            let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
            try audioFile.read(into: buffer!)
            
            audioPlayers.append(playerNode)
            audioBuffers.append(buffer!)
            volumeNodes.append(mixerNode)
            audioFileNames.append(fileName)  // Keep track of the file name
            
            // Connect playerNode -> mixerNode -> main mixer (to control the volume of each track)
            engine.connect(playerNode, to: mixerNode, format: buffer!.format)
            engine.connect(mixerNode, to: engine.mainMixerNode, format: buffer!.format)
        } catch {
            print("Error loading audio file: \(error.localizedDescription)")
        }
    }
    
    func playAlarmSound(fileName: String) {
           guard let alarmSoundURL = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
               print("Alarm sound not found: \(fileName)")
               return
           }
           
           do {
               // Initialize the alarm player with the sound file
               alarmPlayer = try AVAudioPlayer(contentsOf: alarmSoundURL)
               
               // Set the audio session to allow mixing with others, without stopping the engine
               try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
               try AVAudioSession.sharedInstance().setActive(true)
               
               // Play the alarm sound
               alarmPlayer?.play()
               print("Playing alarm sound: \(fileName)")
               
           } catch {
               print("Error playing alarm sound: \(error.localizedDescription)")
           }
       }
       
       // Existing functions for mixing audio (playMixedAudio, stopMixedAudio, etc.) ...
       
       // Function to stop the alarm sound
       func stopAlarmSound() {
           alarmPlayer?.stop()
           print("Alarm sound stopped")
       }
    
    func playMixedAudio() {
        do {
            
            // check audio player
            if AudioPlayer.shared.isPlaying {
                AudioPlayer.shared.pause()
            }
            configureAudioSession()
            // Start the audio engine
            try engine.start()
            self.isPlaying = true // Update when the engine starts playing
            // Play all audio files at the same time
            for (index, player) in audioPlayers.enumerated() {
                let buffer = audioBuffers[index]
                player.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
                player.play()
            }
        } catch {
            print("Audio engine could not start: \(error.localizedDescription)")
        }
    }
    
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    func stopMixedAudio() {
        
        engine.stop()
        self.isPlaying = false // Update when the engine stops
    }
    //MARK: -- reset mixed audio
    func resetMixedAudio() {
        stopMixedAudio()
        audioFileNames.removeAll()
        audioPlayers.removeAll()
        audioBuffers.removeAll()
        isPlaySaved = false
    }
    
    // Restart audio engine after stopping
    func restartMixedAudio() {
        // check audio player
        if AudioPlayer.shared.isPlaying {
            AudioPlayer.shared.pause()
        }
        
        if audioPlayers.isEmpty {return}
        if engine.isRunning {
            stopMixedAudio()
        }
        configureAudioSession()
        self.isPlaying = true
        // Reconnect and re-schedule buffers before starting again
        do {
            for (index, player) in audioPlayers.enumerated() {
                let buffer = audioBuffers[index]
                
                // Ensure players and mixer nodes are re-attached and connected to the engine
                engine.attach(player)
                engine.attach(volumeNodes[index])
                engine.connect(player, to: volumeNodes[index], format: buffer.format)
                engine.connect(volumeNodes[index], to: engine.mainMixerNode, format: buffer.format)
                
                // Re-schedule the buffer before playing
                player.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
            }
            
            try engine.start() // Restart the engine
            for player in audioPlayers {
                player.play()
            }
            
        } catch {
            print("Audio engine could not restart: \(error.localizedDescription)")
        }
    }
    
    
    // Control the volume for each individual track
    func setVolume(forTrack trackIndex: Int, volume: Float) {
        if trackIndex < volumeNodes.count {
            volumeNodes[trackIndex].volume = volume
        } else {
            print("Track index out of bounds")
        }
    }
    
    func setVolume(volume: Float) {
        for volumeNode in volumeNodes {
            volumeNode.volume = volume
        }
    }
    
    func trackWithLowestVolume() -> Int? {
        guard !volumeNodes.isEmpty else {
            print("No tracks available")
            return nil
        }
        
        // Assume the first track has the lowest volume
        var lowestVolumeIndex = 0
        var lowestVolume = volumeNodes[0].volume
        
        // Loop through the volume nodes to find the track with the lowest volume
        for (index, node) in volumeNodes.enumerated() {
            if node.volume < lowestVolume {
                lowestVolume = node.volume
                lowestVolumeIndex = index
            }
        }
        
        return lowestVolumeIndex
    }
    
    // Remove the audio file from the mixer and stop its playback
    func removeAudioFile(_ fileName: String) {
        // Find the index of the file to be removed using the audioFileNames array
        guard let index = audioFileNames.firstIndex(of: fileName) else {
            print("Audio file not found: \(fileName)")
            return
        }
        
        // Disconnect the player and mixer nodes from the engine
        engine.disconnectNodeInput(audioPlayers[index])
        engine.disconnectNodeInput(volumeNodes[index])
        
        // Stop the player and remove from all relevant arrays
        audioPlayers[index].stop()
        audioPlayers.remove(at: index)
        audioBuffers.remove(at: index)
        volumeNodes.remove(at: index)
        audioFileNames.remove(at: index)  // Remove the file name from the tracking array
        
        print("Removed track: \(fileName)")
    }
}
