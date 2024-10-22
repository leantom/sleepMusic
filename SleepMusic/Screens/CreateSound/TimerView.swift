//
//  TimerView.swift
//  SleepMusic
//
//  Created by QuangHo on 18/10/24.
//

import SwiftUI

struct TimerSettingsView: View {
    @State private var selectedDuration: Int = 7 * 60 * 60 // default to 7 hours
    @State private var fadeOutDuration: Double = 30
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            //MARK:  Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.8), Color(hex: "#1f1f48"),  Color(hex: "#1f1f48").opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Button {
                        withAnimation {
                            isPresented.toggle()
                        }
                        
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .foregroundStyle(.white)
                    }
                    .padding(.leading)
                    .frame(width: 50, height: 50)
                    Spacer()
                    
                    Button {
                        withAnimation {
                            AudioMixer.shared.restartMixedAudio()
                            TimerManager.shared.startTimer(duration: TimeInterval(selectedDuration), fadeOutDuration: fadeOutDuration)

                            isPresented.toggle()
                        }
                    } label: {
                        Text("Save")
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white)
                    }
                    .padding(.trailing)
                    .frame(width: 50, height: 50)
                    
                }
                
                //MARK:  Timer Duration Section
                VStack(alignment: .leading) {
                    Text("Timer Duration")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    Picker(selection: $selectedDuration,
                           label: Text("\(formattedDuration())")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white)
                           
                    ) {
                        ForEach(0..<24) { hour in
                            Text("\(hour):00:00").tag(hour * 3600)
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                .foregroundStyle(.white)
                                .tag(hour * 3600) // Set the tag for each item
                        }
                    }
                    .pickerStyle(.wheel)
                    .tint(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15) // Rounded border
                            .stroke(Color.white, lineWidth: 1) // Set border color and width
                    )
                    .padding()
                }
                
                
                //MARK:  Timer Behaviour Section
                VStack(alignment: .leading){
                    Text("Timer Behaviour")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    Text("What do you want the timer to do after it ends?")
                        .font(.system(size: 13, weight: .regular, design: .monospaced))
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .padding(.top, 5)
                    HStack {
                        Button(action: {
                            // Close App Action
                            TimerManager.shared.startTimer(duration: TimeInterval(selectedDuration), fadeOutDuration: fadeOutDuration)

                            isPresented.toggle()
                            
                        }) {
                            Text("Close App")
                                .font(.system(size: 15, weight: .bold, design: .monospaced))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 0.035, green: 0.022, blue: 0.101))
                                .cornerRadius(10)
                        }
                        .foregroundColor(.white)
                        
                        Button(action: {
                            // Stop Sounds Action
                            TimerManager.shared.startTimer(duration: TimeInterval(selectedDuration), fadeOutDuration: fadeOutDuration)
                            isPresented.toggle()
                        }) {
                            Text("Stop Sounds")
                                .font(.system(size: 15, weight: .bold, design: .monospaced))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .foregroundColor(.white)
                    }
                        .padding()
                }
                .padding(.top, 20)
                
                // Fade Out Section
                HStack {
                    Text("Fade Out")
                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    Spacer()
                    
                    FadeOutSettingsView(fadeOutDuration: $fadeOutDuration)
                    
                    Spacer()
                }
                .background(.gray.opacity(0.5))
                .cornerRadius(15)
                .padding()
                Spacer()
                
            }
        }
    }
    
    // Helper to format duration in hours:minutes:seconds
    func formattedDuration() -> String {
        let hours = selectedDuration / 3600
        return String(format: "%02d:00:00", hours)
    }
}

struct FadeOutSettingsView: View {
    @Binding var fadeOutDuration: Double // Change type to Double
    
    var body: some View {
        VStack {
            Text("Set Fade Out Duration")
                .font(.system(size: 15, weight: .medium, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.top, 8)
            // Slider now works with Double
            Slider(value: $fadeOutDuration, in: 10...60, step: 10)
                .padding(.horizontal)
                .tint(.purple)
            
            // Display the fade-out duration as an integer
            Text("\(Int(fadeOutDuration)) seconds")
                .font(.system(size: 15, weight: .medium, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
        
    }
}
struct TimeSettingsViewTests: View {
    @State var isPresented: Bool = false
    var body: some View {
        TimerSettingsView(isPresented: $isPresented)
    }
}
#Preview {
    TimeSettingsViewTests()
}
