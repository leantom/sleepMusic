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
                
                Text("Duration: \(trackDurationString(duration: alarm.duration))")
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(.gray)
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


struct AlarmSoundSelectionView: View {
    @Binding var selectedAlarm: String
    var alarmSounds: [AlarmSound] = [
        AlarmSound(name: "Colombia EAS Alarm", fileName: "colombia-eas-alarm-1903-242749", duration: 30),
        AlarmSound(name: "Germany EAS Alarm", fileName: "germany-eas-alarm-1945-242750", duration: 30),
        AlarmSound(name: "Lofi Alarm Clock", fileName: "lofi-alarm-clock-243766", duration: 60),
        AlarmSound(name: "Mixkit Alert", fileName: "mixkit-alert-alarm-1005", duration: 20),
        AlarmSound(name: "Casino Jackpot Alarm", fileName: "mixkit-casino-jackpot-alarm-and-coins-1991", duration: 45),
        AlarmSound(name: "Digital Clock Buzzer", fileName: "mixkit-digital-clock-digital-alarm-buzzer-992", duration: 15),
        AlarmSound(name: "Game Notification Alarm", fileName: "mixkit-game-notification-wave-alarm-987", duration: 30),
        AlarmSound(name: "Morning Clock Alarm", fileName: "mixkit-morning-clock-alarm-1003", duration: 30),
        AlarmSound(name: "Retro Game Emergency Alarm", fileName: "mixkit-retro-game-emergency-alarm-1000", duration: 40),
        AlarmSound(name: "Rooster Crowing", fileName: "mixkit-rooster-crowing-in-the-morning-2462", duration: 25),
        AlarmSound(name: "Scanning Sci-Fi Alarm", fileName: "mixkit-scanning-sci-fi-alarm-905", duration: 15),
        AlarmSound(name: "Short Rooster Crowing", fileName: "mixkit-short-rooster-crowing-2470", duration: 10),
        AlarmSound(name: "Sound Alert in Hall", fileName: "mixkit-sound-alert-in-hall-1006", duration: 35),
        AlarmSound(name: "Oversimplified Alarm", fileName: "oversimplified-alarm-clock-113180", duration: 45),
        AlarmSound(name: "Security Alarm", fileName: "security-alarm-63578", duration: 30),
        AlarmSound(name: "Severe Warning Alarm", fileName: "severe-warning-alarm-98704", duration: 60)
    ]
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).edgesIgnoringSafeArea(.all) // Dark background
            
            VStack(spacing: 20) {
                Text("Select Alarm Sound")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.top)
                
                // Scrollable grid of alarm sound options
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(alarmSounds) { alarm in
                            HStack {
                                Text(alarm.name)
                                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                if alarm.name == selectedAlarm {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.1)))
                            .onTapGesture {
                                selectedAlarm = alarm.name
                                AudioMixer.shared.playAlarmSound(fileName: alarm.fileName)
                            }
                        }
                    }
                    .padding()
                }
                
                // Done button to dismiss the selection view
                Button(action: {
                    // Dismiss logic or binding state changes
                    AudioMixer.shared.stopAlarmSound()
                    dismiss()
                }) {
                    Text("Done")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 15).fill(Color.green))
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
 
}
