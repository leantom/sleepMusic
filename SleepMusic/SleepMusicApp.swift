//
//  SleepMusicApp.swift
//  SleepMusic
//
//  Created by QuangHo on 14/10/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseRemoteConfig
@main
struct SleepMusicApp: App {
    
    @State private var showUpdateAlert = false
    @State private var remoteConfigVersion = "1.0"
    
    init () {
        
        FirebaseApp.configure()
        autoSignIn()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    fetchRemoteConfig()
                }
                .alert(isPresented: $showUpdateAlert) {
                    Alert(
                        title: Text("Update Required"),
                        message: Text("A new version of the app is available. Please update to continue."),
                        dismissButton: .default(Text("Update"), action: {
                            // Redirect to App Storehttps://apps.apple.com/vn/app/1980s-retro/
                            if let url = URL(string: "itms-apps://apple.com/app/id6737064279") {
                                UIApplication.shared.open(url)
                            }
                        })
                    )
                }
        }
    }
    
    func fetchRemoteConfig() {
        let remoteConfig = RemoteConfig.remoteConfig()
        
        // Configure settings
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600 // Fetch every hour
        remoteConfig.configSettings = settings
        
        remoteConfig.fetch { status, error in
            if status == .success {
                remoteConfig.activate { changed, error in
                    if let error = error {
                        print("Error activating Remote Config: \(error.localizedDescription)")
                        return
                    }
                    let minimumVersion = remoteConfig.configValue(forKey: "min_required_version").stringValue
                    self.remoteConfigVersion = minimumVersion
                    checkForUpdate(minimumRequiredVersion: minimumVersion)
                }
            } else {
                print("Error fetching Remote Config: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func checkForUpdate(minimumRequiredVersion: String) {
        let currentVersion = getCurrentAppVersion()
        if isUpdateRequired(currentVersion: currentVersion, minimumVersion: minimumRequiredVersion) {
            DispatchQueue.main.async {
                self.showUpdateAlert = true
            }
        }
    }
    
    func getCurrentAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return version ?? "0"
    }
    func isUpdateRequired(currentVersion: String, minimumVersion: String) -> Bool {
        let currentComponents = currentVersion.split(separator: ".").compactMap { Int($0) }
        let minimumComponents = minimumVersion.split(separator: ".").compactMap { Int($0) }

        let maxCount = max(currentComponents.count, minimumComponents.count)

        for i in 0..<maxCount {
            let current = i < currentComponents.count ? currentComponents[i] : 0
            let minimum = i < minimumComponents.count ? minimumComponents[i] : 0

            if current < minimum {
                return true
            } else if current > minimum {
                return false
            }
        }
        return false
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
