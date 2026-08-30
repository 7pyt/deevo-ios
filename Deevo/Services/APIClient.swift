import Foundation

// Un iPhone ne peut pas atteindre le 127.0.0.1 du serveur Node local de la
// version desktop — il faut un backend accessible depuis Internet qui
// expose les deux mêmes routes :
//   GET /search?q=<texte>   -> [{ id, title, artist, artworkUrl, durationSeconds }]
//   GET /stream/<id>        -> flux audio (redirect ou proxy, comme sur desktop)
// Change l'URL par défaut une fois ton backend déployé (Katabump, Render...),
// ou laisse tel quel et configure-la depuis l'app (onglet Réglages) sans
// recompiler.
enum APIConfig {
    static let defaultBaseURL = "https://TON-BACKEND.kdns.fr"
}

final class APIClient {
    static let shared = APIClient()

    var baseURL: URL {
        let stored = UserDefaults.standard.string(forKey: "deevo.baseURL")
        return URL(string: (stored?.isEmpty == false ? stored! : APIConfig.defaultBaseURL))
            ?? URL(string: APIConfig.defaultBaseURL)!
    }

    func search(query: String) async throws -> [Track] {
        guard var comps = URLComponents(url: baseURL.appendingPathComponent("search"), resolvingAgainstBaseURL: false) else {
            throw URLError(.badURL)
        }
        comps.queryItems = [URLQueryItem(name: "q", value: query)]
        guard let url = comps.url else { throw URLError(.badURL) }

        let (data, response) = try await URLSession.shared.data(from: url)
        try Self.checkStatus(response)
        return try JSONDecoder().decode([Track].self, from: data)
    }

    func streamURL(for trackId: String) -> URL {
        baseURL.appendingPathComponent("stream/\(trackId)")
    }

    // Fire-and-forget : lance la résolution du flux côté serveur sans
    // attendre la réponse. Appelé dès qu'un résultat apparaît dans la
    // liste, pour que le morceau soit déjà prêt (ou en cours de l'être)
    // au moment où l'utilisateur appuie vraiment sur play.
    func prefetch(trackId: String) {
        let url = baseURL.appendingPathComponent("prefetch/\(trackId)")
        Task.detached(priority: .background) {
            _ = try? await URLSession.shared.data(from: url)
        }
    }

    private static func checkStatus(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
