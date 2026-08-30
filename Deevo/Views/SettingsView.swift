import SwiftUI

struct SettingsView: View {
    @AppStorage("deevo.baseURL") private var baseURL: String = APIConfig.defaultBaseURL

    var body: some View {
        Form {
            Section("Serveur") {
                TextField("https://ton-backend.kdns.fr", text: $baseURL)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(.URL)

                Text("Doit exposer GET /search?q=… et GET /stream/:id, comme le serveur local de la version desktop — mais accessible depuis Internet (Katabump, Render…).")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Réglages")
    }
}
