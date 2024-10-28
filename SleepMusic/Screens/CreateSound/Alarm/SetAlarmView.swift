//
//  SetAlarmView.swift
//  SleepMusic
//
//  Created by QuangHo on 21/10/24.
//

import SwiftUI
import UserNotifications

struct SetAlarmView: View {
    @State private var startTime: Double = 0.0 // 10 PM
    @State private var endTime: Double = 8.0    // 6 AM
    let days = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    @State var selectedDays = [true, true, true, true, true, false, false] // Mo to Fr selected, Sa and Su not selected
    @State private var showDatePicker = false
    @State private var selectedDate = Date()
    @State private var isSelectingBedtime = false // To differentiate between Bedtime and Wake up
    
    @State private var bedtime: Date = Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: Date()) ?? Date() // Default to 11:00 PM
       @State private var wakeupTime: Date = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date() // Default to 7:00 AM
    @State private var showAlarmSoundPicker = false // To control the display of the sound picker sheet
    @State private var selectedAlarmSound: String = "Colombia EAS Alarm" // The currently selected alarm sound
    // Add a new State variable to hold the alarm name
    @State private var alarmName: String = ""

    @State var alarmViewModel = AlarmSoundViewModel()
    @State  var showAlertSuccess = false
    
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.black]),
                           startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                .overlay {
                    Image("bg_alarm_2")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                }
            
            VStack {
                
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .frame(width: 35, height: 35)
                            .foregroundColor(.white)
                            .background(Color(red: 0.104, green: 0.082, blue: 0.243))
                            .clipShape(Circle())
                            .shadow(color: .gray, radius: 5, x: 2, y: 2)
                    }
                    .padding([.horizontal, .top])
                    Spacer()
                    Button {
                        scheduleAlarm()
                        showAlertSuccess.toggle()
                        
                    } label: {
                        Text("Save")
                            .foregroundColor(.white)
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                    }
                    .padding(.horizontal)
                }
                
                GeometryReader { geometry in
                    let screenWidth = geometry.size.width
                    let desiredSize = screenWidth * 0.5
                    
                    VStack {
                        CircularSleepDurationView(startTime: $startTime, endTime: $endTime)
                            .frame(width: desiredSize, height: desiredSize)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                HStack(spacing: 15) {
                    ForEach(0..<days.count, id: \.self) { index in
                        Button(action: {
                            // Toggle the selected state
                            selectedDays[index].toggle()
                        }) {
                            Text(days[index])
                                .font(.system(.caption2))
                                .frame(width: 40, height: 40)
                                .foregroundColor(selectedDays[index] ? .white : .gray)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedDays[index] ? Color.purple : Color.gray, lineWidth: 2)
                                        .background(
                                            selectedDays[index] ? Color.purple : Color.clear
                                        )
                                        .cornerRadius(10)
                                )
                            
                            
                        }
                    }
                }
                .padding()
                
                
                HStack(spacing: 25) {
                    // Bedtime View
                    VStack(alignment: .leading,spacing: 10) {
                        HStack {
                            Image(systemName: "bed.double.fill")
                                .foregroundColor(.gray)
                            Text("Bedtime")
                                .font(.system(size: 13, weight: .regular, design: .monospaced))
                                .foregroundStyle(.gray)
                        }
                        Text(formatTime(date: bedtime))
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, minHeight: 64)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.1))
                            .shadow(radius: 5)
                    )
                    .cornerRadius(20)
                    .onTapGesture {
                        isSelectingBedtime = true
                        selectedDate = bedtime
                        withAnimation {
                            showDatePicker.toggle()
                        }
                    }
                    // Wake up View
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "alarm.fill")
                                .foregroundColor(.gray)
                            Text("Wake up")
                                .font(.system(size: 13, weight: .regular, design: .monospaced))
                                .foregroundStyle(.gray)
                        }
                        Text(formatTime(date: wakeupTime))
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, minHeight: 64)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.1))
                            .shadow(radius: 5)
                    )
                    .cornerRadius(20)
                    .onTapGesture {
                        isSelectingBedtime = false
                        selectedDate = wakeupTime
                        withAnimation {
                            showDatePicker.toggle()
                        }
                    }
                }
                .padding()
                //MARK: -- set alarm sound
                HStack {
                    // Artwork Image (if available)
                    Image("img_1")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .background(Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    // Song title and duration
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Alarm sound")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Text("Morning sunset")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "chevron.forward")
                            .foregroundStyle(.white.opacity(0.3))
                            .font(.system(size: 15))
                    }
                    .padding()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                        .shadow(radius: 5)
                )
                .padding(.horizontal)
                .onTapGesture {
                    self.showAlarmSoundPicker.toggle()
                }
                //MARK: -- set alarm interval
                HStack {
                    
                    Image(systemName: "hourglass")
                        .font(.system(size: 18))
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                .shadow(radius: 5)
                        )
                    
                    //MARK: -- Song title and duration
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Repeat interval")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Text("5 minutes")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "chevron.forward")
                            .foregroundStyle(.white.opacity(0.3))
                            .font(.system(size: 15))
                    }
                    .padding()
                    
                    
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                        .shadow(radius: 5)
                )
                .padding(.horizontal)
                .onTapGesture {
                    
                }
                //MARK: -- set alarm name
                HStack {
                    // Artwork Image (if available)
                    Image(systemName: "keyboard")
                        .font(.system(size: 18))
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                .shadow(radius: 5)
                        )
                    
                    // Song title and duration
                    VStack(alignment: .leading, spacing: 10) {
                        
                        Text("Alarm name")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        TextField("Enter alarm name", text: $alarmName)
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.top, 4)
                    }
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "chevron.forward")
                            .foregroundStyle(.white.opacity(0.3))
                            .font(.system(size: 15))
                    }
                    .padding()
                    
                    
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                        .shadow(radius: 5)
                )
                .padding(.horizontal)
                .onTapGesture {
                    
                }
            }
            
            if showDatePicker {
                Color.black.opacity(0.7).edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .animation(.easeInOut, value: showDatePicker)
                VStack {
                    DatePicker("", selection: $selectedDate, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .background(Color.purple)
                        .cornerRadius(20)
                        .padding()
                        .transition(.opacity)
                        .accentColor(.white)
                        .colorScheme(.dark)
                        .animation(.easeInOut, value: showDatePicker)
                    
                    Button {
                        withAnimation {
                            if isSelectingBedtime {
                                bedtime = selectedDate
                            } else {
                                wakeupTime = selectedDate
                            }
                            showDatePicker = false
                        }
                        
                    } label: {
                        Text("Done")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding()
                            .cornerRadius(10)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.1))
                            .shadow(radius: 5)
                    )
                    
                }
            }
        }
        .sheet(isPresented: $showAlarmSoundPicker) {
         
            AlarmSoundSelectionView(selectedAlarm: $selectedAlarmSound, alarmViewModel: alarmViewModel)
                    .presentationDetents([.large]) // You can specify medium and large sizes
                    .presentationDragIndicator(.visible) // Optional drag indicator
                
        }
        
        .alert("Alarm", isPresented: $showAlertSuccess) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Set alarm successfully!")
        }
    }
    
    
    // Schedule the alarm when the save button is tapped
    func scheduleAlarm() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                scheduleLocalNotifications()
            } else {
                print("Permission denied.")
            }
        }
    }
    
