import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .listen

    var body: some View {
        ZStack {
            LuminousBackground()

            currentScreen
        }
        .safeAreaInset(edge: .bottom) {
            LuminousTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 16)

        }
    }

    @ViewBuilder
    private var currentScreen: some View {
        switch selectedTab {
        case .listen:
            SleepMusicView()
        case .mixer:
            ZenMusicView()
        case .sleep:
            SetAlarmView(showsCloseButton: false)
        case .profile:
            ProfilePlaceholderView()
        }
    }
}

private enum AppTab: String, CaseIterable, Identifiable {
    case listen
    case mixer
    case sleep
    case profile

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .listen:
            return "music.note"
        case .mixer:
            return "slider.horizontal.3"
        case .sleep:
            return "alarm"
        case .profile:
            return "person.fill"
        }
    }

    var title: String {
        rawValue.uppercased()
    }
}

private struct LuminousTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 8) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 17, weight: .semibold))
                        Text(tab.title)
                            .font(LuminousType.label(9, weight: .bold))
                            .tracking(0.8)
                    }
                    .foregroundStyle(selectedTab == tab ? LuminousPalette.primary : LuminousPalette.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(selectedTab == tab ? LuminousPalette.surfaceHigh.opacity(0.95) : .clear)
                            .shadow(
                                color: selectedTab == tab ? LuminousPalette.primary.opacity(0.18) : .clear,
                                radius: 18,
                                x: 0,
                                y: 0
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .luminousGlassCard(cornerRadius: 28, fillColor: LuminousPalette.surfaceContainer)
    }
}

private struct ProfilePlaceholderView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PROFILE")
                            .font(LuminousType.label(11, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(LuminousPalette.secondary)

                        Text("Night Rituals")
                            .font(LuminousType.display(34, weight: .bold))
                            .foregroundStyle(LuminousPalette.textPrimary)
                    }

                    Spacer()

                    Circle()
                        .fill(LuminousPalette.primaryGradient)
                        .frame(width: 52, height: 52)
                        .overlay(
                            Image(systemName: "moon.stars.fill")
                                .foregroundStyle(Color(red: 64 / 255, green: 18 / 255, blue: 116 / 255))
                        )
                }

                VStack(alignment: .leading, spacing: 18) {
                    Text("A calming profile space can live here once account features are ready.")
                        .font(LuminousType.body(16))
                        .foregroundStyle(LuminousPalette.textSecondary)

                    Text("The shell is already aligned to the new design system so future profile work can reuse the same surfaces and typography.")
                        .font(LuminousType.body(15))
                        .foregroundStyle(LuminousPalette.textSecondary)
                }
                .padding(24)
                .luminousGlassCard(fillColor: LuminousPalette.surfaceLow)

                Spacer(minLength: 140)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
}

extension Notification.Name {
    static let openTrackFromWidget = Notification.Name("openTrackFromWidget")
}

#Preview {
    ContentView()
}
