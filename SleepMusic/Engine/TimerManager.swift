//
//  TimerManager.swift
//  SleepMusic
//
//  Created by QuangHo on 18/10/24.
//

import Foundation

class TimerManager: ObservableObject {
    static let shared = TimerManager()
    private var timer: Timer?
    private var fadeOutTimer: Timer?

    func startTimer(duration: TimeInterval, fadeOutDuration: TimeInterval) {
        stopTimer() // Ensure any existing timer is invalidated

        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            self.startFadeOut(duration: fadeOutDuration)
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        fadeOutTimer?.invalidate()
        fadeOutTimer = nil
    }

    private func startFadeOut(duration: TimeInterval) {
        let fadeSteps = 20 // Number of volume adjustments during fade-out
        let stepDuration = duration / Double(fadeSteps)
        var currentStep = 0

        fadeOutTimer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
            currentStep += 1
            let newVolume = max(0, 1.0 - Float(currentStep) / Float(fadeSteps))
            AudioMixer.shared.setVolume(volume: newVolume)

            if newVolume <= 0 {
                timer.invalidate()
                AudioMixer.shared.stopMixedAudio()
            }
        }
    }
}
