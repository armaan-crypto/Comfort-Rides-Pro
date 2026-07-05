//
//  ReservationRow.swift
//  Comfort Rides Pro
//

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
