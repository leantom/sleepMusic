import SwiftUI

struct SleepMixView: View {
    @Binding var sounds: [Sound]
    @Environment(\.dismiss) private var dismiss

    @State private var titleMix = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var isPlaying = false
    @State private var isShowErr = false
    @State private var isShowTimer = false

    private let columns = [GridItem(.flexible(), spacing: 18), GridItem(.flexible(), spacing: 18)]

    var body: some View {
        ZStack {
            LuminousBackground()

            if isShowTimer {
                TimerSettingsView(isPresented: $isShowTimer)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        topBar
                        titleBlock
                        mixStage
                        namingSection
                        footerActions
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 18)
                    .padding(.bottom, 44)
                }
            }
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
        .onAppear {
            isPlaying = AudioMixer.shared.isPlaying
        }
    }

    private var topBar: some View {
        HStack {
            LuminousIconButton(icon: "xmark") {
                dismiss()
            }

            Spacer()

            Button("Clear all") {
                withAnimation {
                    AudioMixer.shared.resetMixedAudio()
                    sounds.removeAll()
                }
            }
            .buttonStyle(.plain)
            .font(LuminousType.label(11, weight: .bold))
            .textCase(.uppercase)
            .foregroundStyle(LuminousPalette.textSecondary)
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ATMOSPHERE")
                .font(LuminousType.label(11, weight: .bold))
                .tracking(2)
                .foregroundStyle(LuminousPalette.primary)

            Text("Sound Mixer")
                .font(LuminousType.display(40, weight: .bold))
                .foregroundStyle(LuminousPalette.textPrimary)

            Text("Shape a saved mix with tactile faders, slow gradients, and just enough glow to feel alive.")
                .font(LuminousType.body(15))
                .foregroundStyle(LuminousPalette.textSecondary)
        }
    }

    @ViewBuilder
    private var mixStage: some View {
        if sounds.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("No active channels yet.")
                    .font(LuminousType.headline(22, weight: .bold))
                    .foregroundStyle(LuminousPalette.textPrimary)

                Text("Return to the mixer tab, layer a few sounds, then come back here to save the blend.")
                    .font(LuminousType.body(15))
                    .foregroundStyle(LuminousPalette.textSecondary)
            }
            .padding(24)
            .luminousGlassCard(fillColor: LuminousPalette.surfaceLow)
        } else {
            LazyVGrid(columns: columns, spacing: 18) {
                ForEach($sounds) { $sound in
                    MixSoundStageCard(sound: $sound)
                }
            }
        }
    }

    private var namingSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Name your mix")
                .font(LuminousType.headline(24, weight: .bold))
                .foregroundStyle(LuminousPalette.textPrimary)

            VStack(alignment: .leading, spacing: 8) {
                TextField(
                    "",
                    text: $titleMix,
                    prompt: Text(isShowErr ? "Please enter a name" : "Ex: Velvet Rain")
                        .foregroundColor(isShowErr ? Color.red.opacity(0.8) : LuminousPalette.textSecondary)
                )
                .focused($isTextFieldFocused)
                .font(LuminousType.body(16))
                .foregroundStyle(LuminousPalette.textPrimary)

                Text("Short and memorable names make saved mixes easier to revisit later.")
                    .font(LuminousType.body(13))
                    .foregroundStyle(LuminousPalette.textSecondary)
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(LuminousPalette.surfaceLow)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(isShowErr ? Color.red.opacity(0.45) : LuminousPalette.ghostBorder, lineWidth: 1)
                    )
            )
        }
    }

    private var footerActions: some View {
        HStack(spacing: 0) {
            footerButton(icon: "clock", title: "Timer") {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isShowTimer = true
                }
            }

            Spacer()

            Button {
                previewMix()
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color(red: 53 / 255, green: 20 / 255, blue: 79 / 255))
                    .frame(width: 68, height: 68)
                    .background(
                        Circle()
                            .fill(LuminousPalette.primaryGradient)
                            .shadow(color: LuminousPalette.primary.opacity(0.35), radius: 28, x: 0, y: 14)
                    )
            }
            .buttonStyle(.plain)
            .offset(y: -16)

            Spacer()

            footerButton(icon: "heart.fill", title: "Save") {
                saveMix()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 12)
        .luminousGlassCard(cornerRadius: 30, fillColor: LuminousPalette.surfaceContainer)
    }

    private func footerButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(LuminousPalette.textPrimary)
                    .frame(width: 40, height: 40)
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

    private func previewMix() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isPlaying.toggle()

            if isPlaying {
                AudioMixer.shared.resetMixedAudio()
                AudioMixer.shared.selectedSounds = sounds
                AudioMixer.shared.loadAudioFilesSound(sounds)
                AudioMixer.shared.playMixedAudio()

                for index in sounds.indices {
                    AudioMixer.shared.setVolume(forTrack: index, volume: Float(sounds[index].volume))
                }
            } else {
                AudioMixer.shared.stopMixedAudio()
            }
        }
    }

    private func saveMix() {
        guard !titleMix.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            isShowErr = true
            return
        }

        isShowErr = false
        let soundMix = SoundMix(name: titleMix.trimmingCharacters(in: .whitespacesAndNewlines), sounds: sounds)
        SoundMixManager.shared.addCombination(soundMix)
        dismiss()
    }
}

private struct MixSoundStageCard: View {
    @Binding var sound: Sound

    var body: some View {
        VStack(spacing: 18) {
            MixStageFader(value: $sound.volume)
                .frame(width: 96, height: 250)

            VStack(spacing: 8) {
                Image(systemName: sound.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(LuminousPalette.primary)

                Text(sound.name.uppercased())
                    .font(LuminousType.label(10, weight: .bold))
                    .tracking(1.4)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(LuminousPalette.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 12)
        .luminousGlassCard(fillColor: LuminousPalette.surfaceLow, glowColor: LuminousPalette.primary)
        .onChange(of: sound.volume) { newValue in
            guard let index = AudioMixer.shared.selectedSounds.firstIndex(where: { $0.id == sound.id }) else { return }
            AudioMixer.shared.setVolume(forTrack: index, volume: Float(newValue))
        }
    }
}

private struct MixStageFader: View {
    @Binding var value: Double

    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let thumbSize: CGFloat = 24
            let progress = max(0, min(1, value))
            let y = (1 - progress) * (height - thumbSize)

            ZStack(alignment: .top) {
                Capsule(style: .continuous)
                    .fill(LuminousPalette.surfaceHigh.opacity(0.7))

                VStack {
                    Spacer(minLength: y)

                    Capsule(style: .continuous)
                        .fill(LuminousPalette.primaryGradient)
                        .frame(height: height - y)
                        .shadow(color: LuminousPalette.primary.opacity(0.28), radius: 22, x: 0, y: 0)
                }

                Circle()
                    .fill(Color.white)
                    .frame(width: thumbSize, height: thumbSize)
                    .shadow(color: LuminousPalette.primary.opacity(0.34), radius: 18, x: 0, y: 0)
                    .offset(y: y)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let location = min(max(gesture.location.y, 0), height)
                        value = 1 - Double(location / height)
                    }
            )
        }
    }
}

struct WrapperSleepViewMix: View {
    @State var sounds: [Sound] = SoundCategory.getAllSounds()

    var body: some View {
        SleepMixView(sounds: $sounds)
    }
}

#Preview {
    WrapperSleepViewMix()
}
