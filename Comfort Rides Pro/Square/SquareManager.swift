//
//  SquareManager.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 3/25/23.
//

import Foundation
import MapKit

struct SquareManager {
    
    enum RideError: Error {
        case timeDoesntExist
        case pickupDoesntExist
        case dropoffDoesntExist
        case userIdNotFound
        case bookingError
    }
    
    enum LocationError: Error {
        case locationCouldntBeMade
    }
    
    func createLocation(with location: MKPlacemark, string: String) async throws -> String {
        //"\(placemark.subThoroughfare ?? "") \(placemark.thoroughfare ?? ""), \(placemark.locality ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.postalCode ?? ""), \(placemark.countryCode ?? "")"
        let parameters = "{\n    \"location\": {\n      \"address\": {\n        \"address_line_1\": \"\(location.subThoroughfare ?? "") \(location.thoroughfare ?? "")\",\n        \"postal_code\": \"\(location.postalCode ?? "")\",\n        \"country\": \"\(location.countryCode ?? "")\",\n        \"locality\": \"\(location.locality ?? "")\",\n        \"administrative_district_level_1\": \"\(location.administrativeArea ?? "")\"\n      },\n      \"name\": \"Customer - \(string)\",\n      \"business_name\": \"Customer Location\"\n    }\n  }"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: "https://connect.squareupsandbox.com/v2/locations")!,timeoutInterval: Double.infinity)
        request.addValue("2023-03-15", forHTTPHeaderField: "Square-Version")
        request.addValue("Bearer EAAAEEcmYwB9IfDVQphfWOj8pGHyzLnZyYhed8MHrnlcpyBErRxXcJyAIcofZF6Y", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("__cf_bm=z6EGQwxlLOy4uYAetF5hV8zp0ig3PxlOYiiYanQodyo-1681576000-0-AcWsWlcu7jEcmrN7Li+31QhmenSBdztsmexfv2e/LjQ7CbUnbq2mHImMTqSSFF1RoJu90f7Q00qB+ohEgBdmzwo=", forHTTPHeaderField: "Cookie")

        request.httpMethod = "POST"
        request.httpBody = postData

        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            guard let errorRes = try? JSONDecoder().decode(SquareErrorJSON.self, from: data) else { throw LocationError.locationCouldntBeMade }
            guard errorRes.errors.count > 0 else { throw LocationError.locationCouldntBeMade }
            guard errorRes.errors[0].detail == "Location names must be unique within a merchant account" else { throw LocationError.locationCouldntBeMade }
            
            var request = URLRequest(url: URL(string: "https://connect.squareupsandbox.com/v2/locations")!,timeoutInterval: Double.infinity)
            request.addValue("2023-03-15", forHTTPHeaderField: "Square-Version")
            request.addValue("Bearer EAAAEEcmYwB9IfDVQphfWOj8pGHyzLnZyYhed8MHrnlcpyBErRxXcJyAIcofZF6Y", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("__cf_bm=z6EGQwxlLOy4uYAetF5hV8zp0ig3PxlOYiiYanQodyo-1681576000-0-AcWsWlcu7jEcmrN7Li+31QhmenSBdztsmexfv2e/LjQ7CbUnbq2mHImMTqSSFF1RoJu90f7Q00qB+ohEgBdmzwo=", forHTTPHeaderField: "Cookie")

            request.httpMethod = "GET"

            let (d, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw LocationError.locationCouldntBeMade }
            guard let locationsData = try? JSONDecoder().decode(LocationsData.self, from: d) else { throw LocationError.locationCouldntBeMade }
            guard let locationId = locationsData.locations.first(where: { $0.name == "Customer - \(string)" }) else { throw LocationError.locationCouldntBeMade }
            return locationId.id
        }
        guard let createdLocation = try? JSONDecoder().decode(Location.self, from: data) else { throw LocationError.locationCouldntBeMade }
        return createdLocation.id
    }
    
    func book(ride: Ride) async throws {
        // Variables
        guard let time = ride.time else { throw RideError.timeDoesntExist }
        // Date
        let newFormatter = ISO8601DateFormatter()
        guard let time = ride.time else { throw RideError.timeDoesntExist }
        let dateStr = newFormatter.string(from: time)
        
        // User id
        guard let userId = UserDefaults.standard.string(forKey: U.userId) else { throw RideError.userIdNotFound }
        
        // Locations
        guard let p = ride.pickUpLocation else { throw RideError.pickupDoesntExist }
        guard let d = ride.dropOffLocation else { throw RideError.dropoffDoesntExist }
        
        // Service
        guard let c = ride.carType else { throw RideError.bookingError }
        let sid = c.serviceId()
        
        // Length
        var minutes = ""
        minutes = "60"
        
        try await bookRideAPI(with: ride, date: dateStr, uid: userId, minutes: minutes, locationId: p, dropOff: d, pickUp: p, serviceId: sid)
    }
    
    fileprivate func bookRideAPI(with ride: Ride, date: String, uid: String, minutes: String, locationId: String, dropOff: String, pickUp: String, serviceId: String) async throws {
        let parameters = "{\n    \"booking\": {\n      \"appointment_segments\": [\n        {\n          \"duration_minutes\": \(minutes),\n          \"service_variation_id\": \"\(serviceId)\",\n          \"team_member_id\": \"TMnxCtcwd8BjSXZ7\",\n          \"service_variation_version\": 1\n        }\n      ],\n      \"location_id\": \"L4SWGZGYQBBF9\",\n      \"location_type\": \"CUSTOMER_LOCATION\",\n      \"start_at\": \"\(date)\",\n      \"customer_note\": \"Booked from the Private Mobile app. Pickup location: \(pickUp). Drop off location: \(dropOff)\",\n      \"customer_id\": \"\(uid)\"\n    }\n  }"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: "https://connect.squareupsandbox.com/v2/bookings")!,timeoutInterval: Double.infinity)
        request.addValue("2023-03-15", forHTTPHeaderField: "Square-Version")
        request.addValue("Bearer EAAAEEcmYwB9IfDVQphfWOj8pGHyzLnZyYhed8MHrnlcpyBErRxXcJyAIcofZF6Y", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData

        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 400
        guard statusCode >= 200 && statusCode <= 202 else { throw RideError.bookingError }
        let res = try JSONDecoder().decode(CreatedBookingResponseData.self, from: data)
        guard res.booking.status == "ACCEPTED" else { throw RideError.bookingError }
    }
    
    func retrieveUser() async throws -> Customer {
        guard let userID = UserDefaults.standard.string(forKey: U.userId) else { throw SquareError.sessionExpired }
        var request = URLRequest(url: URL(string: "https://connect.squareupsandbox.com/v2/customers/\(userID)")!,timeoutInterval: Double.infinity)
        request.addValue("2023-03-15", forHTTPHeaderField: "Square-Version")
        request.addValue("Bearer EAAAEEcmYwB9IfDVQphfWOj8pGHyzLnZyYhed8MHrnlcpyBErRxXcJyAIcofZF6Y", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw SquareError.userNotFound }
        let user = try JSONDecoder().decode(SquareUser.self, from: data)
        return user.customer
    }
    
    func createUser(firstName: String, lastName: String, email: String, phone: String) async throws -> Customer {
        let parameters = "{\n    \"family_name\": \"\(lastName)\",\n    \"given_name\": \"\(firstName)\",\n    \"email_address\": \"\(email)\",\n    \"phone_number\": \"\(phone)\"\n  }"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: "https://connect.squareupsandbox.com/v2/customers")!,timeoutInterval: Double.infinity)
        request.addValue("2023-03-15", forHTTPHeaderField: "Square-Version")
        request.addValue("Bearer EAAAEEcmYwB9IfDVQphfWOj8pGHyzLnZyYhed8MHrnlcpyBErRxXcJyAIcofZF6Y", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData

        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw SquareError.userNotFound }
        let user = try JSONDecoder().decode(SquareUser.self, from: data)
        return user.customer
    }
    
}

struct U {
    static let userId = "square_user_id"
}
