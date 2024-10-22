//
//  ContentView.swift
//  SleepMusic
//
//  Created by QuangHo on 14/10/24.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    
      
    return true
  }
}
struct ContentView: View {
    var body: some View {
        ZenMusicView()
    }
}

#Preview {
    ContentView()
}
