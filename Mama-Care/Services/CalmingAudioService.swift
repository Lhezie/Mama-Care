import Foundation
import AVFoundation

@MainActor
class CalmingAudioService: ObservableObject {
    static let shared = CalmingAudioService()
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {}
    
    //  Local Audio Files
    
    func getLocalAudio() -> [AudioTrack] {
        print("Loading local calming audio...")
        
        // Define bundled audio files
        let localTracks = [
            AudioTrack(
                id: "ocean_waves",
                name: "Ocean Waves",
                description: "Gentle ocean waves for relaxation",
                duration: 300, 
                source: .local,
                url: Bundle.main.url(forResource: "ocean_waves", withExtension: "mp3")
            ),
            AudioTrack(
                id: "rain_sounds",
                name: "Rain Sounds",
                description: "Soft rain for peaceful moments",
                duration: 300,
                source: .local,
                url: Bundle.main.url(forResource: "rain_sounds", withExtension: "mp3")
            ),
            AudioTrack(
                id: "forest_ambience",
                name: "Forest Ambience",
                description: "Birds chirping in a peaceful forest",
                duration: 300,
                source: .local,
                url: Bundle.main.url(forResource: "forest_ambience", withExtension: "mp3")
            )
            
        ]
        
        // Filter out tracks where audio file is missing
        let availableTracks = localTracks.filter { $0.url != nil }
        
        if availableTracks.isEmpty {
            print("No local audio files found in bundle")
            // Don't set errorMessage here, let the fallback happen
        } else {
            print("Loaded \(availableTracks.count) local audio tracks")
        }
        
        return availableTracks
    }
    
    //  Freesound API
    
    func fetchAPIAudio() async throws -> [AudioTrack] {
        print("Fetching calming audio from Freesound API...")
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        // Freesound API endpoint (no API key needed for basic search)
        let searchTerms = ["meditation", "calm", "relaxation", "peaceful"]
        let randomTerm = searchTerms.randomElement() ?? "meditation"
        
        let urlString = "https://freesound.org/apiv2/search/text/?query=\(randomTerm)&filter=duration:[60 TO 600]&fields=id,name,description,duration,previews&page_size=10"
        
        guard let url = URL(string: urlString) else {
            throw NSError(
                domain: "CalmingAudioService",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Invalid API URL"]
            )
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        request.setValue("Token \(Configuration.freesoundAPIKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(
                    domain: "CalmingAudioService",
                    code: 500,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"]
                )
            }
            
            guard httpResponse.statusCode == 200 else {
                throw NSError(
                    domain: "CalmingAudioService",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Unable to load calming sounds. Please check your internet connection."]
                )
            }
            
            let decoder = JSONDecoder()
            let searchResponse = try decoder.decode(FreesoundSearchResponse.self, from: data)
            
            // Convert to AudioTrack
            let tracks = searchResponse.results.compactMap { sound -> AudioTrack? in
                guard let previewURL = sound.previews.previewLqMp3 ?? sound.previews.previewHqMp3,
                      let url = URL(string: previewURL) else {
                    return nil
                }
                
                return AudioTrack(
                    id: String(sound.id),
                    name: sound.name,
                    description: sound.description ?? "Calming audio",
                    duration: Int(sound.duration),
                    source: .online,
                    url: url
                )
            }
            
            print("Fetched \(tracks.count) audio tracks from API")
            return tracks
            
        } catch let error as DecodingError {
            print("Decoding error: \(error)")
            throw NSError(
                domain: "CalmingAudioService",
                code: 500,
                userInfo: [NSLocalizedDescriptionKey: "Unable to process audio data. Please try again."]
            )
        } catch {
            print("Network error: \(error)")
            throw NSError(
                domain: "CalmingAudioService",
                code: 500,
                userInfo: [NSLocalizedDescriptionKey: "Unable to load calming sounds. Please check your internet connection."]
            )
        }
    }
    
    // Hybrid Selection for audio tracks
    
    func getAudioTracks(for storageMode: StorageMode) async throws -> [AudioTrack] {
        // 1. load local bundled audio (preferred for offline)
        let localTracks = getLocalAudio()
        
        if !localTracks.isEmpty {
            print(" Using local audio tracks")
            return localTracks
        }
        
        // 2. Fallback to API if no local files found (or if user is cloud mode)
    
        print(" No local audio found. Falling back to API fetch...")
        return try await fetchAPIAudio()
    }
}
