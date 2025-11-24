//
//  VaccineModels.swift
//  Mama-Care
//
//  Created for JSON data integration
//

import Foundation

// MARK: - Vaccine Schedule Models

struct VaccineScheduleData: Codable {
    let meta: VaccineMeta
    let sources: [VaccineSource]?
    let schedule: [VaccineAppointment]
    let adolescent: [VaccineAppointment]?
    let selectivePrograms: [VaccineAppointment]?
    
    enum CodingKeys: String, CodingKey {
        case meta, sources, schedule, adolescent
        case selectivePrograms = "selective_programmes"
    }
}

struct VaccineMeta: Codable {
    let country: String
    let schemaVersion: String
    let generatedAt: String
    let notes: String
    
    enum CodingKeys: String, CodingKey {
        case country
        case schemaVersion = "schema_version"
        case generatedAt = "generated_at"
        case notes
    }
}

struct VaccineSource: Codable {
    let name: String
    let url: String
    let retrieved: String?
}

struct VaccineAppointment: Codable {
    let label: String?  // Optional because adolescent items don't have labels
    let ageDays: Int?
    let coadminGroup: String?
    let items: [VaccineItemDetail]?  // Optional because adolescent vaccines don't have items array
    let code: String?
    let name: String?
    let target: VaccineTarget?
    
    enum CodingKeys: String, CodingKey {
        case label
        case ageDays = "age_days"
        case coadminGroup = "coadmin_group"
        case items, code, name, target
    }
}

struct VaccineItemDetail: Codable {
    let code: String
    let name: String
    let route: String?
    let site: String?
    let antigens: [String]?
    let series: VaccineSeries?
    let paracetamolRecommended: Bool?
    let eligibility: VaccineEligibility?
    
    enum CodingKeys: String, CodingKey {
        case code, name, route, site, antigens, series, eligibility
        case paracetamolRecommended = "paracetamol_recommended"
    }
}

struct VaccineSeries: Codable {
    let name: String
    let doseNumber: Int
    let totalDoses: Int
    let minIntervalDaysToNext: Int?
    
    enum CodingKeys: String, CodingKey {
        case name
        case doseNumber = "dose_number"
        case totalDoses = "total_doses"
        case minIntervalDaysToNext = "min_interval_days_to_next"
    }
}

struct VaccineEligibility: Codable {
    let cohortKey: String?
    
    enum CodingKeys: String, CodingKey {
        case cohortKey = "cohort_key"
    }
}

struct VaccineTarget: Codable {
    let ageYearsMin: Int?
    let ageYearsMax: Int?
    let schoolYear: String?
    let sex: String?
    
    enum CodingKeys: String, CodingKey {
        case ageYearsMin = "age_years_min"
        case ageYearsMax = "age_years_max"
        case schoolYear = "school_year"
        case sex
    }
}
