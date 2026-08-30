import ActivityKit
import Foundation

// Partagé entre la cible "Deevo" (qui démarre/met à jour l'activité) et la
// cible "DeevoWidgets" (qui l'affiche dans le Dynamic Island / écran
// verrouillé). Les deux tournent dans des process séparés — c'est le système
// (ActivityKit) qui synchronise ce ContentState entre les deux, pas nous.
struct DeevoActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var title: String
        var artist: String
        var artworkURL: String?
        var isPlaying: Bool
        var elapsed: Double
        var duration: Double
    }

    // Attributs fixes pour toute la durée de vie de l'activité (n'importe
    // quel changement de morceau termine l'activité précédente et en
    // redémarre une nouvelle avec un trackId différent).
    var trackId: String
}
