//
//  BookingService.swift
//  Comfort Rides Pro
//

import Foundation

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
