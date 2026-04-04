import SwiftUI
import FirebaseAnalytics
import GoogleMobileAds

enum SelectedTab: String, CaseIterable {
    case sounds = "Sounds"
    case recommended = "Recommended"
}

struct ZenMusicView: View {
    @ObservedObject var soundMixManager = SoundMixManager.shared
    @State private var isSaveCombinationViewPresented = false
    @ObservedObject var audioMixer: AudioMixer = AudioMixer.shared
    let categories = SoundCategory.getCategories()
    @State private var inputText: String = ""
    @ObservedObject var settingApp = AppSetting.shared
    @State var isAnimateBlink = false
    
    // Filtered sounds based on selected category
    var filteredSounds: [Sound] {
        if selectedCategory == "All" {
            return SoundCategory.getAllSounds()
        }
        if let category = categories.first(where: { $0.name == selectedCategory }) {
            return category.sounds
        } else {
            return categories.flatMap { $0.sounds }
        }
    }
    var adSizeGlobal: GADAdSize = GADAdSize(size: CGSize(width: UIScreen.main.bounds.width, height: 60), flags: 1)
    
    // Using enum for tab selection
    @State private var selectedTab: SelectedTab = .sounds
    @State private var selectedCategory = "All"
    @State private var isControlPanelVisible: Bool = true
    @State private var animateOffset: CGFloat = 0
    @State var isRelaxingMusicViewPresented = false
    @State private var isShowAlarmViewPresented = false
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.black]),
                           startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                .overlay {
                    Image("bg_create_sound")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                }
            
            VStack {
                Spacer()
                
                VStack {
                    HStack {
                        Button {
                            withAnimation {
                                Analytics.logEvent("alarm_view_opened", parameters: nil)
                                isShowAlarmViewPresented.toggle()
                            }
                        } label: {
                            Image(systemName: "alarm.waves.left.and.right.fill")
                                .font(.system(size: 23))
                                .foregroundStyle(.white)
                                .frame(width: 35, height: 35)
                        }
                        .padding()
                        
                        Spacer()
                        
                        Text(getRandomSleepSentence())
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .padding()
                    }
                    
                    HStack(spacing: 0) {
                        // Sounds Button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTab = .sounds
                                Analytics.logEvent("tab_selected", parameters: ["tab": SelectedTab.sounds.rawValue])
                            }
                        }) {
                            ZStack {
                                Rectangle()
                                    .fill(selectedTab == .sounds ? Color.purple : Color.clear)
                                    .cornerRadius(20)
                                    .opacity(selectedTab == .sounds ? 1 : 0)
                                    .offset(x: selectedTab == .sounds ? 0 : 200)
                                
                                Text(SelectedTab.sounds.rawValue)
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    .foregroundColor(selectedTab == .sounds ? .white : .gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                        }
                        
                        Spacer().frame(width: 10)
                        
                        // Recommended Button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTab = .recommended
                                Analytics.logEvent("tab_selected", parameters: ["tab": SelectedTab.recommended.rawValue])
                            }
                        }) {
                            ZStack {
                                Rectangle()
                                    .fill(selectedTab == .recommended ? Color.purple : Color.clear)
                                    .cornerRadius(20)
                                    .opacity(selectedTab == .recommended ? 1 : 0)
                                    .offset(x: selectedTab == .recommended ? 0 : -200)
                                
                                Text(SelectedTab.recommended.rawValue)
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    .foregroundColor(selectedTab == .recommended ? .white : .gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.2))
                    )
                    .frame(height: 48)
                    .padding(.horizontal)
                }
                .padding(.top, 44)
                
                // MARK: Horizontal category selection
                ScrollView(.vertical) {
                    VStack {
                        ScrollView(.horizontal, showsIndicators: false) {
                            // Display categories only for Sounds tab
                            if selectedTab == .recommended {
                                HStack {
                                    Text("Your Saved Mix Sounds")
                                        .font(.system(size: 14, weight: .medium))
                                        .padding(.horizontal)
                                        .foregroundStyle(.white)
                                }
                            } else {
                                HStack(spacing: 16) {
                                    ForEach(categories) { category in
                                        Button(action: {
                                            withAnimation {
                                                selectedCategory = category.name
                                            }
                                        }) {
                                            Text(category.name)
                                                .font(.system(size: 14, weight: .regular, design: .monospaced))
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(selectedCategory == category.name ? Color.purple : Color.clear)
                                                .foregroundColor(selectedCategory == category.name ? .white : .gray)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(Color.purple, lineWidth: 1)
                                                )
                                                .cornerRadius(20)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding()
                        
                        // MARK: Sound Option Buttons or Saved Mixes
                        if selectedTab == .recommended {
                            VStack(spacing: 10) {
                                if soundMixManager.savedCombinations.isEmpty {
                                    ForEach(soundMixManager.getExampleMixes()) { mix in
                                        SoundMixRow(soundMix: mix, onDelete: {
                                            delete(soundMix: mix)
                                        })
                                        .transition(.fade)
                                    }
                                } else {
                                    ForEach(soundMixManager.savedCombinations) { track in
                                        SoundMixRow(soundMix: track, onDelete: {
                                            delete(soundMix: track)
                                        })
                                        .transition(.fade)
                                    }
                                }
                            }
                            .padding()
                            .animation(.easeInOut)
                        } else {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 20) {
                                ForEach(filteredSounds) { sound in
                                    SoundButton(sound: sound, audioMixer: audioMixer)
                                }
                            }
                            .padding()
                            .animation(.easeInOut)
                        }
                        
                        Spacer()
                    }
                }
                
                Spacer()
            }
            
            // Bottom control panel and banner view
            VStack {
                Spacer()
                CollapsibleControlPanel(audioMixer: audioMixer,
                                          isRelaxingMusicViewPresented: $isRelaxingMusicViewPresented,
                                          isSavedViewPresented: $isSaveCombinationViewPresented)
                    .padding()
                // Show BannerView if tab is Recommended or a specific category is selected (i.e. not "All")
                if selectedTab == .recommended || selectedCategory != "All" {
                    BannerView(adSizeGlobal)
                        .frame(height: 50)
                }
            }
        }
        .fullScreenCover(isPresented: $isRelaxingMusicViewPresented) {
            RelaxingMusicView()
        }
        .fullScreenCover(isPresented: $isShowAlarmViewPresented) {
            SetAlarmView()
        }
        .sheet(isPresented: $isSaveCombinationViewPresented) {
            SleepMixView(sounds: $audioMixer.selectedSounds)
                .presentationBackground(Color.clear)
                .presentationBackgroundInteraction(.disabled)
        }
        .onAppear {
            isRelaxingMusicViewPresented = AppSetting.shared.isOpenFromWidget
            Task {
                try await TracklistManager.shared.fetchTracklist()
            }
        }
        .onChange(of: settingApp.isOpenFromWidget) { newValue in
            if newValue {
                isRelaxingMusicViewPresented = newValue
            }
        }
    }
    
    private func delete(soundMix: SoundMix) {
        withAnimation {
            SoundMixManager.shared.removeCombination(soundMix: soundMix)
        }
    }
    
    func getRandomSleepSentence() -> String {
        let sentences = [
            "Press play and let the snooze begin.",
            "Making bedtime your favorite time.",
            "Because your brain deserves a break too.",
            "The ultimate 'Do Not Disturb' mode.",
            "Drifting into dreams, one sound at a time.",
            "No sheep were harmed in the making of this sleep aid.",
            "Sounds so good, even your insomnia is impressed.",
            "Turn your night into a peaceful symphony.",
            "Dream like you mean it.",
            "For those nights when silence is just too loud.",
            "Helping you sleep harder than a rock.",
            "Your personal DJ for dreamland.",
            "Why fight sleep when you can embrace it?",
            "The best lullaby is the one you don’t remember.",
            "Soft sounds, deep dreams, no stress."
        ]
        return sentences.randomElement() ?? "Sweet dreams, sleep tight!"
    }
}

