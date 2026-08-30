import SwiftUI

struct ContentView: View {
    @EnvironmentObject var player: AudioPlayerManager

    init() {
        // Forcé en dark partout (l'app desktop n'a qu'un seul thème, très
        // sombre) et TabBar/NavBar repeintes aux couleurs du thème.
        UITabBar.appearance().barTintColor = UIColor(DeevoTheme.bgPanel)
        UITabBar.appearance().backgroundColor = UIColor(DeevoTheme.bgPanel)
        UITabBar.appearance().unselectedItemTintColor = UIColor(DeevoTheme.textFaint)

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(DeevoTheme.bgVoid)
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor(DeevoTheme.textPrimary)]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(DeevoTheme.textPrimary)]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    }

    var body: some View {
        TabView {
            NavigationStack { SearchView() }
                .tabItem { Label("Rechercher", systemImage: "magnifyingglass") }

            NavigationStack { FavoritesView() }
                .tabItem { Label("Favoris", systemImage: "heart.fill") }

            NavigationStack { SettingsView() }
                .tabItem { Label("Réglages", systemImage: "gearshape") }
        }
        .tint(DeevoTheme.accentBright)
        .preferredColorScheme(.dark)
        .safeAreaInset(edge: .bottom) {
            if player.currentTrack != nil {
                MiniPlayerView()
            }
        }
    }
}
