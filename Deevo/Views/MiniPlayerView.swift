import SwiftUI

struct MiniPlayerView: View {
    @EnvironmentObject var player: AudioPlayerManager
    @State private var showFullPlayer = false

    var body: some View {
        if let track = player.currentTrack {
            Button {
                showFullPlayer = true
            } label: {
                HStack(spacing: 10) {
                    AsyncImage(url: track.artworkURL) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(track.title).font(.subheadline).lineLimit(1)
                        Text(track.artist).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                    }

                    Spacer()

                    Button { player.togglePlayPause() } label: {
                        Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title3)
                    }
                    Button { player.playNext() } label: {
                        Image(systemName: "forward.fill")
                            .font(.title3)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showFullPlayer) {
                PlayerView()
            }
        }
    }
}
