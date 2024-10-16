//
//  SleepMusicApp.swift
//  SleepMusic
//
//  Created by QuangHo on 14/10/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct SleepMusicApp: App {
    init () {
        
        FirebaseApp.configure()
        autoSignIn()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    func autoSignIn() {
           if Auth.auth().currentUser == nil {
               // If the user is not signed in, sign them in anonymously
               Auth.auth().signInAnonymously { authResult, error in
                   if let error = error {
                       print("Error signing in anonymously: \(error.localizedDescription)")
                   } else {
                       print("User signed in anonymously: \(String(describing: authResult?.user.uid))")
                   }
               }
           } else {
               print("User already signed in: \(String(describing: Auth.auth().currentUser?.uid))")
           }
       }
}
