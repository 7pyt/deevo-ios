import Foundation
import AVFoundation
import MediaPlayer
import UIKit

// Gère : la lecture réelle (AVPlayer), la file d'attente, et l'affichage
// des infos + boutons sur l'écran verrouillé / le centre de contrôle
// (MPNowPlayingInfoCenter + MPRemoteCommandCenter). C'est ce fichier qui
// répond à "le lecteur dans l'écran verrouillé".
@MainActor
final class AudioPlayerManager: ObservableObject {
    static let shared = AudioPlayerManager()

    @Published var currentTrack: Track?
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var queue: [Track] = []
    @Published var queueIndex: Int = 0

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var statusObservation: NSKeyValueObservation?
    private var artworkImage: UIImage?

    private init() {
        configureAudioSession()
        configureRemoteCommands()
    }

    // MARK: - Session audio
    // .playback + UIBackgroundModes:audio (voir project.yml) = lecture qui
    // continue écran éteint / app en arrière-plan, avec contrôles sur
    // l'écran verrouillé.
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            print("Erreur AVAudioSession :", error)
        }
    }

    // MARK: - Lecture

    func play(track: Track, queue newQueue: [Track]? = nil) {
        if let newQueue {
            queue = newQueue
            queueIndex = newQueue.firstIndex(of: track) ?? 0
        }
        currentTrack = track
        artworkImage = nil
        duration = 0
        currentTime = 0

        let url = APIClient.shared.streamURL(for: track.id)
        let item = AVPlayerItem(url: url)

        player?.pause()
        removeTimeObserver()
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)

        player = AVPlayer(playerItem: item)
        player?.automaticallyWaitsToMinimizeStalling = true

        statusObservation = item.observe(\.status) { [weak self] observedItem, _ in
            guard let self else { return }
            Task { @MainActor in
                if observedItem.status == .readyToPlay {
                    let seconds = observedItem.duration.seconds
                    self.duration = seconds.isFinite ? seconds : 0
                    self.updateNowPlayingInfo()
                } else if observedItem.status == .failed {
                    print("Lecture impossible :", observedItem.error?.localizedDescription ?? "erreur inconnue")
                }
            }
        }

        NotificationCenter.default.addObserver(
            self, selector: #selector(trackDidFinish),
            name: .AVPlayerItemDidPlayToEndTime, object: item
        )

        addTimeObserver()
        player?.play()
        isPlaying = true
        fetchArtwork(for: track)
        updateNowPlayingInfo()
    }

    func togglePlayPause() {
        guard let player else { return }
        if isPlaying { player.pause() } else { player.play() }
        isPlaying.toggle()
        updateNowPlayingInfo()
    }

    func seek(to seconds: Double) {
        player?.seek(to: CMTime(seconds: seconds, preferredTimescale: 1000))
        currentTime = seconds
        updateNowPlayingInfo()
    }

    func playNext() {
        guard !queue.isEmpty, queueIndex + 1 < queue.count else { return }
        queueIndex += 1
        play(track: queue[queueIndex])
    }

    func playPrevious() {
        guard !queue.isEmpty, queueIndex > 0 else { return }
        queueIndex -= 1
        play(track: queue[queueIndex])
    }

    @objc private func trackDidFinish() {
        playNext()
    }

    private func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            self.currentTime = time.seconds
            self.updateNowPlayingInfo(elapsedOnly: true)
        }
    }

    private func removeTimeObserver() {
        if let timeObserver { player?.removeTimeObserver(timeObserver) }
        timeObserver = nil
    }

    // MARK: - Écran verrouillé / Centre de contrôle

    private func configureRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            self.player?.play()
            self.isPlaying = true
            self.updateNowPlayingInfo()
            return .success
        }
        center.pauseCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            self.player?.pause()
            self.isPlaying = false
            self.updateNowPlayingInfo()
            return .success
        }
        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }
        center.nextTrackCommand.addTarget { [weak self] _ in
            self?.playNext()
            return .success
        }
        center.previousTrackCommand.addTarget { [weak self] _ in
            self?.playPrevious()
            return .success
        }
        center.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self, let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self.seek(to: event.positionTime)
            return .success
        }
    }

    private func updateNowPlayingInfo(elapsedOnly: Bool = false) {
        guard let track = currentTrack else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }
        var info: [String: Any] = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]

        if !elapsedOnly {
            info[MPMediaItemPropertyTitle] = track.title
            info[MPMediaItemPropertyArtist] = track.artist
            info[MPMediaItemPropertyPlaybackDuration] = duration
            if let artworkImage {
                info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artworkImage.size) { _ in artworkImage }
            }
        }
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func fetchArtwork(for track: Track) {
        guard let url = track.artworkURL else { return }
        Task {
            guard let (data, _) = try? await URLSession.shared.data(from: url),
                  let image = UIImage(data: data) else { return }
            await MainActor.run {
                guard self.currentTrack == track else { return } // évite une pochette obsolète si l'utilisateur a déjà changé de morceau
                self.artworkImage = image
                self.updateNowPlayingInfo()
            }
        }
    }
}
