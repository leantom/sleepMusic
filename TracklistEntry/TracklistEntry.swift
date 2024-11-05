import WidgetKit
import SwiftUI
import Firebase
struct LikedTracklistEntry: TimelineEntry {
    let date: Date
    let likedTracks: [Track] // Ensure Track conforms to Codable for shared data
}

struct LikedTracklistProvider: AppIntentTimelineProvider {
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> LikedTracklistEntry {
        return  LikedTracklistEntry(date: Date(), likedTracks: [])
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<LikedTracklistEntry> {
        FirebaseApp.configure()
        let likedTracks = TracklistManager.shared.likedTracks()
        let entry = LikedTracklistEntry(date: Date(), likedTracks: likedTracks)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        return timeline
    }
    
    typealias Intent = ConfigurationAppIntent
    typealias Entry = LikedTracklistEntry
    
    func placeholder(in context: Context) -> LikedTracklistEntry {
        LikedTracklistEntry(date: Date(), likedTracks: [])
    }

}

struct TracklistEntryEntryView: View {
    var entry: LikedTracklistProvider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)
            
            Text("Favorite Emoji:")
            // Add more UI elements as needed for displaying the liked tracks
        }
    }
}

struct TracklistEntry: Widget {
    let kind: String = "TracklistEntry"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind,
                               intent: ConfigurationAppIntent.self,
                               provider: LikedTracklistProvider()) { entry in
            LikedTracklistWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
                               .configurationDisplayName("Liked Tracks")
                               .description("View and play your liked tracks")
    }
}


#Preview(as: .systemSmall) {
    TracklistEntry()
} timeline: {
    LikedTracklistEntry(date: .now, likedTracks: []) // Replace SimpleEntry with LikedTracklistEntry
       LikedTracklistEntry(date: .now, likedTracks: []) // Adjust likedTracks as needed

}