struct SoundButton: View {
    let sound: Sound
    @ObservedObject var audioMixer: AudioMixer
    
    var isHighlighted: Bool {
        audioMixer.selectedSounds.contains(where: { $0.name == sound.name })
    }
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: isHighlighted ? [Color.purple.opacity(0.6), Color.gray.opacity(0.1)] : [Color.gray.opacity(0.3), Color.gray.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: isHighlighted ? min(100 - dragOffset.height, 100) : 100)
                    .cornerRadius(10)
                    .shadow(radius: 10)
            }
            Button(action: {
                if isHighlighted {
                    removeSound(sound: sound.audioFile ?? "")
                    Analytics.logEvent("sound_removed", parameters: [
                        "sound_name": sound.name
                    ])
                } else {
                    playSound(sound: sound.audioFile ?? "")
                    Analytics.logEvent("sound_selected", parameters: [
                        "sound_name": sound.name
                    ])
                }
            }) {
                VStack(spacing: 10) {
                    Image(systemName: sound.icon)
                        .font(.system(size: 20))
                        .foregroundColor(isHighlighted ? .white : .gray)
                    Text(sound.name)
                        .foregroundColor(isHighlighted ? .white : .gray)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                }
                .frame(width: 80, height: 100)
                .cornerRadius(12)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            self.dragOffset = CGSize(width: 0, height: gesture.translation.height)
                        }
                        .onEnded { _ in }
                )
            }
        }
        .frame(height: 100)
    }
    
    func playSound(sound: String) {
        if audioMixer.isPlaySaved {
            audioMixer.resetMixedAudio()
        }
        audioMixer.loadAudioFile(sound)
        audioMixer.selectedSounds.append(self.sound)
        audioMixer.playMixedAudio()
    }
    
    func removeSound(sound: String) {
        audioMixer.removeAudioFile(sound)
        audioMixer.selectedSounds.removeAll { $0.id == self.sound.id }
    }
}

struct ZenMusicView_Previews: PreviewProvider {
    static var previews: some View {
        ZenMusicView()
    }
}
