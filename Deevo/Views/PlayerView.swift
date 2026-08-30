import SwiftUI

struct PlayerView: View {
    @EnvironmentObject var player: AudioPlayerManager
    @StateObject private var favorites = FavoritesStore.shared
    var onClose: () -> Void

    var body: some View {
        GeometryReader { geo in
            // La pochette occupe une part fixe de la largeur d'écran plutôt
            // qu'une taille figée (260) : sur un grand écran ça ne laisse
            // plus un vide autour, sur un petit écran ça ne déborde plus.
            let artworkSize = min(geo.size.width - 64, 340)

            VStack(spacing: 0) {
                // Barre du haut : bouton fermer (indispensable en
                // fullScreenCover, qui n'a pas de geste de fermeture natif
                // contrairement à un sheet classique).
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(DeevoTheme.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(DeevoTheme.bgElevated))
                    }
                    Spacer()
                    Text("EN LECTURE")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(DeevoTheme.textDim)
                        .tracking(1)
                    Spacer()
                    // Espace symétrique au bouton de gauche pour centrer le titre.
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                Spacer(minLength: 24)

                if let track = player.currentTrack {
                    AsyncImage(url: track.artworkURL) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        DeevoTheme.bgElevated
                    }
                    .frame(width: artworkSize, height: artworkSize)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: .black.opacity(0.4), radius: 20, y: 10)

                    Spacer(minLength: 32)

                    VStack(spacing: 6) {
                        Text(track.title)
                            .font(.title3.bold())
                            .foregroundStyle(DeevoTheme.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        Text(track.artist)
                            .font(.subheadline)
                            .foregroundStyle(DeevoTheme.textDim)
                    }
                    .padding(.horizontal, 32)

                    Spacer(minLength: 28)

                    VStack(spacing: 6) {
                        Slider(
                            value: Binding(get: { player.currentTime }, set: { player.seek(to: $0) }),
                            in: 0...max(player.duration, 1)
                        )
                        .tint(DeevoTheme.accentBright)
                        HStack {
                            Text(formatTime(player.currentTime)).font(.caption).foregroundStyle(DeevoTheme.textDim)
                            Spacer()
                            Text(formatTime(player.duration)).font(.caption).foregroundStyle(DeevoTheme.textDim)
                        }
                    }
                    .padding(.horizontal, 28)

                    Spacer(minLength: 28)

                    HStack(spacing: 44) {
                        Button { player.playPrevious() } label: {
                            Image(systemName: "backward.fill")
                                .font(.title2)
                                .foregroundStyle(DeevoTheme.textPrimary)
                        }
                        Button { player.togglePlayPause() } label: {
                            Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 68))
                                .foregroundStyle(DeevoTheme.textPrimary)
                        }
                        Button { player.playNext() } label: {
                            Image(systemName: "forward.fill")
                                .font(.title2)
                                .foregroundStyle(DeevoTheme.textPrimary)
                        }
                    }

                    Spacer(minLength: 24)

                    Button {
                        favorites.toggle(track)
                    } label: {
                        Image(systemName: favorites.contains(track) ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundStyle(favorites.contains(track) ? .red : DeevoTheme.textDim)
                    }

                    Spacer(minLength: 32)
                } else {
                    Spacer()
                    Text("Aucune lecture en cours").foregroundStyle(DeevoTheme.textDim)
                    Spacer()
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .background(DeevoTheme.bgVoid.ignoresSafeArea())
    }

    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }
        let total = Int(seconds)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}
