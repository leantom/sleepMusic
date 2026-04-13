import SwiftUI
import FirebaseAnalytics

struct ZenMusicView: View {
    @ObservedObject var soundMixManager = SoundMixManager.shared
    @ObservedObject var audioMixer: AudioMixer = AudioMixer.shared
    @ObservedObject var settingApp = AppSetting.shared

    private let categories = SoundCategory.getCategories()

    @State private var selectedCategory = "All"
    @State private var isRelaxingMusicViewPresented = false
    @State private var isShowAlarmViewPresented = false
    @State private var isSaveCombinationViewPresented = false

    private var filteredSounds: [Sound] {
        if selectedCategory == "All" {
            return SoundCategory.getAllSounds()
        }

        return categories.first(where: { $0.name == selectedCategory })?.sounds ?? SoundCategory.getAllSounds()
    }

    var body: some View {
        ZStack {
            LuminousBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    activeMixSection
                    categoriesSection
                    soundLibrarySection
                    savedMixesSection
                    Spacer(minLength: 170)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }

            VStack {
                Spacer()
                CollapsibleControlPanel(
                    audioMixer: audioMixer,
                    isRelaxingMusicViewPresented: $isRelaxingMusicViewPresented,
                    isSavedViewPresented: $isSaveCombinationViewPresented
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 86)
            }
        }
        .sheet(isPresented: $isSaveCombinationViewPresented) {
            SleepMixView(sounds: $audioMixer.selectedSounds)
                .presentationBackground(Color.clear)
        }
        .fullScreenCover(isPresented: $isRelaxingMusicViewPresented) {
            RelaxingMusicView()
        }
        .fullScreenCover(isPresented: $isShowAlarmViewPresented) {
            
            SetAlarmView(showsCloseButton: true)
        }
        .onAppear {
            if settingApp.isOpenFromWidget {
                isRelaxingMusicViewPresented = true
            }
        }
        .onChange(of: settingApp.isOpenFromWidget) { newValue in
            if newValue {
                isRelaxingMusicViewPresented = true
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("ATMOSPHERE")
                    .font(LuminousType.label(11, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(LuminousPalette.primary)

                Text("Sound Mixer")
                    .font(LuminousType.display(40, weight: .bold))
                    .foregroundStyle(LuminousPalette.textPrimary)

                Text("Layer textures of the night to craft your own sanctuary.")
                    .font(LuminousType.body(15))
                    .foregroundStyle(LuminousPalette.textSecondary)
            }

            Spacer(minLength: 16)

            VStack(spacing: 12) {
                LuminousIconButton(icon: "alarm.fill", isAccent: true) {
                    Analytics.logEvent("alarm_view_opened", parameters: nil)
                    isShowAlarmViewPresented = true
                }

                LuminousIconButton(icon: "waveform.path.ecg") {
                    Analytics.logEvent("relaxing_music_view_opened", parameters: nil)
                    isRelaxingMusicViewPresented = true
                }
            }
        }
    }

    private var activeMixSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Active channels")
                        .font(LuminousType.headline(24, weight: .bold))
                        .foregroundStyle(LuminousPalette.textPrimary)

                    Text(audioMixer.selectedSounds.isEmpty ? "Choose sounds below to begin." : "Fine tune every layer in your live mix.")
                        .font(LuminousType.body(14))
                        .foregroundStyle(LuminousPalette.textSecondary)
                }

                Spacer()

                if !audioMixer.selectedSounds.isEmpty {
                    Button("Clear all") {
                        withAnimation {
                            audioMixer.resetMixedAudio()
                            audioMixer.selectedSounds.removeAll()
                        }
                    }
                    .buttonStyle(.plain)
                    .font(LuminousType.label(11, weight: .bold))
                    .textCase(.uppercase)
                    .foregroundStyle(LuminousPalette.primary)
                }
            }

            if audioMixer.selectedSounds.isEmpty {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Start with rain, waves, or a soft tonal bed. The dock below can preview and save once the mix feels right.")
                        .font(LuminousType.body(15))
                        .foregroundStyle(LuminousPalette.textSecondary)

                    HStack(spacing: 10) {
                        ForEach(["Rainfall", "Ocean Waves", "Soft Piano"], id: \.self) { name in
                            Text(name)
                                .font(LuminousType.label(11, weight: .bold))
                                .foregroundStyle(LuminousPalette.textPrimary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .luminousGlassCard(cornerRadius: 18, fillColor: LuminousPalette.surfaceLow)
                        }
                    }
                }
                .padding(24)
                .luminousGlassCard(fillColor: LuminousPalette.surfaceLow)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom, spacing: 18) {
                        ForEach($audioMixer.selectedSounds) { $sound in
                            VerticalMixerChannel(sound: $sound)
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .frame(height: 320)
                .padding(.vertical, 10)
                .luminousGlassCard(fillColor: LuminousPalette.surfaceLow, glowColor: LuminousPalette.primary)
            }
        }
    }

    private var categoriesSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories) { category in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = category.name
                        }
                    } label: {
                        LuminousChip(title: category.name, isSelected: selectedCategory == category.name)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var soundLibrarySection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Sound library")
                .font(LuminousType.headline(24, weight: .bold))
                .foregroundStyle(LuminousPalette.textPrimary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 14)], spacing: 14) {
                ForEach(filteredSounds) { sound in
                    SoundButton(sound: sound, audioMixer: audioMixer)
                }
            }
        }
    }

    private var savedMixesSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Saved recipes")
                        .font(LuminousType.headline(24, weight: .bold))
                        .foregroundStyle(LuminousPalette.textPrimary)

                    Text("Jump back into mixes you already trust.")
                        .font(LuminousType.body(14))
                        .foregroundStyle(LuminousPalette.textSecondary)
                }

                Spacer()
            }

            VStack(spacing: 12) {
                ForEach(savedMixes) { mix in
                    SoundMixRow(soundMix: mix) {
                        withAnimation {
                            soundMixManager.removeCombination(soundMix: mix)
                        }
                    }
                }
            }
        }
    }

    private var savedMixes: [SoundMix] {
        let storedMixes = soundMixManager.savedCombinations
        return storedMixes.isEmpty ? soundMixManager.getExampleMixes() : storedMixes
    }
}

