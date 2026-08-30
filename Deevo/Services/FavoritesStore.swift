import Foundation

@MainActor
final class FavoritesStore: ObservableObject {
    static let shared = FavoritesStore()

    @Published private(set) var tracks: [Track] = []
    private let key = "deevo.favorites"

    private init() { load() }

    func toggle(_ track: Track) {
        if let idx = tracks.firstIndex(of: track) {
            tracks.remove(at: idx)
        } else {
            tracks.append(track)
        }
        save()
    }

    func contains(_ track: Track) -> Bool {
        tracks.contains(track)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Track].self, from: data) else { return }
        tracks = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(tracks) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
