//
//  CirclularSleepDurationView.swift
//  SleepMusic
//
//  Created by QuangHo on 21/10/24.
//

import SwiftUI

struct CircularSleepDurationView: View {
    @Binding var startTime: Double // Start time in hours (0 to 24)
    @Binding var endTime: Double   // End time in hours (0 to 24)
    
    var sleepDuration: Double {
        let duration = endTime - startTime
        return duration >= 0 ? duration : (24 + duration)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size.width // Use the width of the available space
            let center = CGPoint(x: size / 2, y: size / 2)
            let radius = size / 2
            
            ZStack {
                // Background circle
                Image("clockhands_bg")
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(0.9)
                    .frame(width: size, height: size)
                    .clipped()
                
                Circle()
                    .stroke(lineWidth: 15)
                    .opacity(0.2)
                    .foregroundColor(.purple)
                    .frame(width: size, height: size)
                
                // Progress arc
                Circle()
                    .trim(from: startAngle / 360, to: endAngle / 360)
                    .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .butt, lineJoin: .round))
                    .foregroundColor(.purple)
                    .rotationEffect(.degrees(-90))
                    .frame(width: size, height: size)
                
                // Start handle
                Circle()
                    .fill(Color.white)
                    .frame(width: 30, height: 30)
                    .position(getHandlePosition(size: size, time: startTime))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let touchPoint = CGPoint(x: value.location.x, y: value.location.y)
                                let angle = angleFrom(center: center, to: touchPoint)
                                let newTime = angle / 360 * 24
                                self.startTime = newTime
                            }
                    )
                
                // End handle
                Circle()
                    .fill(Color.white)
                    .frame(width: 30, height: 30)
                    .position(getHandlePosition(size: size, time: endTime))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let touchPoint = CGPoint(x: value.location.x, y: value.location.y)
                                let angle = angleFrom(center: center, to: touchPoint)
                                let newTime = angle / 360 * 24
                                self.endTime = newTime
                            }
                    )
                
                // Sleep duration text
                VStack {
                    Text(String(format: "%.0fhr %.0fmin", floor(sleepDuration), (sleepDuration - floor(sleepDuration)) * 60))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Sleep duration")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .frame(width: size, height: size)
        }
        .aspectRatio(1, contentMode: .fit) // Maintain a square aspect ratio
    }
    
    // Computed properties for start and end angles
    var startAngle: Double {
        return startTime / 24 * 360
    }
    
    var endAngle: Double {
        // Adjust for times that cross midnight
        let angle = endTime / 24 * 360
        return angle >= startAngle ? angle : angle + 360
    }
    
    // Function to get the position of the handle based on time
    func getHandlePosition(size: CGFloat, time: Double) -> CGPoint {
        let angle = time / 24 * 360 - 90 // Adjust for rotation
        let radians = angle * .pi / 180
        
        let radius = size / 2
        let x = radius * cos(radians) + radius
        let y = radius * sin(radians) + radius
        
        return CGPoint(x: x, y: y)
    }
    
    // Function to calculate the angle between the center and the touch point
    func angleFrom(center: CGPoint, to point: CGPoint) -> Double {
        let dx = point.x - center.x
        let dy = point.y - center.y
        
        var angle = atan2(dy, dx) * 180 / .pi
        if angle < 0 { angle += 360 }
        
        // Adjust for circle's rotation (-90 degrees)
        angle = (angle - 270).truncatingRemainder(dividingBy: 360)
        if angle < 0 { angle += 360 }
        
        return angle
    }
}


struct WrapperCircularSleepDurationView: View {
    @State var startTime: Double = 0.0
    @State var endTime: Double = 8.0
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let desiredSize = screenWidth * 0.6 // 60% of screen width
            
            VStack {
                CircularSleepDurationView(startTime: $startTime, endTime: $endTime)
                    .frame(width: desiredSize, height: desiredSize)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
#Preview {
    WrapperCircularSleepDurationView()
}
