import SwiftUI
import FirebaseCore

struct ContentView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content area based on selected tab
            Group {
                switch selectedTab {
                case 0:
                    SleepMusicView() // The newly designed home screen
                case 1:
                    ZenMusicView() // Existing mixer view
                case 2:
                    SetAlarmView() // Existing sleep/alarm view
                case 3:
                    // Profile placeholder
                    ZStack {
                        Color(red: 0.06, green: 0.06, blue: 0.08).edgesIgnoringSafeArea(.all)
                        Text("Profile View")
                            .foregroundColor(.white)
                    }
                default:
                    SleepMusicView()
                }
            }
            // Ensure content doesn't get hidden behind custom tab bar
            .padding(.bottom, 60)
            
            // Custom Dark Tab Bar
            HStack(spacing: 0) {
                TabBarButton(icon: "music.note", title: "LISTEN", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                TabBarButton(icon: "slider.horizontal.3", title: "MIXER", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                TabBarButton(icon: "alarm.fill", title: "SLEEP", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
                TabBarButton(icon: "person.fill", title: "PROFILE", isSelected: selectedTab == 3) {
                    selectedTab = 3
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 25) // SafeArea equivalent for bottom
            .background(
                Color(red: 0.06, green: 0.06, blue: 0.08)
                    .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: -5)
            )
            .edgesIgnoringSafeArea(.bottom)
        }
        .edgesIgnoringSafeArea(.bottom) // Remove bottom safe area logic so tab bar sticks to bottom
    }
}

struct TabBarButton: View {
    var icon: String
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? Color(red: 0.7, green: 0.5, blue: 0.9) : .gray)
                Text(title)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(isSelected ? Color(red: 0.7, green: 0.5, blue: 0.9) : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

extension Notification.Name {
    static let openTrackFromWidget = Notification.Name("openTrackFromWidget")
}

#Preview {
    ContentView()
}
