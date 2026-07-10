//
//  BookingService.swift
//  Comfort Rides Pro
//

import Foundation
import Supabase

// MARK: - Profile

struct ProfileRow: Codable {
    let id: UUID
    let firstName: String?
    let lastName: String?
    let email: String?
    let phone: String?

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phone
    }

    var fullName: String {
        [firstName, lastName].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " ")
    }
}

private struct ProfileUpsert: Encodable {
    let id: UUID
    let email: String
    let firstName: String
    let lastName: String
    let phone: String

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case phone
    }
}

// MARK: - Booking service

struct BookingService {

    enum BookingError: LocalizedError {
        case notAuthenticated
        case missingRideDetails

        var errorDescription: String? {
            switch self {
            case .notAuthenticated: return "You must be signed in to book a ride."
            case .missingRideDetails: return "Some ride details are missing. Please go back and try again."
            }
        }
    }

    func saveProfile(firstName: String, lastName: String, phone: String = "") async throws {
        let user = try await supabase.auth.session.user
        let email = user.email ?? ""

        if !firstName.isEmpty || !lastName.isEmpty {
            // Sign-up path: write email + names to profiles
            try await supabase
                .from("profiles")
                .upsert(
                    ProfileUpsert(id: user.id, email: email, firstName: firstName, lastName: lastName, phone: phone),
                    onConflict: "id"
                )
                .execute()

            // Save phone number to auth.users
            if !phone.isEmpty {
                try await supabase.auth.update(user: UserAttributes(phone: phone))
            }
        } else {
            // Sign-in path: only ensure email is recorded, leave names untouched
            try await supabase
                .from("profiles")
                .upsert(["id": user.id.uuidString, "email": email],
                        onConflict: "id")
                .execute()
        }
    }

    func fetchProfile() async throws -> ProfileRow {
        let userId = try await supabase.auth.session.user.id
        let rows: [ProfileRow] = try await supabase
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .limit(1)
            .execute()
            .value
        guard let profile = rows.first else {
            return ProfileRow(id: userId, firstName: nil, lastName: nil, email: nil, phone: nil)
        }
        return profile
    }

    func createReservation(ride: Ride) async throws {
        guard let time = ride.time,
              let pickup = ride.pickUpLocation,
              let dropoff = ride.dropOffLocation,
              let carType = ride.carType else {
            throw BookingError.missingRideDetails
        }
        let userId = try await supabase.auth.session.user.id
        let insert = ReservationInsert(
            userId: userId,
            pickupAt: time,
            pickupLocation: pickup,
            dropoffLocation: dropoff,
            carTypeId: carType.supabaseId,
            standbyHours: ride.layover,
            note: ride.note
        )
        try await supabase.from("reservations").insert(insert).execute()
    }

    func cancelReservation(id: UUID) async throws {
        try await supabase
            .from("reservations")
            .update(["status": "cancelled"])
            .eq("id", value: id.uuidString)
            .execute()
    }

    func fetchCarTypes() async throws -> [CarTypeRow] {
        let rows: [CarTypeRow] = try await supabase
            .from("car_types")
            .select()
            .eq("active", value: true)
            .order("sort_order", ascending: true)
            .execute()
            .value
        return rows
    }

    func fetchUpcomingReservations() async throws -> [ReservationRow] {
        let userId = try await supabase.auth.session.user.id
        let now = ISO8601DateFormatter().string(from: Date())
        let rows: [ReservationRow] = try await supabase
            .from("reservations")
            .select()
            .eq("user_id", value: userId.uuidString)
            .neq("status", value: "cancelled")
            .gt("pickup_at", value: now)
            .order("pickup_at", ascending: true)
            .execute()
            .value
        return rows
    }
}
