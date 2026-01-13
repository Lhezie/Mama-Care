import Foundation

//  Audio Track Model

struct AudioTrack: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let duration: Int // in seconds
    let source: AudioSource
    var url: URL?
    
    enum AudioSource: String, Codable {
        case local = "Local"
        case online = "Online"
    }
}

//  Freesound API Response Models

struct FreesoundSearchResponse: Codable {
    let count: Int
    let results: [FreesoundSound]
}

struct FreesoundSound: Codable {
    let id: Int
    let name: String
    let description: String?
    let duration: Double
    let previews: FreesoundPreviews
    
    struct FreesoundPreviews: Codable {
        let previewHqMp3: String?
        let previewLqMp3: String?
        
        enum CodingKeys: String, CodingKey {
            case previewHqMp3 = "preview-hq-mp3"
            case previewLqMp3 = "preview-lq-mp3"
        }
    }
}
