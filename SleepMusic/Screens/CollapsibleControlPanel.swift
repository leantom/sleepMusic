import SwiftUI

struct CollapsibleControlPanel: View {
    @State private var isExpanded: Bool = false // Track whether the panel is expanded or collapsed
    @State private var isPause: Bool = false // Track whether the panel is expanded or collapsed
    @Binding var audioMixer: AudioMixer
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 20) {
                
                Button(action: {
                    // Toggle panel expansion
                    withAnimation {
                        
                        isPause.toggle()
                        isExpanded = true
                        if isPause {
                            audioMixer.stopMixedAudio()
                        } else {
                            audioMixer.restartMixedAudio()
                        }
                    }
                }) {
                    Image(systemName: isPause ? "pause.fill" : "play.fill")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.purple)
                        .clipShape(Circle())
                }
                
                // Check if the control panel is expanded
                if isExpanded {
                    // Additional Buttons (Visible when expanded)
                    Button(action: {
                        print("Button 1 tapped")
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
    @State  var audioMixer: AudioMixer = AudioMixer(audioFileNames: [])
    var body: some View {
        CollapsibleControlPanel(audioMixer: $audioMixer)
    }
}

struct CollapsibleControlPanel_Previews: PreviewProvider {
    static var previews: some View {
        WrapperCollapsibleControlView()
    }
}
