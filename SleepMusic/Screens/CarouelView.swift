//
//  CarouelView.swift
//  MusicSleep
//
//  Created by QuangHo on 13/10/24.
//

import SwiftUI

struct CarouselView: View {
    var images = ["img_1", "img_2", "img_3"] // Replace with your image names
    
    var body: some View {
        TabView {
            ForEach(images, id: \.self) { image in
                GeometryReader { geometry in
                    Image(image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        .rotation3DEffect(
                            .degrees(Double(geometry.frame(in: .global).minX) / -10),
                            axis: (x: 0, y: 10.0, z: 0)
                        )
                }
                .padding(20)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .frame(height: 250) // Adjust height based on your needs
    }
}


#Preview {
    CarouselView()
}
