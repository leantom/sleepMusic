import SwiftUI

struct AlarmSoundSelectionView: View {
    @Binding var selectedAlarm: String
    @ObservedObject var alarmViewModel: AlarmSoundViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LuminousBackground()

            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("WAKE TONES")
                            .font(LuminousType.label(11, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(LuminousPalette.secondary)

                        Text("Select Alarm Sound")
                            .font(LuminousType.display(32, weight: .bold))
                            .foregroundStyle(LuminousPalette.textPrimary)
                    }

                    Spacer()

                    LuminousIconButton(icon: "xmark") {
                        AudioPlayer.shared.stopPlayAlarm()
                        dismiss()
                    }
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(alarmViewModel.alarmSounds, id: \.id) { alarm in
                            Button {
                                selectedAlarm = alarm.name
                                alarmViewModel.playSound(alarmSound: alarm)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(alarm.name)
                                            .font(LuminousType.body(15, weight: .semibold))
                                            .foregroundStyle(LuminousPalette.textPrimary)

                                        Text(alarm.name == selectedAlarm ? "Selected for wake up" : "Tap to preview")
                                            .font(LuminousType.body(13))
                                            .foregroundStyle(LuminousPalette.textSecondary)
                                    }

                                    Spacer()

                                    Image(systemName: alarm.name == selectedAlarm ? "checkmark.circle.fill" : "play.circle")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundStyle(alarm.name == selectedAlarm ? LuminousPalette.success : LuminousPalette.primary)
                                }
                                .padding(18)
                                .luminousGlassCard(cornerRadius: 24, fillColor: LuminousPalette.surfaceLow)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 12)
                }

                LuminousPrimaryButton(title: "Done") {
                    AudioPlayer.shared.stopPlayAlarm()
                    dismiss()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .padding(.bottom, 24)
        }
        .onAppear {
            AudioPlayer.shared.isPlayAlarm = true
        }
        .onDisappear {
            AudioPlayer.shared.isPlayAlarm = false
        }
    }
}
