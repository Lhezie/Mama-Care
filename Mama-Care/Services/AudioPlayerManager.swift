import Foundation
import AVFoundation

@MainActor
class AudioPlayerManager: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTrack: AudioTrack?
    
    private var player: AVPlayer?
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func play(track: AudioTrack) {
        guard let url = track.url else {
            print("No URL for track: \(track.name)")
            return
        }
        
        // Stop current playback
        stop()
        
        // Create new player
        player = AVPlayer(url: url)
        currentTrack = track
        
        // Start playback
        player?.play()
        isPlaying = true
        
        print("Playing: \(track.name)")
        
        // Observe when track ends
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.stop()
        }
    }
    
    func togglePlayPause() {
        guard let player = player else { return }
        
        if isPlaying {
            player.pause()
            isPlaying = false
            print("Paused")
        } else {
            player.play()
            isPlaying = true
            print("Resumed")
        }
    }
    
    func stop() {
        player?.pause()
        player = nil
        isPlaying = false
        currentTrack = nil
        print("Stopped")
    }
}
