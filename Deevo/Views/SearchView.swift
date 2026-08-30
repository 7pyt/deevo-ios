import SwiftUI

struct SearchView: View {
    @EnvironmentObject var player: AudioPlayerManager
    @State private var query = ""
    @State private var results: [Track] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            DeevoTheme.bgVoid.ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(results) { track in
                        Button {
                            player.play(track: track, queue: results)
                        } label: {
                            TrackRow(track: track, isPlaying: player.currentTrack == track && player.isPlaying)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
            .scrollDismissesKeyboard(.immediately)

            if isLoading {
                ProgressView().tint(DeevoTheme.accentBright)
            } else if let errorMessage {
                EmptyStateView(icon: "wifi.slash", text: errorMessage)
            } else if results.isEmpty {
                EmptyStateView(icon: "music.note", text: "Cherche un titre ou un artiste")
            }
        }
        .searchable(text: $query, prompt: "Titre, artiste…")
        .onSubmit(of: .search, runSearch)
        .navigationTitle("Deevo")
    }

    private func runSearch() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        Task {
            do {
                results = try await APIClient.shared.search(query: trimmed)
            } catch {
                errorMessage = "Impossible de contacter le serveur. Vérifie l'URL dans Réglages."
            }
            isLoading = false
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let text: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 34))
                .foregroundStyle(DeevoTheme.textFaint)
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(DeevoTheme.textDim)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
    }
}

// Reprend la mise en page des lignes de la bibliothèque desktop : pochette
// carrée arrondie, titre en clair, artiste en atténué, accent orange quand
// le morceau est en cours de lecture.
struct TrackRow: View {
    let track: Track
    var isPlaying: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: track.artworkURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                DeevoTheme.bgElevated
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: DeevoTheme.radiusXS, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(track.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isPlaying ? DeevoTheme.accentBright : DeevoTheme.textPrimary)
                    .lineLimit(1)
                Text(track.artist)
                    .font(.system(size: 12))
                    .foregroundStyle(DeevoTheme.textDim)
                    .lineLimit(1)
            }

            Spacer()

            if isPlaying {
                Image(systemName: "waveform")
                    .font(.system(size: 14))
                    .foregroundStyle(DeevoTheme.accentBright)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: DeevoTheme.radiusS, style: .continuous)
                .fill(isPlaying ? DeevoTheme.accentDim : DeevoTheme.bgPanel2)
        )
    }
}
