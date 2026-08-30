import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var player: AudioPlayerManager
    @StateObject private var store = FavoritesStore.shared

    var body: some View {
        ZStack {
            DeevoTheme.bgVoid.ignoresSafeArea()

            if store.tracks.isEmpty {
                EmptyStateView(icon: "heart", text: "Aucun favori pour l'instant")
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(store.tracks) { track in
                            Button {
                                player.play(track: track, queue: store.tracks)
                            } label: {
                                TrackRow(track: track, isPlaying: player.currentTrack == track && player.isPlaying)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("Favoris")
    }
}
