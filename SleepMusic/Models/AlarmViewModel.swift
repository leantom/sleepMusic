import Foundation
import Combine
import AVFoundation

@MainActor
class AlarmSoundViewModel: ObservableObject {
    @Published var alarmSounds: [AlarmSound] = [
        AlarmSound(id: "colombia-eas-alarm-1903-242749", name: "Colombia EAS Alarm"),
        AlarmSound(id: "germany-eas-alarm-1945-242750", name: "Germany EAS Alarm"),
        AlarmSound(id: "lofi-alarm-clock-243766", name: "Lofi Alarm Clock"),
        AlarmSound(id: "mixkit-alert-alarm-1005", name: "Mixkit Alert Alarm"),
        AlarmSound(id: "mixkit-rooster-crowing-in-the-morning-2462", name: "Mixkit Rooster Crowing"),
        AlarmSound(id: "mixkit-scanning-sci-fi-alarm-905", name: "Mixkit Scanning Sci-Fi Alarm"),
        AlarmSound(id: "mixkit-sound-alert-in-hall-1006", name: "Mixkit Sound Alert in Hall"),
        AlarmSound(id: "severe-warning-alarm-98704", name: "Severe Warning Alarm")
    ]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    private var audioPlayer: AVAudioPlayer?

    init() {
       
    }

    
    /// Plays the sound for preview.
    func playSound(alarmSound: AlarmSound) {
        if let url = alarmSound.fileURL {
            playSound(from: url )
        }
        
    }

    /// Plays sound from the given URL.
    private func playSound(from url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }

   
}
