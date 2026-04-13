import SwiftUI

struct SleepMusicView: View {
    @ObservedObject private var tracklistManager = TracklistManager.shared
    @ObservedObject private var audioPlayer = AudioPlayer.shared

    @State private var selectedFilter = "Music"
    @State private var searchText = ""
    @State private var isShowingPlayer = false

    private let filters = ["Music", "Podcasts", "Soundscapes"]
    private let fallbackTopics: [DiscoveryTopic] = [
//        .init(title: "Deep Sleep", subtitle: "24 tracks • Guided Sessions", detail: "Sink into long-form ambient journeys built for uninterrupted rest.", imageName: "img_4", tint: Color(red: 41 / 255, green: 70 / 255, blue: 103 / 255)),
//        .init(title: "Anxiety Relief", subtitle: "10 meditations • 4 playlists", detail: "Soft oceans, low drones, and breath-led cues to quiet the noise.", imageName: "img_2", tint: Color(red: 42 / 255, green: 95 / 255, blue: 127 / 255)),
//        .init(title: "Nature Sounds", subtitle: "Popular now", detail: "Rain forests, distant thunder, and wind loops layered with tonal warmth.", imageName: "img_1", tint: Color(red: 37 / 255, green: 50 / 255, blue: 41 / 255)),
//        .init(title: "Bedtime Stories", subtitle: "42 stories • New every Tuesday", detail: "Narratives designed to slow attention and soften the edge of the day.", imageName: "img_5", tint: Color(red: 78 / 255, green: 58 / 255, blue: 36 / 255)),
//        .init(title: "Rainy Night", subtitle: "12 tracks • Podcasts", detail: "Close-mic rainfall and distant trains for the kind of quiet that hums.", imageName: "img_3", tint: Color(red: 35 / 255, green: 55 / 255, blue: 74 / 255))
    ]

    var body: some View {
        ZStack {
            LuminousBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    topBar
                    searchBar
                    filterRow
                    topicsSection
                    madeForYouSection
                    Spacer(minLength: 140)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
        }
        .safeAreaInset(edge: .bottom) {
            miniPlayer
                .padding(.horizontal, 16)
        }
        .fullScreenCover(isPresented: $isShowingPlayer) {
            RelaxingMusicView()
        }
        .task {
            if tracklistManager.tracklists.isEmpty {
                try? await tracklistManager.fetchTracklist()
            }

            if tracklistManager.selectedTracklist == nil {
                tracklistManager.selectedTracklist = tracklistManager.tracklists.first
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [LuminousPalette.secondary.opacity(0.8), LuminousPalette.primary.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 34, height: 34)
                .overlay(
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.6))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("SleepMusic")
                    .font(LuminousType.headline(20, weight: .bold))
                    .foregroundStyle(LuminousPalette.textPrimary)

                Text("LUMINOUS VOID")
                    .font(LuminousType.label(10, weight: .bold))
                    .tracking(1.8)
                    .foregroundStyle(LuminousPalette.secondary)
            }

            Spacer()

            LuminousIconButton(icon: "gearshape.fill", isAccent: true, action: {})
        }
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(LuminousPalette.textSecondary)

            TextField(
                "",
                text: $searchText,
                prompt: Text("Search sounds, stories or moods")
                    .foregroundColor(LuminousPalette.textSecondary)
            )
            .font(LuminousType.body(14))
            .foregroundStyle(LuminousPalette.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .luminousGlassCard(cornerRadius: 20, fillColor: LuminousPalette.surfaceLow)
    }

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(filters, id: \.self) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        LuminousChip(title: filter, isSelected: selectedFilter == filter)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var topicsSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Explore Topics")
                        .font(LuminousType.display(34, weight: .bold))
                        .foregroundStyle(LuminousPalette.textPrimary)

