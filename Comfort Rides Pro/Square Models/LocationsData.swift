// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let locationsData = try? JSONDecoder().decode(LocationsData.self, from: jsonData)

import Foundation

// MARK: - LocationsData
struct LocationsData: Codable {
    let locations: [Location]
}

// MARK: - Location
struct Location: Codable {
    let id, name: String
}
