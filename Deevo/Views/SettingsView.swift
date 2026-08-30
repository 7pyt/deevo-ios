import SwiftUI

struct SettingsView: View {
    @AppStorage("deevo.baseURL") private var baseURL: String = APIConfig.defaultBaseURL

    var body: some View {
        ZStack {
            DeevoTheme.bgVoid.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("SERVEUR")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(DeevoTheme.textFaint)
                        .padding(.horizontal, 4)

                    VStack(alignment: .leading, spacing: 10) {
                        TextField("https://xxxx.ngrok-free.app", text: $baseURL)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .keyboardType(.URL)
                            .foregroundStyle(DeevoTheme.textPrimary)
                            .tint(DeevoTheme.accentBright)

                        Text("URL ngrok (ou autre) du serveur qui expose /search et /stream/:id — voir server.js.")
                            .font(.system(size: 12))
                            .foregroundStyle(DeevoTheme.textFaint)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: DeevoTheme.radiusS, style: .continuous)
                            .fill(DeevoTheme.bgPanel2)
                    )
                }
                .padding(16)
            }
        }
        .navigationTitle("Réglages")
    }
}