                    Text("Curated journeys for the hour between focus and sleep.")
                        .font(LuminousType.body(15))
                        .foregroundStyle(LuminousPalette.textSecondary)
                }

                Spacer()

                Button("See all") {}
                    .buttonStyle(.plain)
                    .font(LuminousType.label(11, weight: .bold))
                    .textCase(.uppercase)
                    .foregroundStyle(LuminousPalette.primary)
            }

            LazyVStack(spacing: 18) {
                ForEach(filteredTopics.indices, id: \.self) { index in
                    let topic = filteredTopics[index]
                    TopicFeatureCard(
                        title: topic.title,
                        subtitle: topic.subtitle,
                        detail: topic.detail,
                        imageName: topic.imageName,
                        remoteImageURL: topic.remoteImageURL,
                        tint: topic.tint
                    ) {
                        openPlayer(for: topic.tracklist)
                    }
                }
            }
        }
    }

    private var madeForYouSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Made for You")
                .font(LuminousType.headline(22, weight: .bold))
                .foregroundStyle(LuminousPalette.textPrimary)

            if tracklistManager.tracklists.isEmpty {
                HStack(spacing: 14) {
                    ForEach(0..<2, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(LuminousPalette.surfaceLow)
                            .frame(height: 92)
                            .overlay(ProgressView().tint(LuminousPalette.primary))
                            .luminousGlassCard(cornerRadius: 24, fillColor: LuminousPalette.surfaceLow)
                    }
                }
            } else {
                VStack(spacing: 12) {
                    ForEach(tracklistManager.tracklists.prefix(2), id: \.id) { tracklist in
                        Button {
                            openPlayer(for: tracklist)
                        } label: {
                            HStack(spacing: 14) {
                                coverImage(
                                    named: fallbackImageName(for: tracklist.title),
                                    remoteURL: tracklist.coverImageURL
                                )
                                .frame(width: 68, height: 68)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                                VStack(alignment: .leading, spacing: 5) {
                                    Text(tracklist.title)
                                        .font(LuminousType.body(15, weight: .semibold))
                                        .foregroundStyle(LuminousPalette.textPrimary)

                                    Text(tracklist.description)
                                        .font(LuminousType.body(13))
                                        .foregroundStyle(LuminousPalette.textSecondary)
                                        .lineLimit(2)
                                }

                                Spacer()

                                Image(systemName: "play.fill")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(Color(red: 53 / 255, green: 20 / 255, blue: 79 / 255))
                                    .frame(width: 42, height: 42)
                                    .background(Circle().fill(LuminousPalette.primaryGradient))
                            }
                            .padding(14)
                            .luminousGlassCard(cornerRadius: 24, fillColor: LuminousPalette.surfaceLow)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var miniPlayer: some View {
        let currentTitle = audioPlayer.currentTrack?.nameOfTracklist ?? tracklistManager.selectedTracklist?.title ?? "Midnight Train"
        let currentSubtitle = audioPlayer.currentTrack?.name ?? "Soft ambient motion"

        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(LuminousPalette.primaryGradient)
                .frame(width: 46, height: 46)
                .overlay(
                    Image(systemName: "sparkles")
                        .foregroundStyle(Color(red: 53 / 255, green: 20 / 255, blue: 79 / 255))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(currentTitle)
                    .font(LuminousType.body(14, weight: .semibold))
                    .foregroundStyle(LuminousPalette.textPrimary)
                    .lineLimit(1)

                Text(currentSubtitle)
                    .font(LuminousType.body(12))
                    .foregroundStyle(LuminousPalette.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Button {
                audioPlayer.togglePlayPause()
            } label: {
                Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color(red: 53 / 255, green: 20 / 255, blue: 79 / 255))
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(LuminousPalette.primaryGradient))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .luminousGlassCard(cornerRadius: 24, fillColor: LuminousPalette.surfaceContainer)
        .contentShape(Rectangle())
        .onTapGesture {
            isShowingPlayer = true
        }
    }

    private var filteredTopics: [DiscoveryTopic] {
        let dynamicTopics = tracklistManager.tracklists.map { tracklist in
            DiscoveryTopic(
                title: tracklist.title,
                subtitle: "\(tracklist.numberOfTracks ?? 0) tracks • \(formatSecondsToHoursMinutes(tracklist.totalDuration))",
                detail: tracklist.description,
                imageName: fallbackImageName(for: tracklist.title),
                remoteImageURL: tracklist.coverImageURL,
                tint: colorTint(for: tracklist.title),
                tracklist: tracklist
            )
        }

        let source = dynamicTopics.isEmpty ? fallbackTopics : dynamicTopics
        guard !searchText.isEmpty else { return source }

        return source.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.detail.localizedCaseInsensitiveContains(searchText) ||
            $0.subtitle.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func openPlayer(for tracklist: Tracklist?) {
        if let tracklist {
            tracklistManager.selectedTracklist = tracklist
            if let tracks = tracklist.tracks, !tracks.isEmpty {
                AudioPlayer.shared.setTracks(tracks)
            }
        }

        isShowingPlayer = true
    }

    private func fallbackImageName(for seed: String) -> String {
        let names = ["img_1", "img_2", "img_3", "img_4", "img_5", "img_6"]
        let index = abs(seed.hashValue) % names.count
        return names[index]
    }

    private func colorTint(for seed: String) -> Color {
        let palette: [Color] = [
            Color(red: 35 / 255, green: 55 / 255, blue: 74 / 255),
            Color(red: 44 / 255, green: 73 / 255, blue: 104 / 255),
            Color(red: 62 / 255, green: 48 / 255, blue: 92 / 255),
            Color(red: 73 / 255, green: 56 / 255, blue: 45 / 255)
        ]

        return palette[abs(seed.hashValue) % palette.count]
    }

    @ViewBuilder
    private func coverImage(named imageName: String, remoteURL: String?) -> some View {
        if let remoteURL, let url = URL(string: remoteURL) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            }
        } else {
            Image(imageName)
                .resizable()
                .scaledToFill()
        }
    }
}

private struct TopicFeatureCard: View {
    let title: String
    let subtitle: String
    let detail: String
    let imageName: String
    let remoteImageURL: String?
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                cardArtwork

                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.14), Color.black.opacity(0.68)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(subtitle.uppercased())
                        .font(LuminousType.label(10, weight: .bold))
                        .tracking(1.4)
                        .foregroundStyle(LuminousPalette.secondary.opacity(0.88))

                    Text(title)
                        .font(LuminousType.headline(30, weight: .bold))
                        .foregroundStyle(LuminousPalette.textPrimary)

                    Text(detail)
                        .font(LuminousType.body(13))
                        .foregroundStyle(LuminousPalette.textPrimary.opacity(0.82))
                        .lineLimit(2)
                }
                .padding(22)
            }
            .frame(height: 256)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(LuminousPalette.ghostBorder, lineWidth: 1)
            )
            .shadow(color: tint.opacity(0.22), radius: 28, x: 0, y: 18)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var cardArtwork: some View {
        ZStack {
            if let remoteImageURL, let url = URL(string: remoteImageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                }
            } else {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            }

            tint.opacity(0.38)
        }
    }
}

private struct DiscoveryTopic {
    let title: String
    let subtitle: String
    let detail: String
    let imageName: String
    var remoteImageURL: String? = nil
    let tint: Color
    var tracklist: Tracklist? = nil
}

struct SleepMusicView_Previews: PreviewProvider {
    static var previews: some View {
        SleepMusicView()
    }
}
