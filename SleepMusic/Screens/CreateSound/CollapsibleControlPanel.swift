import SwiftUI
import FirebaseAnalytics

struct CollapsibleControlPanel: View {
    @ObservedObject var audioMixer: AudioMixer
    @Binding var isRelaxingMusicViewPresented: Bool
    @Binding var isSavedViewPresented: Bool

    var body: some View {
        HStack(spacing: 0) {
            dockButton(icon: "waveform.path", title: "Player") {
                Analytics.logEvent("relaxing_music_view_opened", parameters: nil)
                isRelaxingMusicViewPresented = true
            }

            Spacer()

            Button {
                if audioMixer.isPlaying {
                    audioMixer.stopMixedAudio()
                } else {
                    audioMixer.restartMixedAudio()
                }
            } label: {
                Image(systemName: audioMixer.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color(red: 53 / 255, green: 20 / 255, blue: 79 / 255))
                    .frame(width: 66, height: 66)
                    .background(
                        Circle()
                            .fill(LuminousPalette.primaryGradient)
                            .shadow(color: LuminousPalette.primary.opacity(0.34), radius: 28, x: 0, y: 12)
                    )
            }
            .buttonStyle(.plain)
            .offset(y: -16)

            Spacer()

            dockButton(icon: "square.and.arrow.down", title: "Save") {
                guard !AudioMixer.shared.selectedSounds.isEmpty else { return }
                isSavedViewPresented = true
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 10)
        .luminousGlassCard(cornerRadius: 30, fillColor: LuminousPalette.surfaceContainer)
    }

    private func dockButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(LuminousPalette.textPrimary)
                    .frame(width: 38, height: 38)
                    .background(
                        Circle()
                            .fill(LuminousPalette.surfaceHigh)
                            .overlay(Circle().stroke(LuminousPalette.ghostBorder, lineWidth: 1))
                    )

                Text(title.uppercased())
                    .font(LuminousType.label(9, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(LuminousPalette.textSecondary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct WrapperCollapsibleControlView: View {
    @ObservedObject var audioMixer: AudioMixer = AudioMixer(audioFileNames: [])
    @State var isRelaxingMusicViewPresented = false
    @State var isShow = false

    var body: some View {
        CollapsibleControlPanel(
            audioMixer: audioMixer,
            isRelaxingMusicViewPresented: $isRelaxingMusicViewPresented,
            isSavedViewPresented: $isShow
        )
    }
}

struct CollapsibleControlPanel_Previews: PreviewProvider {
    static var previews: some View {
        WrapperCollapsibleControlView()
    }
}
