//
//  ReservationRow.swift
//  Comfort Rides Pro
//

// MARK: - Car type (from car_types table)

struct CarTypeRow: Codable, Identifiable {
    let id: String               // "sedan" | "suv"
    let displayName: String
    let seats: Int
    let features: [String]
    let hourlyRateCents: Int
    let sortOrder: Int
    let active: Bool

    var hourlyRateFormatted: String { "$\(hourlyRateCents / 100)/hr" }

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case seats
        case features
        case hourlyRateCents = "hourly_rate_cents"
        case sortOrder = "sort_order"
        case active
    }
}

import Foundation

struct ReservationRow: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let pickupAt: Date
    let pickupLocation: String
    let dropoffLocation: String
    let carTypeId: String
    let standbyHours: Int
    let note: String
    let status: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case pickupAt = "pickup_at"
        case pickupLocation = "pickup_location"
        case dropoffLocation = "dropoff_location"
        case carTypeId = "car_type_id"
        case standbyHours = "standby_hours"
        case note
        case status
    }
}

struct ReservationInsert: Encodable {
    let userId: UUID
    let pickupAt: Date
    let pickupLocation: String
    let dropoffLocation: String
    let carTypeId: String
    let standbyHours: Int
    let note: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case pickupAt = "pickup_at"
        case pickupLocation = "pickup_location"
        case dropoffLocation = "dropoff_location"
        case carTypeId = "car_type_id"
        case standbyHours = "standby_hours"
        case note
    }
}
