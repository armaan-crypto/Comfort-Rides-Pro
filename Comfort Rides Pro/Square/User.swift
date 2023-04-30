//
//  User.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 3/26/23.
//

import Foundation

// MARK: - User
struct SquareUser: Codable {
    let customer: Customer
}

// MARK: - Customer
struct Customer: Codable {
    let id: String
    let givenName, familyName, phoneNumber: String
    let preferences: Preferences
    let creationSource: String
    let version: Int

    enum CodingKeys: String, CodingKey {
        case id
        case givenName = "given_name"
        case familyName = "family_name"
        case phoneNumber = "phone_number"
        case preferences
        case creationSource = "creation_source"
        case version
    }
}

// MARK: - Preferences
struct Preferences: Codable {
    let emailUnsubscribed: Bool

    enum CodingKeys: String, CodingKey {
        case emailUnsubscribed = "email_unsubscribed"
    }
}
