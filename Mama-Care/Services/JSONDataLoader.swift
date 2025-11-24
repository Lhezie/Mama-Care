//
//  JSONDataLoader.swift
//  Mama-Care
//
//  Created for JSON data integration
//

import Foundation

enum JSONDataLoaderError: Error {
    case fileNotFound(String)
    case invalidData
    case decodingError(Error)
    
    var localizedDescription: String {
        switch self {
        case .fileNotFound(let filename):
            return "JSON file not found: \(filename)"
        case .invalidData:
            return "Invalid JSON data"
        case .decodingError(let error):
            return "Failed to decode JSON: \(error.localizedDescription)"
        }
    }
}

class JSONDataLoader {
    
    /// Load and decode JSON file from the app bundle
    static func loadJSON<T: Decodable>(filename: String, type: T.Type) -> Result<T, JSONDataLoaderError> {
        // Get the file URL from the bundle
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("❌ JSONDataLoader: File not found - \(filename).json")
            return .failure(.fileNotFound(filename))
        }
        
        do {
            // Load the data
            let data = try Data(contentsOf: url)
            
            // Decode the JSON
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(T.self, from: data)
            
            print("✅ JSONDataLoader: Successfully loaded \(filename).json")
            return .success(decoded)
            
        } catch let decodingError as DecodingError {
            print("❌ JSONDataLoader: Decoding error for \(filename).json")
            print("   Error: \(decodingError)")
            return .failure(.decodingError(decodingError))
            
        } catch {
            print("❌ JSONDataLoader: Failed to load \(filename).json")
            print("   Error: \(error)")
            return .failure(.decodingError(error))
        }
    }
    
    /// Convenience method to load nutrition data
    static func loadNutritionData() -> NutritionData? {
        let result = loadJSON(filename: "nutrition_data", type: NutritionData.self)
        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            print("Failed to load nutrition data: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Convenience method to load vaccine schedule
    static func loadVaccineSchedule(country: String) -> VaccineScheduleData? {
        // Normalize country input to handle both full names and country codes
        let normalizedCountry = country.uppercased()
        
        // Determine which schedule to load based on country name or code
        let isNigeria = normalizedCountry == "NIGERIA" || normalizedCountry == "NG"
        let filename = isNigeria ? "ng_vaccination_schedule" : "uk_vaccination_schedule"
        
        print("🔍 Loading vaccine schedule")
        
        let result = loadJSON(filename: filename, type: VaccineScheduleData.self)
        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            print("Failed to load vaccine schedule: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Convenience method to load postpartum data
    static func loadPostpartumData() -> [PostpartumDay]? {
        print("🔍 Loading postpartum data...")
        let result = loadJSON(filename: "postpartum_motivation", type: [PostpartumDataWrapper].self)
        switch result {
        case .success(let wrappers):
            print("✅ Loaded \(wrappers.count) wrapper(s)")
            // The JSON is an array with one wrapper object
            if let days = wrappers.first?.postpartumDays {
                print("✅ Found \(days.count) postpartum days")
                return days
            } else {
                print("⚠️ No postpartumDays found in wrapper")
                return nil
            }
        case .failure(let error):
            print("❌ Failed to load postpartum data: \(error.localizedDescription)")
            return nil
        }
    }
}
