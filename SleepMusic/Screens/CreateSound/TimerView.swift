import SwiftUI

struct TimerSettingsView: View {
    @State private var selectedDuration: Int = 7 * 60 * 60
    @State private var fadeOutDuration: Double = 30
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            LuminousBackground()

            VStack(alignment: .leading, spacing: 22) {
                HStack {
                    LuminousIconButton(icon: "xmark") {
                        isPresented = false
                    }

                    Spacer()

                    Button("Save") {
                        AudioMixer.shared.restartMixedAudio()
                        TimerManager.shared.startTimer(
                            duration: TimeInterval(selectedDuration),
                            fadeOutDuration: fadeOutDuration
                        )
                        isPresented = false
                    }
                    .buttonStyle(.plain)
                    .font(LuminousType.label(11, weight: .bold))
                    .textCase(.uppercase)
                    .foregroundStyle(LuminousPalette.primary)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("SLEEP TIMER")
                        .font(LuminousType.label(11, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(LuminousPalette.secondary)

                    Text("Wind Down")
                        .font(LuminousType.display(34, weight: .bold))
                        .foregroundStyle(LuminousPalette.textPrimary)

                    Text("Fade the mix out at exactly the point your night needs it.")
                        .font(LuminousType.body(15))
                        .foregroundStyle(LuminousPalette.textSecondary)
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text("Timer duration")
                        .font(LuminousType.headline(22, weight: .bold))
                        .foregroundStyle(LuminousPalette.textPrimary)

                    Picker("", selection: $selectedDuration) {
                        ForEach(1..<24, id: \.self) { hour in
                            Text("\(hour) hr").tag(hour * 3600)
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .luminousGlassCard(cornerRadius: 28, fillColor: LuminousPalette.surfaceLow)
                }

                FadeOutSettingsView(fadeOutDuration: $fadeOutDuration)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .padding(.bottom, 24)
        }
    }
}

struct FadeOutSettingsView: View {
    @Binding var fadeOutDuration: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Fade out")
                .font(LuminousType.headline(22, weight: .bold))
                .foregroundStyle(LuminousPalette.textPrimary)

            VStack(alignment: .leading, spacing: 12) {
                Slider(value: $fadeOutDuration, in: 10...60, step: 10)
                    .tint(LuminousPalette.primary)

                Text("\(Int(fadeOutDuration)) seconds")
                    .font(LuminousType.body(14))
                    .foregroundStyle(LuminousPalette.textSecondary)
            }
            .padding(18)
            .luminousGlassCard(cornerRadius: 24, fillColor: LuminousPalette.surfaceLow)
        }
    }
}

struct TimeSettingsViewTests: View {
    @State var isPresented = false

    var body: some View {
        TimerSettingsView(isPresented: $isPresented)
    }
}

#Preview {
    TimeSettingsViewTests()
}
