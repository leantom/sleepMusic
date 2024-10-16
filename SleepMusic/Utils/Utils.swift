//
//  Utils.swift
//  SleepMusic
//
//  Created by QuangHo on 16/10/24.
//

import Foundation

func formatSecondsToHoursMinutes(_ seconds: Int) -> String {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    
    if hours > 0 {
        return "\(hours) hr \(minutes) min"
    } else {
        return "\(minutes) min"
    }
}
