import SwiftUI

struct SoundMixRow: View {
    var soundMix: SoundMix
    var onDelete: () -> Void

    var body: some View {
        Button {
            withAnimation {
                AudioMixer.shared.resetMixedAudio()
                AudioMixer.shared.selectedSounds = soundMix.sounds
                AudioMixer.shared.loadAudioFilesSound(soundMix.sounds)
                AudioMixer.shared.playMixedAudio()
                AudioMixer.shared.isPlaySaved = true
            }
        } label: {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(LuminousPalette.accentGradient)
                    .frame(width: 64, height: 64)
                    .overlay(
                        Image(systemName: "waveform.and.magnifyingglass")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Color(red: 53 / 255, green: 20 / 255, blue: 79 / 255))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(soundMix.name)
                        .font(LuminousType.body(15, weight: .semibold))
                        .foregroundStyle(LuminousPalette.textPrimary)

                    Text("\(soundMix.sounds.count) layered sounds")
                        .font(LuminousType.body(13))
                        .foregroundStyle(LuminousPalette.textSecondary)
                }

                Spacer()

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(LuminousPalette.textSecondary)
                        .frame(width: 38, height: 38)
                        .background(
                            Circle()
                                .fill(LuminousPalette.surfaceHigh)
                                .overlay(Circle().stroke(LuminousPalette.ghostBorder, lineWidth: 1))
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(14)
            .luminousGlassCard(cornerRadius: 24, fillColor: LuminousPalette.surfaceLow)
        }
        .buttonStyle(.plain)
    }
}
