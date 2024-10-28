//
//  AlarmSoundSelectionView.swift
//  SleepMusic
//
//  Created by QuangHo on 23/10/24.
//
import SwiftUI

struct AlarmSoundSelectionView: View {
    @Binding var selectedAlarm: String
    @ObservedObject var alarmViewModel: AlarmSoundViewModel // Changed to ObservedObject
    
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
                        ForEach(alarmViewModel.alarmSounds, id: \.id) { alarm in
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
                                alarmViewModel.playSound(alarmSound: alarm)
                            }
                        }
                    }
                    .padding()
                }
                
                // Done button to dismiss the selection view
                Button(action: {
                    // Dismiss logic or binding state changes
                    AudioPlayer.shared.stopPlayAlarm()
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
        .onAppear {
            AudioPlayer.shared.isPlayAlarm = true
        }
        .onDisappear {
            AudioPlayer.shared.isPlayAlarm = false
        }
    }
}
