//
//  BedTimeView.swift
//  MusicSleep
//
//  Created by QuangHo on 13/10/24.
//

import SwiftUI

struct BedtimeView: View {
    @State private var offset: CGFloat = 1 // Offset for the circle
    @State private var opacity: CGFloat = 1 // Offset for the circle
    private let sliderWidth: CGFloat = UIScreen.main.bounds.width - 60 // Width of the slider background
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "5C19B7").opacity(0.4), .blue.opacity(0.5)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            .overlay {
                Image("bg_alarm")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
            }
            VStack {
                // Top Date and Bedtime Title
                VStack (spacing: 10){
                    HStack(spacing: 5) {
                        Image(systemName: "moon.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                        
                        Text("BEDTIME")
                            .foregroundColor(.white)
                            .font(.headline)

                        Text("23 Jul, Monday")
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 20)
                    
                    // Clock Display
                    Text("11:30")
                        .font(.system(size: 90, weight: .light))
                        .foregroundColor(.white)
                }
                .padding(.top, 60)
                
                Spacer()
                
               
                // Swipe to Sleep Action
                VStack (alignment: .leading){
                    VStack(spacing: 5) {
                        Text("It's time to \nGood sleep ...")
                            .foregroundColor(.white)
                            .font(.system(size: 34, weight: .light))
                    }
                    .padding(.horizontal, 30)
                    // Slider Background
                    RoundedRectangle(cornerRadius: 30)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex:"5C19B7").opacity(0.5), Color.white.opacity(0.2)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 60)
                        .overlay(
                            ZStack {
                                // HStack inside the overlay
                                HStack {
                                    // Arrow Icon inside circle
                                    ZStack {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: "arrow.right")
                                            .foregroundColor(.purple)
                                            .font(.system(size: 20, weight: .bold))
                                    }
                                    .offset(x: offset) // Apply offset to move the circle
                                    .gesture(
                                        DragGesture()
                                            .onChanged { gesture in
                                                // Constrain the offset within the bounds of the slider
                                                if gesture.translation.width >= 0 && gesture.translation.width <= (sliderWidth - 70) {
                                                    withAnimation(.easeOut) {
                                                        self.offset = gesture.translation.width
                                                        self.opacity = 1 - (offset / (sliderWidth - 70.0))
                                                    }
                                                }
                                            }
                                            .onEnded { gesture in
                                                // On release, if the offset is past 80% of the slider width, move it to the end
                                                if self.offset > (sliderWidth - 70) * 0.8 {
                                                    withAnimation(.easeOut) {
                                                        self.offset = sliderWidth - 70
                                                        self.opacity = 0
                                                        print("opacity: \(opacity)")
                                                    }
                                                    // Add action for when the user completes the swipe
                                                    print("Sleep mode started")
                                                    
                                                } else {
                                                    // If not past 80%, return to starting position
                                                    withAnimation(.easeOut) {
                                                        self.offset = 0
                                                        self.opacity = 1
                                                    }
                                                }
                                            }
                                    )
                                    
                                    Spacer()
                                }
                                .padding(.leading, 10)
                                
                                // Swipe text centered
                                Text("Swipe Right to Start Sleep")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .medium))
                                    .opacity(self.opacity)
                            }
                        )
                        .padding(.horizontal, 30)
                }
                .padding(.bottom, 40)
            }
        }
       
    }
}

struct BedtimeView_Previews: PreviewProvider {
    static var previews: some View {
        BedtimeView()
            .preferredColorScheme(.dark)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
