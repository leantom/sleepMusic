//
//  SnapCarousel.swift
//  SleepMusic
//
//  Created by QuangHo on 16/10/24.
//

import SwiftUI
import Kingfisher

struct SnapCarousel: View {
    @EnvironmentObject var UIState: UIStateModel
    var tracklists: [Tracklist]
    @Binding var selectedTracklist: Tracklist?
    
    var body: some View {
        let spacing: CGFloat = 16
        let widthOfHiddenCards: CGFloat = 32
        let cardHeight: CGFloat = 279

        
        return Canvas {
            /// TODO: find a way to avoid passing same arguments to Carousel and Item
            Carousel(
                numberOfItems: CGFloat(tracklists.count),
                spacing: spacing,
                widthOfHiddenCards: widthOfHiddenCards
            ) {
                ForEach(tracklists, id: \.id) { item in
                    Item(
                        _id: Int(item.id!) ?? 0,
                        spacing: spacing,
                        widthOfHiddenCards: widthOfHiddenCards,
                        cardHeight: cardHeight
                    ) {
                        VStack {
                            // Display the cover image
                            if let coverImageURL = item.coverImageURL, let url = URL(string: coverImageURL) {
                                KFImage(url)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width:300, height: 220)
                                    .cornerRadius(20)
                                    .clipped()
                            } else {
                                // Placeholder image
                                Image("img_3")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 200)
                                    .clipped()
                            }
                            
                            // Display the title
                            Text(item.title)
                                .font(.system(size: 15, weight: .medium, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.top, 8)
                        }
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    }
                    .padding(.vertical, 16)
                    .animation(.spring())
                }

            }
            .animation(.easeInOut)
        }
    }
}

struct Card: Decodable, Hashable, Identifiable {
    var id: Int
    var name: String = ""
}

public class UIStateModel: ObservableObject {
    @Published var activeCard: Int = 0
    @Published var screenDrag: Float = 0.0
}

struct Carousel<Items : View> : View {
    let items: Items
    let numberOfItems: CGFloat
    let spacing: CGFloat
    let widthOfHiddenCards: CGFloat
    let totalSpacing: CGFloat
    let cardWidth: CGFloat
    
    @GestureState var isDetectingLongPress = false
    
    @EnvironmentObject var UIState: UIStateModel
        
    @inlinable public init(
        numberOfItems: CGFloat,
        spacing: CGFloat,
        widthOfHiddenCards: CGFloat,
        @ViewBuilder _ items: () -> Items) {
        
        self.items = items()
        self.numberOfItems = numberOfItems
        self.spacing = spacing
        self.widthOfHiddenCards = widthOfHiddenCards
        self.totalSpacing = (numberOfItems - 1) * spacing
        self.cardWidth = UIScreen.main.bounds.width - (widthOfHiddenCards*2) - (spacing*2)
        
    }
    
    var body: some View {
        let totalCanvasWidth: CGFloat = (cardWidth * numberOfItems) + totalSpacing
        let xOffsetToShift = (totalCanvasWidth - UIScreen.main.bounds.width) / 2
        let leftPadding = widthOfHiddenCards + spacing
        let totalMovement = cardWidth + spacing
                
        let activeOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(UIState.activeCard))
        let nextOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(UIState.activeCard) + 1)

        var calcOffset = Float(activeOffset)
        
        if (calcOffset != Float(nextOffset)) {
            calcOffset = Float(activeOffset) + UIState.screenDrag
        }
        
        return HStack(alignment: .center, spacing: spacing) {
            items
        }
        .offset(x: CGFloat(calcOffset), y: 0)
        .gesture(DragGesture().updating($isDetectingLongPress) { currentState, gestureState, transaction in
            self.UIState.screenDrag = Float(currentState.translation.width)
            
        }.onEnded { value in
            self.UIState.screenDrag = 0
            
            if (value.translation.width < -50) &&  self.UIState.activeCard < Int(numberOfItems) - 1 {
                self.UIState.activeCard = self.UIState.activeCard + 1
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }
            
            if (value.translation.width > 50) && self.UIState.activeCard > 0 {
                self.UIState.activeCard = self.UIState.activeCard - 1
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }
        })
    }
}

struct Canvas<Content : View> : View {
    let content: Content
    @EnvironmentObject var UIState: UIStateModel
    
    @inlinable init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
    }
}

struct Item<Content: View>: View {
    @EnvironmentObject var UIState: UIStateModel
    let cardWidth: CGFloat
    let cardHeight: CGFloat

    var _id: Int
    var content: Content

    @inlinable public init(
        _id: Int,
        spacing: CGFloat,
        widthOfHiddenCards: CGFloat,
        cardHeight: CGFloat,
        @ViewBuilder _ content: () -> Content
    ) {
        self.content = content()
        self.cardWidth = UIScreen.main.bounds.width - (widthOfHiddenCards*2) - (spacing*2)
        self.cardHeight = cardHeight
        self._id = _id
    }

    var body: some View {
        content
            .frame(width: cardWidth, height: _id == UIState.activeCard ? cardHeight : cardHeight - 60, alignment: .center)
    }
}


struct WrapperSnapCarouselView: View {
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
        SnapCarousel(tracklists: tracklists, selectedTracklist: $selectedTracklist)
    }
}

#Preview {
    WrapperSnapCarouselView()
}

