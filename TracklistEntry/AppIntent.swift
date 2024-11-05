//
//  AppIntent.swift
//  TracklistEntry
//
//  Created by QuangHo on 31/10/24.
//

import WidgetKit
import AppIntents
import SwiftUI
import UIKit

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    init() {
        
    }
    
    static var title: LocalizedStringResource = "Open Track"
    static var description = IntentDescription("Open a specific track in the app")

    @Parameter(title: "Track ID")
    var trackID: String?
    
    func perform() async throws -> some IntentResult {
        
        return .result()
    }
}

extension Notification.Name {
    static let openTrackFromWidget = Notification.Name("openTrackFromWidget")
}
