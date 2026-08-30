import SwiftUI

struct SearchView: View {
    @EnvironmentObject var player: AudioPlayerManager
    @State private var query = ""
    @State private var results: [Track] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        List(results) { track in
            Button {
                player.play(track: track, queue: results)
            } label: {
                TrackRow(track: track)
            }
        }
        .listStyle(.plain)
        .searchable(text: $query, prompt: "Titre, artiste…")
        .onSubmit(of: .search, runSearch)
        .navigationTitle("Deevo")
        .overlay {
            if isLoading {
                ProgressView()
            } else if let errorMessage {
                VStack(spacing: 8) {
                    Image(systemName: "wifi.slash").font(.largeTitle).foregroundStyle(.secondary)
                    Text(errorMessage).foregroundStyle(.secondary)
                }
            } else if results.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "music.note").font(.largeTitle).foregroundStyle(.secondary)
                    Text("Cherche un titre ou un artiste").foregroundStyle(.secondary)
                }
            }
        }
    }

    private func runSearch() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        Task {
            do {
                results = try await APIClient.shared.search(query: trimmed)
                if results.isEmpty { errorMessage = nil }
            } catch {
                errorMessage = "Impossible de contacter le serveur. Vérifie l'URL dans Réglages."
            }
            isLoading = false
        }
    }
}

struct TrackRow: View {
    let track: Track

    var body: some View {
        HStack {
            AsyncImage(url: track.artworkURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 46, height: 46)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading) {
                Text(track.title).lineLimit(1)
                Text(track.artist).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
        }
    }
}
