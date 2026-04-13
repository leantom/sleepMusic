import SwiftUI

struct RelaxingMusicView: View {
    @ObservedObject var tracklistManager = TracklistManager.shared
    @ObservedObject var audioPlayer = AudioPlayer.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LuminousBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    topBar
                    heroCard
                    playlistRail
                    MediaControlView()
                    queueSection
                    Spacer(minLength: 42)
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 24)
            }
        }
        .task {
            try? await prepareTracklistsIfNeeded()
        }
        .onDisappear {
            AppSetting.shared.isOpenFromWidget = false
        }
    }

    private var topBar: some View {
        HStack {
            LuminousIconButton(icon: "xmark") {
                dismiss()
            }

            Spacer()

            VStack(spacing: 2) {
                Text("NOW PLAYING")
                    .font(LuminousType.label(10, weight: .bold))
                    .tracking(1.6)
                    .foregroundStyle(LuminousPalette.primary)

                Text("SleepMusic")
                    .font(LuminousType.body(16, weight: .semibold))
                    .foregroundStyle(LuminousPalette.textPrimary)
            }

            Spacer()

            LuminousIconButton(icon: "arrow.clockwise") {
                Task {
                    try? await tracklistManager.fetchTracklist()
                }
            }
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            ZStack(alignment: .bottomTrailing) {
                heroImage
                    .frame(height: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .stroke(LuminousPalette.ghostBorder, lineWidth: 1)
                    )

                BreatheOrb()
                    .padding(20)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("CURATED JOURNEY")
                    .font(LuminousType.label(10, weight: .bold))
                    .tracking(1.8)
                    .foregroundStyle(LuminousPalette.secondary)

                Text(selectedTracklist?.title ?? "Cosmic Drift")
                    .font(LuminousType.display(34, weight: .bold))
                    .foregroundStyle(LuminousPalette.textPrimary)

                Text(selectedTracklist?.description ?? "Deep sleep sequences with soft halos of motion.")
                    .font(LuminousType.body(15))
                    .foregroundStyle(LuminousPalette.textSecondary)
                    .lineLimit(3)
            }

            HStack(spacing: 12) {
                statPill(icon: "music.note.list", title: "\(selectedTracklist?.numberOfTracks ?? 0) songs")
                statPill(icon: "clock", title: formatSecondsToHoursMinutes(selectedTracklist?.totalDuration ?? 0))
            }
        }
    }

    private var playlistRail: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Other journeys")
                    .font(LuminousType.headline(22, weight: .bold))
                    .foregroundStyle(LuminousPalette.textPrimary)

                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(tracklistManager.tracklists, id: \.id) { tracklist in
                        Button {
                            select(tracklist: tracklist, autoplay: true)
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                tracklistCoverImage(tracklist: tracklist)
                                    .frame(width: 170, height: 118)
                                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                                Text(tracklist.title)
                                    .font(LuminousType.body(14, weight: .semibold))
                                    .foregroundStyle(LuminousPalette.textPrimary)
                                    .lineLimit(1)

                                Text(formatSecondsToHoursMinutes(tracklist.totalDuration))
                                    .font(LuminousType.body(12))
                                    .foregroundStyle(LuminousPalette.textSecondary)
                            }
                            .frame(width: 170, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var queueSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Queue")
                .font(LuminousType.headline(22, weight: .bold))
                .foregroundStyle(LuminousPalette.textPrimary)

            if tracksForSelectedTracklist.isEmpty {
                Text("No tracks are available for this collection yet.")
                    .font(LuminousType.body(14))
                    .foregroundStyle(LuminousPalette.textSecondary)
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .luminousGlassCard(fillColor: LuminousPalette.surfaceLow)
            } else {
                VStack(spacing: 12) {
                    ForEach(tracksForSelectedTracklist) { track in
                        SongRow(track: track, listTrack: tracksForSelectedTracklist)
                    }
                }
            }
        }
    }

    private var heroImage: some View {
        ZStack {
            if let selectedTracklist {
                tracklistCoverImage(tracklist: selectedTracklist)
            } else {
                Image("img_2")
                    .resizable()
                    .scaledToFill()
            }

            LinearGradient(
                colors: [LuminousPalette.secondary.opacity(0.22), .clear, Color.black.opacity(0.42)],
                startPoint: .top,
                endPoint: .bottom
            )

            Circle()
                .fill(LuminousPalette.secondary.opacity(0.16))
                .frame(width: 160, height: 160)
                .blur(radius: 10)

            Circle()
                .stroke(Color.white.opacity(0.16), lineWidth: 3)
                .frame(width: 140, height: 140)

            Circle()
                .fill(Color.white)
                .frame(width: 24, height: 24)
                .shadow(color: LuminousPalette.secondary.opacity(0.8), radius: 30, x: 0, y: 0)
        }
    }

    private var selectedTracklist: Tracklist? {
        tracklistManager.selectedTracklist ?? tracklistManager.tracklists.first
    }

    private var tracksForSelectedTracklist: [Track] {
        selectedTracklist?.tracks?.sorted(by: { $0.trackNumber < $1.trackNumber }) ?? []
    }

    private func statPill(icon: String, title: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(LuminousPalette.primary)

            Text(title)
                .font(LuminousType.body(13, weight: .semibold))
                .foregroundStyle(LuminousPalette.textPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .luminousGlassCard(cornerRadius: 18, fillColor: LuminousPalette.surfaceLow)
    }

    @ViewBuilder
    private func tracklistCoverImage(tracklist: Tracklist) -> some View {
        if let coverImageURL = tracklist.coverImageURL, let url = URL(string: coverImageURL) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                fallbackTracklistImage(for: tracklist.title)
            }
        } else {
            fallbackTracklistImage(for: tracklist.title)
        }
    }

    private func fallbackTracklistImage(for seed: String) -> some View {
        let names = ["img_1", "img_2", "img_3", "img_4", "img_5", "img_6"]
        let index = abs(seed.hashValue) % names.count
        return Image(names[index])
            .resizable()
            .scaledToFill()
    }

    private func prepareTracklistsIfNeeded() async throws {
        if tracklistManager.tracklists.isEmpty {
            try await tracklistManager.fetchTracklist()
        }

        if AppSetting.shared.isOpenFromWidget,
           let tracklist = tracklistManager.getTracklist(by: AppSetting.shared.trackId) {
            select(tracklist: tracklist, autoplay: true)
            return
        }

        if tracklistManager.selectedTracklist == nil {
            tracklistManager.selectedTracklist = tracklistManager.tracklists.first
        }

        if let selectedTracklist, !audioPlayer.isPlaying, let tracks = selectedTracklist.tracks, !tracks.isEmpty {
            AudioPlayer.shared.setTracks(tracks)
        }
    }

    private func select(tracklist: Tracklist, autoplay: Bool) {
        tracklistManager.selectedTracklist = tracklist

        if let id = tracklist.id {
            tracklistManager.incrementViewCount(for: id)
        }

        guard let tracks = tracklist.tracks, !tracks.isEmpty else { return }
        AudioPlayer.shared.setTracks(tracks)

        if !autoplay {
            AudioPlayer.shared.pause()
        }
    }
}

