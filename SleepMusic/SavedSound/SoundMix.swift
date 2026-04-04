//
//  SoundMix.swift
//  SleepMusic
//
//  Created by QuangHo on 16/10/24.
//
import Foundation

struct SoundMix: Identifiable, Codable {
    var id = UUID()
    var name: String
    var sounds: [Sound]
    var dateSaved: Date
    init(id: UUID = UUID(), name: String, sounds: [Sound], dateSaved: Date = Date()) {
        self.id = id
        self.name = name
        self.sounds = sounds
        self.dateSaved = dateSaved
    }
}

class SoundMixManager: ObservableObject {
    static let shared = SoundMixManager()
    
    @Published var savedCombinations: [SoundMix] = []
    
    private let key = "savedSoundMixes"
    
    init() {
        load()
    }
    //MARK: - Load saved mixes from UserDefaults
    func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let combinations = try? JSONDecoder().decode([SoundMix].self, from: data) {
            self.savedCombinations = combinations
        } else {
            self.savedCombinations = []
        }
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(savedCombinations) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func addCombination(_ combination: SoundMix) {
        savedCombinations.append(combination)
        save()
    }
    
    func removeCombination(at offsets: IndexSet) {
        savedCombinations.remove(atOffsets: offsets)
        save()
    }
    
    func removeCombination(soundMix: SoundMix) {
        savedCombinations.removeAll { sound in
            return sound.id == soundMix.id
        }
        save()
    }
    
    /// Generates a specified number of suggested mixes.
    func generateSuggestedMixes(count: Int = 3) -> [SoundMix] {
        var suggestions: [SoundMix] = []
        // Exclude the "All" category since it’s empty or not specific.
        let categories = SoundCategory.getCategories().filter { $0.name != "All" }
        
        for i in 0..<count {
            var mixSounds: [Sound] = []
            
            // For each category, try to pick a random sound.
            for category in categories {
                if let randomSound = category.sounds.randomElement() {
                    mixSounds.append(randomSound)
                }
            }
            
            // Create a new mix with a default name (you can allow the user to rename later)
            let mixName = "Suggested Mix \(i + 1)"
            let newMix = SoundMix(name: mixName, sounds: mixSounds)
            suggestions.append(newMix)
        }
        
        return suggestions
    }
    
}

extension SoundMixManager {
    /// Returns 5 example, meaningful sound mixes based on your sound categories.
    func getExampleMixes() -> [SoundMix] {
        // Force unwrapping is safe here because we know the sounds exist in the predefined lists.
        let mix1 = SoundMix(name: "Deep Forest Meditation", sounds: [
            // Nature: Forest Sounds
            SoundCategory.natureSounds.sounds.first(where: { $0.name == "Forest Sounds" })!,
            // Instrumental: Ambient Pads
            SoundCategory.instrumentalMusic.sounds.first(where: { $0.name == "Ambient Pads" })!,
            // Meditation: Tibetan Singing Bowls
            SoundCategory.meditationSounds.sounds.first(where: { $0.name == "Tibetan Singing Bowls" })!,
            // White/Pink Noise: Pink Noise
            SoundCategory.whitePinkNoise.sounds.first(where: { $0.name == "Pink Noise" })!,
            // Binaural Beats: Theta Binaural Beats
            SoundCategory.binauralBeats.sounds.first(where: { $0.name == "Theta Binaural Beats" })!
        ])
        
        let mix2 = SoundMix(name: "Oceanic Chill", sounds: [
            // Nature: Ocean Waves
            SoundCategory.natureSounds.sounds.first(where: { $0.name == "Ocean Waves" })!,
            // Instrumental: Soft Piano
            SoundCategory.instrumentalMusic.sounds.first(where: { $0.name == "Soft Piano" })!,
            // Meditation: Chimes
            SoundCategory.meditationSounds.sounds.first(where: { $0.name == "Chimes" })!,
            // White/Pink Noise: White Noise
            SoundCategory.whitePinkNoise.sounds.first(where: { $0.name == "White Noise" })!,
            // Binaural Beats: Delta Binaural Beats
            SoundCategory.binauralBeats.sounds.first(where: { $0.name == "Delta Binaural Beats" })!
        ])
        
        let mix3 = SoundMix(name: "Rainy Day Serenity", sounds: [
            // Nature: Rainfall
            SoundCategory.natureSounds.sounds.first(where: { $0.name == "Rainfall" })!,
            // Instrumental: Acoustic Guitar
            SoundCategory.instrumentalMusic.sounds.first(where: { $0.name == "Acoustic Guitar" })!,
            // Meditation: Tibetan Singing Bowls
            SoundCategory.meditationSounds.sounds.first(where: { $0.name == "Tibetan Singing Bowls" })!,
            // White/Pink Noise: Brown Noise
            SoundCategory.whitePinkNoise.sounds.first(where: { $0.name == "Brown Noise" })!,
            // Binaural Beats: Theta Binaural Beats
            SoundCategory.binauralBeats.sounds.first(where: { $0.name == "Theta Binaural Beats" })!
        ])
        
        let mix4 = SoundMix(name: "Windy Ambient", sounds: [
            // Nature: Wind
            SoundCategory.natureSounds.sounds.first(where: { $0.name == "Wind" })!,
            // Instrumental: Ambient Pads
            SoundCategory.instrumentalMusic.sounds.first(where: { $0.name == "Ambient Pads" })!,
            // Meditation: Chimes
            SoundCategory.meditationSounds.sounds.first(where: { $0.name == "Chimes" })!,
            // White/Pink Noise: Pink Noise
            SoundCategory.whitePinkNoise.sounds.first(where: { $0.name == "Pink Noise" })!,
            // Binaural Beats: Delta Binaural Beats
            SoundCategory.binauralBeats.sounds.first(where: { $0.name == "Delta Binaural Beats" })!
        ])
        
        let mix5 = SoundMix(name: "Stream of Consciousness", sounds: [
            // Nature: Water Stream
            SoundCategory.natureSounds.sounds.first(where: { $0.name == "Water Stream" })!,
            // Instrumental: Harp
            SoundCategory.instrumentalMusic.sounds.first(where: { $0.name == "Harp" })!,
            // Meditation: Tibetan Singing Bowls
            SoundCategory.meditationSounds.sounds.first(where: { $0.name == "Tibetan Singing Bowls" })!,
            // White/Pink Noise: White Noise
            SoundCategory.whitePinkNoise.sounds.first(where: { $0.name == "White Noise" })!,
            // Binaural Beats: Delta Binaural Beats
            SoundCategory.binauralBeats.sounds.first(where: { $0.name == "Delta Binaural Beats" })!
        ])
        
        return [mix1, mix2, mix3, mix4, mix5]
    }
}
