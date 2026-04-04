import SwiftUI
import AVFoundation

struct SleepMusicView: View {
    @State private var audioMixer: AudioMixer? = nil
    
    // Grid data
    let soundscapes = [
        ("Rain", "cloud.rain", "rainfall", true),
        ("Waves", "water.waves", "waves", false),
        ("Noise", "wind", "white_noise", false),
        ("Forest", "tree", "bird", false),
        ("Birds", "bird", "bird", false),
        ("Thunder", "cloud.bolt", "rainfall", false)
    ]
    
    var body: some View {
        ZStack {
            // Base background
            Color(red: 0.06, green: 0.06, blue: 0.08).edgesIgnoringSafeArea(.all)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 30) {
                    // 1. Custom Top Nav Bar
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(Color(red: 0.7, green: 0.5, blue: 0.9))
                        }
                        
                        Spacer()
                        
                        Text("SleepMusic")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Fake Profile Image
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 35, height: 35)
                            .overlay(
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.white)
                            )
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // 2. NOW PLAYING / Hero
                    VStack {
                        ZStack(alignment: .bottomTrailing) {
                            // Hero Image Placeholder (Cosmos)
                            RoundedRectangle(cornerRadius: 30)
                                .fill(
                                    LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.black]),
                                                   startPoint: .top, endPoint: .bottom)
                                )
                                .frame(height: 380)
                                .overlay(
                                    // A subtle galaxy-like circle in center
                                    Circle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 4)
                                        .frame(width: 150, height: 150)
                                )
                                .overlay(
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 20, height: 20)
                                        .shadow(color: .white, radius: 20, x: 0, y: 0)
                                )
                            
                            // Breathe Button
                            Button(action: {}) {
                                Text("BREATHE")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                    .frame(width: 80, height: 80)
                                    .background(Color.cyan.opacity(0.3))
                                    .clipShape(Circle())
                                    .padding(20)
                                    .offset(y: 40) // Makes it hang off the bottom right
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("NOW PLAYING")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.7, green: 0.5, blue: 0.9))
                                .padding(.top, 20)
                            
                            Text("Cosmic Drift")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Deep Sleep • 45 min")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        
                        // Progress Bar
                        VStack(spacing: 8) {
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.white.opacity(0.1))
                                        .frame(height: 6)
                                        .cornerRadius(3)
                                    
                                    Rectangle()
                                        .fill(Color(red: 0.7, green: 0.5, blue: 0.9))
                                        .frame(width: geometry.size.width * 0.35, height: 6)
                                        .cornerRadius(3)
                                }
                            }
                            .frame(height: 6)
                            
                            HStack {
                                Text("15:20")
                                Spacer()
                                Text("45:00")
                            }
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .padding(.top, 15)
                        
                        // Playback Controls
                        HStack(spacing: 50) {
                            Button(action: {}) {
                                Image(systemName: "gobackward.10")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "pause.fill")
                                    .font(.title)
                                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                                    .frame(width: 80, height: 80)
                                    .background(Color(red: 0.7, green: 0.5, blue: 0.9))
                                    .clipShape(Circle())
                                    .shadow(color: Color(red: 0.7, green: 0.5, blue: 0.9).opacity(0.5), radius: 20)
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "goforward.30")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 10)
                    }
                    
                    // 3. Soundscapes Grid
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Soundscapes")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text("Layer your experience")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(action: {}) {
                                Text("VIEW ALL")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(Color(red: 0.7, green: 0.5, blue: 0.9))
                            }
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 30) {
                            ForEach(soundscapes, id: \.0) { (name, icon, soundFile, isActive) in
                                VStack(spacing: 12) {
                                    Button(action: { playSound(sound: soundFile) }) {
                                        Image(systemName: icon)
                                            .font(.title2)
                                            .frame(width: 70, height: 70)
                                            .foregroundColor(isActive ? Color(red: 0.7, green: 0.5, blue: 0.9) : .white)
                                            .background(Color.white.opacity(0.05))
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle().stroke(isActive ? Color(red: 0.7, green: 0.5, blue: 0.9) : Color.clear, lineWidth: 2)
                                            )
                                            .shadow(color: isActive ? Color(red: 0.7, green: 0.5, blue: 0.9).opacity(0.5) : Color.clear, radius: 10)
                                    }
                                    
                                    Text(name.uppercased())
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(isActive ? Color(red: 0.7, green: 0.5, blue: 0.9) : .gray)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // 4. Featured Cards
                    VStack(spacing: 20) {
                        // Card 1
                        FeaturedCard(title: "Morning Focus", subtitle: "Gently awaken your mind with binaural beats and nature.", imageGradient: [Color.teal.opacity(0.4), Color(red: 0.1, green: 0.2, blue: 0.2)])
                        
                        // Card 2
                        FeaturedCard(title: "Deep Sleep", subtitle: "Engineered frequencies to guide you into restorative rest.", imageGradient: [Color.orange.opacity(0.2), Color(red: 0.2, green: 0.1, blue: 0.1)])
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100) // Space for custom tab bar
                }
            }
        }
    }
    
    // Function to play sound using AudioMixer
    func playSound(sound: String) {
        if let mixer = audioMixer {
            mixer.loadAudioFile(sound)
            mixer.playMixedAudio()
        } else {
            audioMixer = AudioMixer(audioFileNames: [sound])
            audioMixer?.playMixedAudio()
        }
    }
}

// Helper Card View
struct FeaturedCard: View {
    var title: String
    var subtitle: String
    var imageGradient: [Color]
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 25)
                .fill(LinearGradient(gradient: Gradient(colors: imageGradient), startPoint: .top, endPoint: .bottom))
                .frame(height: 220)
                .overlay(
                    // Fake generic icon in middle
                    Image(systemName: "sparkles")
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.trailing, 40)
            }
            .padding(25)
        }
    }
}

struct SleepMusicView_Previews: PreviewProvider {
    static var previews: some View {
        SleepMusicView()
    }
}
