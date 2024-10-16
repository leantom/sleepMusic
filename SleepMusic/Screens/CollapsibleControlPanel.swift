import SwiftUI

struct CollapsibleControlPanel: View {
    @State private var isExpanded: Bool = false // Track whether the panel is expanded or collapsed
    @ObservedObject var audioMixer: AudioMixer
    @Binding var isRelaxingMusicViewPresented: Bool // New binding property
        
    @State var isPlaying: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 20) {
                
                Button(action: {
                    // Toggle panel expansion
                    withAnimation {
                        
                        isExpanded = true
                        if audioMixer.isPlaying {
                            audioMixer.stopMixedAudio()
                        } else {
                            audioMixer.restartMixedAudio()
                        }
                    }
                }) {
                    Image(systemName: audioMixer.isPlaying ? "pause.fill" : "play.fill")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.purple)
                        .clipShape(Circle())
                }
                
                
                // Check if the control panel is expanded
                if isExpanded {
                    // Additional Buttons (Visible when expanded)
                    Button(action: {
                        isRelaxingMusicViewPresented.toggle()
                    }) {
                        Image(systemName: "rectangle.3.offgrid.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        print("Button 2 tapped")
                    }) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    // Close Button (To collapse the panel back)
                    Button(action: {
                        withAnimation {
                            isExpanded = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.4))
            )
            .padding(.horizontal, 30)
            .transition(.move(edge: .bottom)) // Smooth transition effect
        }
    }
}

struct WrapperCollapsibleControlView: View {
    @ObservedObject  var audioMixer: AudioMixer = AudioMixer(audioFileNames: [])
    @State var isplaying: Bool = false
    @State var isRelaxingMusicViewPresented: Bool = false  // New binding property
        
    var body: some View {
        CollapsibleControlPanel(audioMixer: audioMixer, isRelaxingMusicViewPresented: $isRelaxingMusicViewPresented)
    }
}

struct CollapsibleControlPanel_Previews: PreviewProvider {
    static var previews: some View {
        WrapperCollapsibleControlView()
    }
}
