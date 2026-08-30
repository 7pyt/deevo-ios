import SwiftUI

@main
struct DeevoApp: App {
    // Instance unique partagée par toute l'app (lecture, file d'attente,
    // intégration écran verrouillé) — voir AudioPlayerManager.swift.
    @StateObject private var player = AudioPlayerManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(player)
        }
    }
}
