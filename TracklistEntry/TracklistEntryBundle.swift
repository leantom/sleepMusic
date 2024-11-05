//
//  TracklistEntryBundle.swift
//  TracklistEntry
//
//  Created by QuangHo on 31/10/24.
//

import WidgetKit
import SwiftUI

@main
struct TracklistEntryBundle: WidgetBundle {
    var body: some Widget {
        TracklistEntry()
        TracklistEntryControl()
        TracklistEntryLiveActivity()
    }
}
