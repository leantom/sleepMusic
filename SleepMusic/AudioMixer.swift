import Foundation
import AVFoundation

class AudioMixer {
    let engine = AVAudioEngine()
    var audioPlayers: [AVAudioPlayerNode] = []
    var audioBuffers: [AVAudioPCMBuffer] = []
    var volumeNodes: [AVAudioMixerNode] = []

    init(audioFileNames: [String]) {
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
        for player in audioPlayers {
            player.stop()
        }
        engine.stop()
    }

    // Control the volume for each individual track
    func setVolume(forTrack trackIndex: Int, volume: Float) {
        if trackIndex < volumeNodes.count {
            volumeNodes[trackIndex].volume = volume
        } else {
            print("Track index out of bounds")
        }
    }
}
