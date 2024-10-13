import SwiftUI
import AVFoundation

struct SleepMusicView: View {
    // Create an instance of AudioMixer
    @State private var audioMixer: AudioMixer? = nil
    
    let soundButtons = [
        ("Bird", "icon-bird", "bird", true),
        ("Instrumental", "icon-instrumental", "instrumental_music", true),
        ("Rainfall", "icon-rainfall", "rainfall", true),
        ("Waves", "icon-waves", "waves", true),
        ("Waves Close Up", "icon-waves-close", "waves_close_up", true),
        ("White Noise", "icon-white-noise", "white_noise", true),
        // Add more sounds as needed
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.black]),
                           startPoint: .top,
                           endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                // Top bar
                HStack {
                    Text("Sounds")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        // Upgrade action
                    }) {
                        Text("Upgrade")
                            .font(.headline)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                    }
                    Button(action: {
                        // Search action
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                }
                .padding()
                
                // Tab bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(["All", "Rain", "Water", "Wind", "Instrument"], id: \.self) { tab in
                            Text(tab)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 20)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Sound buttons
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                    ForEach(soundButtons, id: \.0) { (name, icon, soundFile, isActive) in
                        VStack {
                            Button(action: {
                                playSound(sound: soundFile)
                            }) {
                                Image(systemName: isActive ? "circle.fill" : "circle")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(isActive ? Color.purple : Color.gray)
                                    .background(isActive ? Color.white.opacity(0.2) : Color.gray.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            Text(name)
                                .foregroundColor(isActive ? .white : .gray)
                        }
                        .padding()
                    }
                }
                .padding()
                
                Spacer()
                
                // Bottom player bar (optional)
                HStack {
                    Button(action: {
                        // Play/Pause action (if needed)
                    }) {
                        Image(systemName: "playpause.fill")
                            .foregroundColor(.white)
                            .font(.title)
                            .padding()
                    }
                    Spacer()
                    // Add other buttons like forward, backward, etc.
                }
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(20)
                .padding()
            }
        }
    }
    
    // Function to play sound using AudioMixer
    func playSound(sound: String) {
        if audioMixer == nil {
            // Initialize AudioMixer with the selected sound
            audioMixer = AudioMixer(audioFileNames: [sound])
        } else {
            // Add new sound to the mixer
            audioMixer?.loadAudioFile(sound)
        }
        
        // Play the sound using AudioMixer
        audioMixer?.playMixedAudio()
    }
}

struct SleepMusicView_Previews: PreviewProvider {
    static var previews: some View {
        SleepMusicView()
    }
}
