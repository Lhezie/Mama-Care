import SwiftUI
import AVFoundation

struct CalmingAudioView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: MamaCareViewModel
    @StateObject private var audioService = CalmingAudioService.shared
    @StateObject private var audioPlayer = AudioPlayerManager()
    
    @State private var tracks: [AudioTrack] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading calming sounds...")
                            .foregroundColor(.mamaCareTextSecondary)
                    }
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(.mamaCareTextTertiary)
                        
                        Text("Unable to Load Audio")
                            .font(.headline)
                            .foregroundColor(.mamaCareTextPrimary)
                        
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.mamaCareTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Try Again") {
                            loadAudio()
                        }
                        .foregroundColor(.mamaCarePrimary)
                    }
                } else if tracks.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "music.note")
                            .font(.system(size: 48))
                            .foregroundColor(.mamaCareTextTertiary)
                        
                        Text("No Audio Available")
                            .font(.headline)
                            .foregroundColor(.mamaCareTextPrimary)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Header
                            VStack(spacing: 8) {
                                Image(systemName: "waveform")
                                    .font(.system(size: 40))
                                    .foregroundColor(.mamaCarePrimary)
                                
                                Text("Calming Sounds")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.mamaCareTextPrimary)
                                
                                Text("Take a moment to relax and breathe")
                                    .font(.subheadline)
                                    .foregroundColor(.mamaCareTextSecondary)
                            }
                            .padding()
                            
                            // Audio tracks
                            ForEach(tracks) { track in
                                AudioTrackCard(
                                    track: track,
                                    isPlaying: audioPlayer.currentTrack?.id == track.id && audioPlayer.isPlaying,
                                    onTap: {
                                        if audioPlayer.currentTrack?.id == track.id {
                                            audioPlayer.togglePlayPause()
                                        } else {
                                            audioPlayer.play(track: track)
                                        }
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Calming Audio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        audioPlayer.stop()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadAudio()
            }
            .onDisappear {
                audioPlayer.stop()
            }
        }
    }
    
    private func loadAudio() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let storageMode = viewModel.currentUser?.storageMode ?? .deviceOnly
                tracks = try await audioService.getAudioTracks(for: storageMode)
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

#Preview {
    CalmingAudioView()
        .environmentObject(MamaCareViewModel())
}