private struct BreatheOrb: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Circle()
                .fill(LuminousPalette.secondary.opacity(0.12))
                .frame(width: 84, height: 84)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [LuminousPalette.secondary.opacity(0.95), LuminousPalette.primary.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 54, height: 54)
                .scaleEffect(animate ? 1.08 : 0.92)
                .shadow(color: LuminousPalette.secondary.opacity(0.4), radius: 20, x: 0, y: 0)
        }
        .overlay(
            Text("BREATHE")
                .font(LuminousType.label(8, weight: .bold))
                .tracking(1.6)
                .foregroundStyle(Color.black.opacity(0.55))
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

struct SongRow: View {
    var track: Track
    var listTrack: [Track]
    @ObservedObject var audioPlayer = AudioPlayer.shared

    var body: some View {
        Button {
            AudioPlayer.shared.setTracks(listTrack)
            AudioPlayer.shared.playTrack(for: track)
        } label: {
            HStack(spacing: 14) {
                artwork
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    Text(track.name)
                        .font(LuminousType.body(15, weight: .semibold))
                        .foregroundStyle(LuminousPalette.textPrimary)
                        .lineLimit(1)

                    Text(trackDurationString(duration: track.duration))
                        .font(LuminousType.body(13))
                        .foregroundStyle(LuminousPalette.textSecondary)
                }

                Spacer()

                if audioPlayer.currentTrack == track && audioPlayer.isPlaying {
                    LoadingView()
                        .frame(width: 34, height: 24)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(LuminousPalette.textSecondary)
                }
            }
            .padding(14)
            .luminousGlassCard(cornerRadius: 24, fillColor: LuminousPalette.surfaceLow)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var artwork: some View {
        if let artworkURL = track.artWorkURL, let url = URL(string: artworkURL) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image("img_1")
                    .resizable()
                    .scaledToFill()
            }
        } else {
            Image("img_1")
                .resizable()
                .scaledToFill()
        }
    }

    private func trackDurationString(duration: Int) -> String {
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    RelaxingMusicView()
}
