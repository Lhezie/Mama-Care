import SwiftUI

struct AudioTrackCard: View {
    let track: AudioTrack
    let isPlaying: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Play/Pause Icon
                ZStack {
                    Circle()
                        .fill(isPlaying ? Color.mamaCarePrimary : Color.mamaCareGrayLight)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .foregroundColor(isPlaying ? .white : .mamaCarePrimary)
                        .font(.system(size: 20))
                }
                
                // Track Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(track.name)
                        .font(.headline)
                        .foregroundColor(.mamaCareTextPrimary)
                        .lineLimit(1)
                    
                    Text(track.description)
                        .font(.caption)
                        .foregroundColor(.mamaCareTextSecondary)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        Label(formatDuration(track.duration), systemImage: "clock")
                            .font(.caption2)
                            .foregroundColor(.mamaCareTextTertiary)
                        
                        Label(track.source.rawValue, systemImage: track.source == .local ? "iphone" : "cloud")
                            .font(.caption2)
                            .foregroundColor(.mamaCareTextTertiary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color.mamaCareGrayLight.opacity(0.3))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}
