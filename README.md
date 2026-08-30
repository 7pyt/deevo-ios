# Deevo iOS — étapes exactes

## Ce qui est fait ici
- App SwiftUI native : recherche, favoris, lecteur avec écran verrouillé /
  centre de contrôle fonctionnels (MPNowPlayingInfoCenter + MPRemoteCommandCenter).
- Le projet Xcode (`.xcodeproj`) n'est PAS commité : il est généré à la volée
  par XcodeGen à partir de `project.yml`, aussi bien en local que dans le
  build GitHub Actions. Ça évite les conflits/bugs classiques d'un
  `.xcodeproj` écrit à la main.
- Le build GitHub Actions produit un **.ipa non signé** — c'est toi qui
  signes ensuite, comme demandé.

## Ce qui N'EST PAS fait (à faire ensuite)
L'app appelle un backend qui doit exposer :
```
GET /search?q=<texte>   -> [{ "id": "...", "title": "...", "artist": "...", "artworkUrl": "...", "durationSeconds": 123 }]
GET /stream/<id>        -> flux audio
```
C'est exactement ce que fait déjà `main.js` de la version desktop
(`music:streamUrl` → `http://127.0.0.1:PORT/stream/:id`), sauf qu'un iPhone
ne peut pas taper du 127.0.0.1 : il faut héberger cette partie (yt-dlp +
recherche) sur un serveur accessible depuis Internet — Katabump, comme pour
le système de ban qu'on avait commencé. Tant que ce backend n'est pas en
ligne, l'app se lance et s'affiche très bien, mais la recherche ne
renverra rien (message "Impossible de contacter le serveur").

## Étape 1 — Créer le repo GitHub
1. Sur GitHub, crée un nouveau repo, **public** (les builds macOS sont
   gratuits et illimités sur un repo public ; sur un repo privé, macOS
   consomme 10x plus vite ton quota gratuit de minutes).
2. Mets-y exactement l'arborescence de ce dossier :
   ```
   project.yml
   Deevo/
     DeevoApp.swift
     Models/Track.swift
     Services/APIClient.swift
     Services/AudioPlayerManager.swift
     Services/FavoritesStore.swift
     Views/ContentView.swift
     Views/SearchView.swift
     Views/FavoritesView.swift
     Views/MiniPlayerView.swift
     Views/PlayerView.swift
     Views/SettingsView.swift
   .github/workflows/build-ipa.yml
   .gitignore
   ```
3. Push sur la branche `main`.

## Étape 2 — Lancer le build
- Le push déclenche automatiquement le workflow (`on: push: main`).
- Ou manuellement : onglet **Actions** du repo → "Build unsigned IPA" →
  **Run workflow**.
- Ça prend 3-5 minutes.

## Étape 3 — Récupérer le .ipa
- Une fois le run vert, ouvre-le → section **Artifacts** en bas de page →
  télécharge `Deevo-unsigned-ipa` (c'est un .zip contenant `Deevo-unsigned.ipa`).

## Étape 4 — Signer toi-même
Tu l'as dit, tu t'en charges, mais pour mémoire les options courantes :
- **Sideloadly** (Windows/Mac, gratuit) : glisse le .ipa, connecte l'iPhone,
  Apple ID gratuit suffit → app valable 7 jours, à re-signer ensuite.
- **AltStore** : même principe, avec re-signature automatique en arrière-plan
  tant que le téléphone est sur le même Wi-Fi que ton PC de temps en temps.
- **Compte développeur Apple payant (99$/an)** + `codesign`/Xcode : app valable
  1 an, jusqu'à 100 appareils enregistrés (profil ad hoc).

## Modifier l'app ensuite
Après tout changement de fichier `.swift` ou de `project.yml`, il suffit de
push sur `main` : le workflow régénère le projet et rebuild automatiquement.
Aucune manip locale nécessaire — tu n'as même pas besoin d'un Mac pour
itérer, seulement pour signer à la fin (ou MacinCloud/Sideloadly qui n'en
demandent pas).
