//
//  TracklistEntryLiveActivity.swift
//  TracklistEntry
//
//  Created by QuangHo on 31/10/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TracklistEntryAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct TracklistEntryLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TracklistEntryAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension TracklistEntryAttributes {
    fileprivate static var preview: TracklistEntryAttributes {
        TracklistEntryAttributes(name: "World")
    }
}

extension TracklistEntryAttributes.ContentState {
    fileprivate static var smiley: TracklistEntryAttributes.ContentState {
        TracklistEntryAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: TracklistEntryAttributes.ContentState {
         TracklistEntryAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: TracklistEntryAttributes.preview) {
   TracklistEntryLiveActivity()
} contentStates: {
    TracklistEntryAttributes.ContentState.smiley
    TracklistEntryAttributes.ContentState.starEyes
}
