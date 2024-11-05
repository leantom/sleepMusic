//
//  CarouelView.swift
//  MusicSleep
//
//  Created by QuangHo on 13/10/24.
//

import SwiftUI
import Kingfisher


struct CarouselView: View {
    var tracklists: [Tracklist]
    @Binding var selectedTracklist: Tracklist?
    @State private var currentIndex: Int = 0

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(tracklists.enumerated()), id: \.offset) { index, tracklist in
                GeometryReader { geometry in
                    ZStack {
                        if let coverImageURL = tracklist.coverImageURL, let url = URL(string: coverImageURL) {
                            KFImage(url)
                                .resizable()
                                .onSuccess { _ in
                                    preloadAdjacentImages(currentIndex: index)
                                }
                                .placeholder {
                                    ProgressView()
                                }
                                .cacheOriginalImage()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            // Placeholder image
                            Image("img_1")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                    }
                    .frame(width: geometry.size.width * 2 / 3, height: geometry.size.height)
                    .clipped()
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .rotation3DEffect(
                        .degrees(Double(geometry.frame(in: .global).minX) / -10),
                        axis: (x: 0, y: 10.0, z: 0)
                    )
                    .onTapGesture {
                        selectedTracklist = tracklist
                    }
                    .onChange(of: currentIndex) {  newIndex in
                        // This code runs whenever currentIndex changes
                        print("Scrolled to index \(newIndex)")
                        // Perform any actions needed when the index changes
                        selectedTracklist = tracklists[newIndex]
                    }
                }
                .padding(20)
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .frame(height: 250)
    }

    // Preload previous and next images
    func preloadAdjacentImages(currentIndex: Int) {
        let indicesToPreload = [currentIndex - 1, currentIndex + 1]
        for index in indicesToPreload {
            guard tracklists.indices.contains(index) else { continue }
            if let coverImageURL = tracklists[index].coverImageURL, let url = URL(string: coverImageURL) {
                KingfisherManager.shared.retrieveImage(with: url) { result in
                    switch result {
                    case .success(let value):
                        print("Preloaded image at index \(index): \(value.image)")
                    case .failure(let error):
                        print("Failed to preload image at index \(index): \(error)")
                    }
                }
            }
        }
    }
}
