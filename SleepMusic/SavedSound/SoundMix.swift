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
    
}
