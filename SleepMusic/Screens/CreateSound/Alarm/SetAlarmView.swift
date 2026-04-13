import SwiftUI
import UserNotifications
import FirebaseAnalytics

struct SetAlarmView: View {
    let showsCloseButton: Bool

    private let days = ["M", "T", "W", "T", "F", "S", "S"]

    @State private var selectedDays = [false, true, true, true, true, false, false]
    @State private var selectedDate = Date()
    @State private var editingField: AlarmEditableField?
    @State private var bedtime = Calendar.current.date(bySettingHour: 23, minute: 30, second: 0, of: Date()) ?? Date()
    @State private var wakeupTime = Calendar.current.date(bySettingHour: 7, minute: 45, second: 0, of: Date()) ?? Date()
    @State private var showAlarmSoundPicker = false
    @State private var selectedAlarmSound = "Colombia EAS Alarm"
    @State private var alarmName = "Morning Light"
    @State private var showAlertSuccess = false

    @State var alarmViewModel = AlarmSoundViewModel()
    @Environment(\.dismiss) private var dismiss

    init(showsCloseButton: Bool = false) {
        self.showsCloseButton = showsCloseButton
    }

    var body: some View {
        ZStack {
            LuminousBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    topBar
                    titleBlock
                    dialSection
                    repeatSection
                    timeCards
                    settingsGrid
                    LuminousPrimaryButton(title: "Save Alarm") {
                        scheduleAlarm()
                        showAlertSuccess = true
                        Analytics.logEvent("alarm_saved", parameters: [
                            "bedtime": formatTime(date: bedtime),
                            "wakeup_time": formatTime(date: wakeupTime),
                            "days_selected_count": selectedDays.filter { $0 }.count,
                            "alarm_name": alarmName
                        ])
                    }
                    .disabled(alarmName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(alarmName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1)

                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }

            if let editingField {
                Color.black.opacity(0.72)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    Text(editingField == .bedtime ? "Adjust bedtime" : "Adjust wake up")
                        .font(LuminousType.headline(22, weight: .bold))
                        .foregroundStyle(LuminousPalette.textPrimary)

                    DatePicker(
                        "",
                        selection: $selectedDate,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .tint(LuminousPalette.primary)
                    .colorScheme(.dark)
                    .padding(.horizontal)

                    HStack(spacing: 12) {
                        Button("Cancel") {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                self.editingField = nil
                            }
                        }
                        .buttonStyle(.plain)
                        .font(LuminousType.body(15, weight: .semibold))
                        .foregroundStyle(LuminousPalette.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .luminousGlassCard(cornerRadius: 22, fillColor: LuminousPalette.surfaceLow)

                        LuminousPrimaryButton(title: "Apply") {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if editingField == .bedtime {
                                    bedtime = selectedDate
                                } else {
                                    wakeupTime = selectedDate
                                }
                                self.editingField = nil
                            }
                        }
                    }
                }
                .padding(24)
                .luminousGlassCard(cornerRadius: 32, fillColor: LuminousPalette.surfaceContainer)
                .padding(.horizontal, 20)
            }
        }
        .sheet(isPresented: $showAlarmSoundPicker) {
            AlarmSoundSelectionView(selectedAlarm: $selectedAlarmSound, alarmViewModel: alarmViewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .alert("Alarm", isPresented: $showAlertSuccess) {
            Button("OK", role: .cancel) {
                if showsCloseButton {
                    dismiss()
                }
            }
        } message: {
            Text("Set alarm successfully!")
        }
        .onAppear {
            requestNotificationPermission()
        }
    }

    private var topBar: some View {
        HStack {
            if showsCloseButton {
                LuminousIconButton(icon: "xmark") {
                    dismiss()
                }
            } else {
                LuminousIconButton(icon: "gearshape.fill", isAccent: true, action: {})
            }

            Spacer()

            Text("SleepMusic")
                .font(LuminousType.body(18, weight: .semibold))
                .foregroundStyle(LuminousPalette.textPrimary)

            Spacer()

            Circle()
                .fill(LuminousPalette.accentGradient)
                .frame(width: 38, height: 38)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(red: 53 / 255, green: 20 / 255, blue: 79 / 255))
                )
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SMART WAKEUP")
                .font(LuminousType.label(11, weight: .bold))
                .tracking(2.1)
                .foregroundStyle(LuminousPalette.secondary)

            Text("Set Sleep Goal")
                .font(LuminousType.display(40, weight: .bold))
                .foregroundStyle(LuminousPalette.textPrimary)

            Text("Quiet routines, repeated gently, so tomorrow starts with less friction.")
                .font(LuminousType.body(15))
                .foregroundStyle(LuminousPalette.textSecondary)
        }
    }

    private var dialSection: some View {
        CircularSleepDurationView(bedtime: $bedtime, wakeupTime: $wakeupTime)
            .frame(height: 320)
            .frame(maxWidth: .infinity)
    }

    private var repeatSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Repeat")
                        .font(LuminousType.headline(24, weight: .bold))
                        .foregroundStyle(LuminousPalette.textPrimary)

                    Text("Wake up feeling refreshed every day")
                        .font(LuminousType.body(14))
                        .foregroundStyle(LuminousPalette.textSecondary)
                }

                Spacer()

                Text(selectedDays.filter { $0 }.count >= 5 ? "Everyday" : "Custom")
                    .font(LuminousType.body(14, weight: .semibold))
                    .foregroundStyle(LuminousPalette.primary)
            }

            HStack(spacing: 10) {
                ForEach(days.indices, id: \.self) { index in
                    Button {
                        selectedDays[index].toggle()
                    } label: {
                        Text(days[index])
                            .font(LuminousType.label(11, weight: .bold))
                            .foregroundStyle(selectedDays[index] ? Color(red: 53 / 255, green: 20 / 255, blue: 79 / 255) : LuminousPalette.textSecondary)
                            .frame(width: 38, height: 38)
                            .background(
                                Circle()
                                    .fill(selectedDays[index] ? AnyShapeStyle(LuminousPalette.primaryGradient) : AnyShapeStyle(LuminousPalette.surfaceHigh))
                                    .overlay(Circle().stroke(LuminousPalette.ghostBorder, lineWidth: selectedDays[index] ? 0 : 1))
                            )
                            .shadow(color: selectedDays[index] ? LuminousPalette.primary.opacity(0.25) : .clear, radius: 18, x: 0, y: 8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var timeCards: some View {
        HStack(spacing: 12) {
            timingCard(icon: "bed.double.fill", title: "Bedtime", value: formatTime(date: bedtime)) {
                selectedDate = bedtime
                editingField = .bedtime
            }

            timingCard(icon: "alarm.fill", title: "Wake up", value: formatTime(date: wakeupTime)) {
                selectedDate = wakeupTime
                editingField = .wakeup
            }
        }
    }

    private var settingsGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                actionCard(
                    icon: "bell.and.waves.left.and.right.fill",
                    eyebrow: "Sound",
                    title: selectedAlarmSound,
                    subtitle: "Preview and choose alarm tone"
                ) {
                    showAlarmSoundPicker = true
                }

                actionCard(
                    icon: "wand.and.stars.inverse",
                    eyebrow: "Sleep",
                    title: selectedDays.filter { $0 }.count >= 5 ? "Gentle cadence" : "Custom rhythm",
                    subtitle: "\(selectedDays.filter { $0 }.count) active nights"
                ) {}
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Alarm label")
                    .font(LuminousType.body(14, weight: .semibold))
                    .foregroundStyle(LuminousPalette.textPrimary)

                TextField(
                    "",
                    text: $alarmName,
                    prompt: Text("Enter a name")
                        .foregroundColor(LuminousPalette.textSecondary)
                )
                .font(LuminousType.body(15))
                .foregroundStyle(LuminousPalette.textPrimary)
            }
            .padding(18)
            .luminousGlassCard(cornerRadius: 24, fillColor: LuminousPalette.surfaceLow)
        }
    }

    private func timingCard(icon: String, title: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(LuminousPalette.primary)

                Text(title)
                    .font(LuminousType.body(13))
                    .foregroundStyle(LuminousPalette.textSecondary)

                Text(value)
                    .font(LuminousType.headline(22, weight: .bold))
                    .foregroundStyle(LuminousPalette.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .luminousGlassCard(cornerRadius: 26, fillColor: LuminousPalette.surfaceLow)
        }
        .buttonStyle(.plain)
    }

    private func actionCard(icon: String, eyebrow: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(LuminousPalette.secondary)

                Text(eyebrow.uppercased())
                    .font(LuminousType.label(10, weight: .bold))
                    .tracking(1.6)
                    .foregroundStyle(LuminousPalette.textSecondary)

                Text(title)
                    .font(LuminousType.body(16, weight: .semibold))
                    .foregroundStyle(LuminousPalette.textPrimary)
                    .lineLimit(2)

                Text(subtitle)
                    .font(LuminousType.body(13))
                    .foregroundStyle(LuminousPalette.textSecondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 156, alignment: .leading)
            .padding(18)
            .luminousGlassCard(cornerRadius: 26, fillColor: LuminousPalette.surfaceLow)
        }
        .buttonStyle(.plain)
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("User denied notification permissions: \(error?.localizedDescription ?? "No error")")
            }
        }
    }

    private func scheduleAlarm() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                scheduleLocalNotifications()
            }
        }
    }

    private func scheduleLocalNotifications() {
        let center = UNUserNotificationCenter.current()

        Task {
            guard let selectedAlarm = alarmViewModel.alarmSounds.first(where: { $0.name == selectedAlarmSound }) else {
                print("Selected alarm sound not found")
                return
            }

            for (index, isSelected) in selectedDays.enumerated() where isSelected {
                let content = UNMutableNotificationContent()
                content.title = "Alarm"
                content.body = alarmName
                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(selectedAlarm.id).wav"))

                var dateComponents = DateComponents()
                dateComponents.hour = Calendar.current.component(.hour, from: wakeupTime)
                dateComponents.minute = Calendar.current.component(.minute, from: wakeupTime)

                var weekday = index + 2
                if weekday > 7 {
                    weekday -= 7
                }
                dateComponents.weekday = weekday

                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                center.add(request) { error in
                    if let error {
                        print("Error scheduling notification: \(error)")
                    }
                }
            }
        }
    }

    private func formatTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
}

private enum AlarmEditableField {
    case bedtime
    case wakeup
}

#Preview {
    SetAlarmView()
}
