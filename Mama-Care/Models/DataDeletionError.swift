import Foundation

enum DataDeletionError: LocalizedError {
    case noUserFound
    case swiftDataDeletionFailed
    case firebaseDeletionFailed
    case signOutFailed
    
    var errorDescription: String? {
        switch self {
        case .noUserFound:
            return "No user data found to delete."
        case .swiftDataDeletionFailed:
            return "Unable to delete local data. Please try again."
        case .firebaseDeletionFailed:
            return "Unable to delete cloud data. Please check your connection and try again."
        case .signOutFailed:
            return "Data deleted but failed to sign out. Please restart the app."
        }
    }
}
