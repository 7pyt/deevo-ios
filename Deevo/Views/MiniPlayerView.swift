import SwiftUI

// Reprend l'esprit de la barre de lecture persistante du desktop : bandeau
// "verre dépoli" collé en bas, pochette + titre/artiste + contrôles.
struct MiniPlayerView: View {
    @EnvironmentObject var player: AudioPlayerManager
    @State private var showFullPlayer = false

    var body: some View {
        if let track = player.currentTrack {
            Button {
                showFullPlayer = true
            } label: {
                HStack(spacing: 12) {
                    AsyncImage(url: track.artworkURL) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        DeevoTheme.bgElevated
                    }
                    .frame(width: 42, height: 42)
                    .clipShape(RoundedRectangle(cornerRadius: DeevoTheme.radiusXS, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(track.title)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(DeevoTheme.textPrimary)
                            .lineLimit(1)
                        Text(track.artist)
                            .font(.system(size: 11))
                            .foregroundStyle(DeevoTheme.textDim)
                            .lineLimit(1)
                    }

                    Spacer()

                    Button { player.togglePlayPause() } label: {
                        Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 17))
                            .foregroundStyle(DeevoTheme.textPrimary)
                    }
                    Button { player.playNext() } label: {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(DeevoTheme.textDim)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
            .deevoGlass(cornerRadius: 0)
            .overlay(alignment: .top) {
                Rectangle().fill(DeevoTheme.line).frame(height: 1)
            }
            .sheet(isPresented: $showFullPlayer) {
                PlayerView()
                    .preferredColorScheme(.dark)
            }
        }
    }
}
