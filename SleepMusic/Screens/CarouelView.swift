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
                    .onChange(of: currentIndex) { oldIndex, newIndex in
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

struct WrapperCarouselView: View {
    let tracklists: [Tracklist] = [
        Tracklist(
            id: "1",
            title: "Chill Vibes",
            description: "A collection of mellow and relaxing tracks for unwinding.",
            coverImageURL: "https://firebasestorage.googleapis.com:443/v0/b/lullify-3fffe.appspot.com/o/coverImages%2F6286B9E8-4251-4A66-A0E0-E50C0B5DAC84.png?alt=media&token=1d254daa-455c-4127-b270-a64b747f8027",
            totalDuration: 3600,
            numberOfTracks: 12
        ),
        Tracklist(
            id: "2",
            title: "Workout Anthems",
            description: "High-energy tracks to keep you motivated during your workout.",
            coverImageURL: "https://firebasestorage.googleapis.com:443/v0/b/lullify-3fffe.appspot.com/o/coverImages%2F6286B9E8-4251-4A66-A0E0-E50C0B5DAC84.png?alt=media&token=1d254daa-455c-4127-b270-a64b747f8027",
            totalDuration: 4500,
            numberOfTracks: 15
        ),
        Tracklist(
            id: "3",
            title: "Classical Essentials",
            description: "The most iconic classical music pieces in one playlist.",
            coverImageURL: "https://firebasestorage.googleapis.com:443/v0/b/lullify-3fffe.appspot.com/o/coverImages%2F6286B9E8-4251-4A66-A0E0-E50C0B5DAC84.png?alt=media&token=1d254daa-455c-4127-b270-a64b747f8027",
            totalDuration: 5400,
            numberOfTracks: 10
        ),
        Tracklist(
            id: "4",
            title: "Indie Hits",
            description: "A mix of the latest and greatest indie tracks from emerging artists.",
            coverImageURL: "https://firebasestorage.googleapis.com:443/v0/b/lullify-3fffe.appspot.com/o/coverImages%2F6286B9E8-4251-4A66-A0E0-E50C0B5DAC84.png?alt=media&token=1d254daa-455c-4127-b270-a64b747f8027",
            totalDuration: 3900,
            numberOfTracks: 13
        ),
        Tracklist(
            id: "5",
            title: "Jazz Classics",
            description: "Timeless jazz tracks that define the genre.",
            coverImageURL: "https://firebasestorage.googleapis.com:443/v0/b/lullify-3fffe.appspot.com/o/coverImages%2F6286B9E8-4251-4A66-A0E0-E50C0B5DAC84.png?alt=media&token=1d254daa-455c-4127-b270-a64b747f8027",
            totalDuration: 4200,
            numberOfTracks: 14
        )
    ]


    @State var selectedTracklist: Tracklist?
    
    var body: some View {
        CarouselView(tracklists: tracklists, selectedTracklist: $selectedTracklist)
    }
}

#Preview {
    WrapperCarouselView()
}