//    func scheduleLocalNotifications() {
//        let center = UNUserNotificationCenter.current()
//        
//        for (index, isSelected) in selectedDays.enumerated() {
//            if isSelected {
//                let content = UNMutableNotificationContent()
//                content.title = "Alarm"
//                content.body = "Time to wake up!"
//                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "severe-warning-alarm-98704.wav"))
//                
//                var dateComponents = DateComponents()
//                dateComponents.hour = Calendar.current.component(.hour, from: wakeupTime)
//                dateComponents.minute = Calendar.current.component(.minute, from: wakeupTime)
//                
//                // Map index to weekday (1 = Sunday, 7 = Saturday)
//                var weekday = index + 2
//                if weekday > 7 {
//                    weekday -= 7
//                }
//                dateComponents.weekday = weekday
//                
//                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//                
//                let uuidString = UUID().uuidString
//                let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
//                
//                center.add(request) { (error) in
//                    if let error = error {
//                        print("Error scheduling notification: \(error)")
//                    } else {
//                        print("Notification scheduled for weekday \(dateComponents.weekday ?? 0)")
//                    }
//                }
//            }
//        }
//    }
//    
    func scheduleLocalNotifications() {
            let center = UNUserNotificationCenter.current()

            Task {
                // Find the selected alarm sound from the view model
                guard let selectedAlarm = alarmViewModel.alarmSounds.first(where: { $0.name == selectedAlarmSound }) else {
                    print("Selected alarm sound not found")
                    return
                }
                


                // Now that the sound is downloaded, schedule the notifications
                for (index, isSelected) in selectedDays.enumerated() {
                    if isSelected {
                        let content = UNMutableNotificationContent()
                        content.title = "Alarm"
                        content.body = "Time to wake up!"

                        // Use the downloaded sound file
                        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: selectedAlarm.name))

                        var dateComponents = DateComponents()
                        dateComponents.hour = Calendar.current.component(.hour, from: wakeupTime)
                        dateComponents.minute = Calendar.current.component(.minute, from: wakeupTime)

                        // Map index to weekday (1 = Sunday, 7 = Saturday)
                        var weekday = index + 2
                        if weekday > 7 {
                            weekday -= 7
                        }
                        dateComponents.weekday = weekday

                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

                        let uuidString = UUID().uuidString
                        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

                        center.add(request) { (error) in
                            if let error = error {
                                print("Error scheduling notification: \(error)")
                            } else {
                                print("Notification scheduled for weekday \(dateComponents.weekday ?? 0)")
                            }
                        }
                    }
                }
            }
        }
    
    // Helper function to format the time as "hh : mm a"
    private func formatTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh : mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    SetAlarmView()
}