struct SoundButton: View {
    let sound: Sound
    @ObservedObject var audioMixer: AudioMixer

    private var isHighlighted: Bool {
        audioMixer.selectedSounds.contains(where: { $0.name == sound.name })
    }

    var body: some View {
        Button {
            if isHighlighted {
                removeSound(sound: sound.audioFile ?? "")
                Analytics.logEvent("sound_removed", parameters: ["sound_name": sound.name])
            } else {
                playSound(sound: sound.audioFile ?? "")
                Analytics.logEvent("sound_selected", parameters: ["sound_name": sound.name])
            }
        } label: {
            VStack(spacing: 12) {
                Image(systemName: sound.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(isHighlighted ? LuminousPalette.primary : LuminousPalette.textPrimary)
                    .frame(width: 52, height: 52)
                    .background(
                        Circle()
                            .fill(LuminousPalette.surfaceHigh)
                            .overlay(Circle().stroke(LuminousPalette.ghostBorder, lineWidth: 1))
                            .shadow(color: isHighlighted ? LuminousPalette.primary.opacity(0.3) : .clear, radius: 16, x: 0, y: 0)
                    )

                Text(sound.name)
                    .font(LuminousType.body(12, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(isHighlighted ? LuminousPalette.textPrimary : LuminousPalette.textSecondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 130)
            .padding(.horizontal, 10)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(isHighlighted ? LuminousPalette.surfaceContainer.opacity(0.98) : LuminousPalette.surfaceLow.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(isHighlighted ? LuminousPalette.primary.opacity(0.45) : LuminousPalette.ghostBorder, lineWidth: 1)
                    )
                    .shadow(color: isHighlighted ? LuminousPalette.primary.opacity(0.22) : .clear, radius: 18, x: 0, y: 10)
            )
        }
        .buttonStyle(.plain)
    }

    private func playSound(sound: String) {
        if audioMixer.isPlaySaved {
            audioMixer.resetMixedAudio()
        }

        audioMixer.loadAudioFile(sound)
        audioMixer.selectedSounds.append(self.sound)
        audioMixer.playMixedAudio()
    }

    private func removeSound(sound: String) {
        audioMixer.removeAudioFile(sound)
        audioMixer.selectedSounds.removeAll { $0.id == self.sound.id }
    }
}

private struct VerticalMixerChannel: View {
    @Binding var sound: Sound

    var body: some View {
        VStack(spacing: 12) {
            VerticalFader(value: $sound.volume)
                .frame(width: 92, height: 220)

            VStack(spacing: 6) {
                Image(systemName: sound.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(LuminousPalette.primary)

                Text(sound.name.uppercased())
                    .font(LuminousType.label(10, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(LuminousPalette.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 92)
        }
        .onChange(of: sound.volume) { newValue in
            syncVolume(newValue)
        }
    }

    private func syncVolume(_ value: Double) {
        guard let index = AudioMixer.shared.selectedSounds.firstIndex(where: { $0.id == sound.id }) else { return }
        AudioMixer.shared.setVolume(forTrack: index, volume: Float(value))
    }
}

private struct VerticalFader: View {
    @Binding var value: Double

    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let thumbSize: CGFloat = 26
            let progress = max(0, min(1, value))
            let y = (1 - progress) * (height - thumbSize)

            ZStack(alignment: .top) {
                Capsule(style: .continuous)
                    .fill(LuminousPalette.surfaceHigh.opacity(0.72))

                VStack {
                    Spacer(minLength: y)

                    Capsule(style: .continuous)
                        .fill(LuminousPalette.primaryGradient)
                        .frame(height: height - y)
                        .shadow(color: LuminousPalette.primary.opacity(0.28), radius: 24, x: 0, y: 0)
                }

                Circle()
                    .fill(Color.white)
                    .frame(width: thumbSize, height: thumbSize)
                    .shadow(color: LuminousPalette.primary.opacity(0.3), radius: 20, x: 0, y: 0)
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

struct ZenMusicView_Previews: PreviewProvider {
    static var previews: some View {
        ZenMusicView()
    }
}
