import SwiftUI

struct PlayerView: View {
    @EnvironmentObject var player: AudioPlayerManager
    @StateObject private var favorites = FavoritesStore.shared

    var body: some View {
        VStack(spacing: 24) {
            Capsule().fill(.secondary.opacity(0.4)).frame(width: 40, height: 5).padding(.top, 8)

            if let track = player.currentTrack {
                AsyncImage(url: track.artworkURL) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 260, height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 10)

                VStack(spacing: 4) {
                    Text(track.title).font(.title3.bold()).multilineTextAlignment(.center)
                    Text(track.artist).font(.subheadline).foregroundStyle(.secondary)
                }

                VStack(spacing: 4) {
                    Slider(
                        value: Binding(get: { player.currentTime }, set: { player.seek(to: $0) }),
                        in: 0...max(player.duration, 1)
                    )
                    HStack {
                        Text(formatTime(player.currentTime)).font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        Text(formatTime(player.duration)).font(.caption).foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)

                HStack(spacing: 40) {
                    Button { player.playPrevious() } label: {
                        Image(systemName: "backward.fill").font(.title2)
                    }
                    Button { player.togglePlayPause() } label: {
                        Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 64))
                    }
                    Button { player.playNext() } label: {
                        Image(systemName: "forward.fill").font(.title2)
                    }
                }

                Button {
                    favorites.toggle(track)
                } label: {
                    Image(systemName: favorites.contains(track) ? "heart.fill" : "heart")
                        .font(.title2)
                        .foregroundStyle(favorites.contains(track) ? .red : .secondary)
                }
            } else {
                Spacer()
                Text("Aucune lecture en cours").foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
    }

    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }
        let total = Int(seconds)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}
