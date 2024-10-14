import Foundation
import AVFoundation

class AudioMixer {
    let engine = AVAudioEngine()
    var audioPlayers: [AVAudioPlayerNode] = []
    var audioBuffers: [AVAudioPCMBuffer] = []
    var volumeNodes: [AVAudioMixerNode] = []
    var audioFileNames: [String] = []  // Parallel array to track file names
    
    init(audioFileNames: [String]) {
        if audioFileNames.isEmpty {
            return
        }
        for fileName in audioFileNames {
            loadAudioFile(fileName)
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
    
    func playMixedAudio() {
        do {
            // Start the audio engine
            try engine.start()
            
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
    
    func stopMixedAudio() {
        
        engine.stop()
    }
    
    // Restart audio engine after stopping
    func restartMixedAudio() {
        if engine.isRunning {
            stopMixedAudio()
        }
        
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
