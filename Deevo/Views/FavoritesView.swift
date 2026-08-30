import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var player: AudioPlayerManager
    @StateObject private var store = FavoritesStore.shared

    var body: some View {
        List(store.tracks) { track in
            Button {
                player.play(track: track, queue: store.tracks)
            } label: {
                TrackRow(track: track)
            }
        }
        .listStyle(.plain)
        .overlay {
            if store.tracks.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "heart").font(.largeTitle).foregroundStyle(.secondary)
                    Text("Aucun favori pour l'instant").foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Favoris")
    }
}
