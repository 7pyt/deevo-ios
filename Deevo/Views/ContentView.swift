import SwiftUI

struct ContentView: View {
    @EnvironmentObject var player: AudioPlayerManager

    var body: some View {
        TabView {
            NavigationStack { SearchView() }
                .tabItem { Label("Rechercher", systemImage: "magnifyingglass") }

            NavigationStack { FavoritesView() }
                .tabItem { Label("Favoris", systemImage: "heart.fill") }

            NavigationStack { SettingsView() }
                .tabItem { Label("Réglages", systemImage: "gearshape") }
        }
        .safeAreaInset(edge: .bottom) {
            if player.currentTrack != nil {
                MiniPlayerView()
            }
        }
    }
}
