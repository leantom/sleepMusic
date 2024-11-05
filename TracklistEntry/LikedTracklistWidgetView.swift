import SwiftUI
import WidgetKit
import AppIntents

struct LikedTracklistWidgetView: View {
    var entry: LikedTracklistProvider.Entry

    
    var deeplinkURL = "widget-deeplink://"

    var body: some View {
        if let firstTrack = entry.likedTracks.randomElement(), let trackID = firstTrack.id {
            HStack {
                Image("img_2")
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading) {
                    Text(firstTrack.name)
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                    if let tracklist = TracklistManager.shared.getTracklist(by: firstTrack.tracklistID ?? "") {
                        Text(tracklist.title)
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                    }
                }
                
                Spacer()
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 25))
                    .foregroundColor(.pink)
            }
            .widgetURL(URL(string: deeplinkURL.appending(trackID.description))!)
        
            
        } else {
            // Handle the case where there are no liked tracks
            Text("No liked tracks available.")
        }
    }
    
    
    func handleURL(_ url: URL) {
           guard url.scheme == "sleepMusic",
                 let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                 let host = components.host else { return }
           
           switch host {
           case "track":
               if let id = components.queryItems?.first(where: { $0.name == "id" })?.value {
                   // Navigate to the specific track using the id
               }
           default:
               break
           }
       }
    
}
