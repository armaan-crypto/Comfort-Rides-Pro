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
    let givenName, familyName, emailAddress: String
    let phoneNumber: String?
    let cards: [Card]?

    enum CodingKeys: String, CodingKey {
        case id
        case givenName = "given_name"
        case familyName = "family_name"
        case phoneNumber = "phone_number"
        case emailAddress = "email_address"
        case cards
    }
}

// MARK: - Card
struct Card: Codable, Identifiable, Hashable {
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id, cardBrand, last4: String
    let expMonth, expYear: Int
    let billingAddress: BillingAddress

    enum CodingKeys: String, CodingKey {
        case id
        case cardBrand = "card_brand"
        case last4 = "last_4"
        case expMonth = "exp_month"
        case expYear = "exp_year"
        case billingAddress = "billing_address"
    }
}

// MARK: - BillingAddress
struct BillingAddress: Codable, Hashable {
    let postalCode: String

    enum CodingKeys: String, CodingKey {
        case postalCode = "postal_code"
    }
}
