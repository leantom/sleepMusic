//
//  ContentView.swift
//  SleepMusic
//
//  Created by QuangHo on 14/10/24.
//

import SwiftUI
import FirebaseCore


struct ContentView: View {
    var body: some View {
        ZenMusicView()
    }
}

extension Notification.Name {
    static let openTrackFromWidget = Notification.Name("openTrackFromWidget")
}

#Preview {
    ContentView()
}
