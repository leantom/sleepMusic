import SwiftUI

struct MediaControlView: View {
    @ObservedObject var audioPlayer = AudioPlayer.shared

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 22) {
                controlButton(icon: audioPlayer.isShuffleEnabled ? "shuffle.circle.fill" : "shuffle") {
                    audioPlayer.toggleShuffle()
                }

                controlButton(icon: "backward.fill") {
                    audioPlayer.previousTrack()
                }

                Button {
                    audioPlayer.togglePlayPause()
                } label: {
                    Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color(red: 53 / 255, green: 20 / 255, blue: 79 / 255))
                        .frame(width: 72, height: 72)
                        .background(
                            Circle()
                                .fill(LuminousPalette.primaryGradient)
                                .shadow(color: LuminousPalette.primary.opacity(0.34), radius: 26, x: 0, y: 14)
                        )
                }
                .buttonStyle(.plain)

                controlButton(icon: "forward.fill") {
                    audioPlayer.nextTrack()
                }

                controlButton(icon: audioPlayer.isRepeatEnabled ? "repeat.circle.fill" : "repeat") {
                    audioPlayer.toggleRepeat()
                }
            }

            Text(audioPlayer.currentTrack?.name ?? "Waiting for a selected track")
                .font(LuminousType.body(14, weight: .semibold))
                .foregroundStyle(LuminousPalette.textPrimary)
                .lineLimit(1)

            Text(audioPlayer.currentTrack?.nameOfTracklist ?? "Choose a tracklist to begin")
                .font(LuminousType.body(12))
                .foregroundStyle(LuminousPalette.textSecondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 20)
        .luminousGlassCard(cornerRadius: 30, fillColor: LuminousPalette.surfaceLow)
    }

    private func controlButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(LuminousPalette.textPrimary)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(LuminousPalette.surfaceHigh)
                        .overlay(Circle().stroke(LuminousPalette.ghostBorder, lineWidth: 1))
                )
        }
        .buttonStyle(.plain)
    }
}

struct WrapperMediaControlView: View {
    var body: some View {
        MediaControlView()
    }
}

struct MediaControlView_Previews: PreviewProvider {
    static var previews: some View {
        WrapperMediaControlView()
    }
}
