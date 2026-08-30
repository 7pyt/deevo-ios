import Foundation

// Doit correspondre à ce que renvoie le backend sur GET /search?q=...
// (voir APIClient.swift). "id" est l'identifiant que le backend sait
// résoudre en flux audio réel via GET /stream/:id — dans la version
// desktop c'est l'ID YouTube utilisé par yt-dlp.
struct Track: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let title: String
    let artist: String
    let artworkUrl: String?
    let durationSeconds: Int?

    var artworkURL: URL? {
        guard let artworkUrl else { return nil }
        return URL(string: artworkUrl)
    }
}
