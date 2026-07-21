//
//  Ride.swift
//  Comfort Rides Pro
//

import Foundation
import SwiftUI
import UIKit

struct Ride: Identifiable {
    var id: UUID = UUID()
    var reservationId: UUID? = nil
    var time: Date?
    var pickUpLocation: String?
    var dropOffLocation: String?
    var carType: CarType?
    var price: Int = 0
    var layover: Int = 1
    var hasLayover: Bool = false
    var note: String = ""

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        formatter.timeZone = TimeZone(abbreviation: "PST")
        formatter.doesRelativeDateFormatting = true
        return formatter.string(from: time!)
    }
}

enum CarType: String, Identifiable {
    var id: String { rawValue }
    case crsedan = "Private Sedan"
    case crluxury = "Private SUV"

    var supabaseId: String {
        switch self {
        case .crsedan: return "sedan"
        case .crluxury: return "suv"
        }
    }

    init(supabaseId: String) {
        self = (supabaseId == "suv") ? .crluxury : .crsedan
    }

    func title() -> String { rawValue }

    func seats() -> Int {
        switch self {
        case .crsedan: return 4
        case .crluxury: return 6
        }
    }

    func description1() -> [String] {
        switch self {
        case .crsedan:
            return [
                "Tesla Model Y or similar (EV)",
                "Holds 4 passengers • 4 luggage",
                "Free Cancellation up to 24 hrs before pickup time",
                "30 minutes of wait time included on every ride."
            ]
        case .crluxury:
            return [
                "Cadillac Escalade ESV or similar",
                "Holds 6 passengers • 6 luggage",
                "All drivers are fully trained and licensed",
//                "Free Cancellation up to 24 hrs before pickup time", - "x.circle"
                "30 minutes of wait time included on every ride."
            ]
        }
    }

    func images() -> [String] {
        switch self {
        case .crsedan: return ["car.fill", "person.fill", "x.circle", "clock.fill"]
        case .crluxury: return ["car.fill", "person.fill", "checkmark.square", "clock.fill"]
        }
    }

    func price(_ layover: Int) -> String {
        switch self {
        case .crsedan: return layover == 1 ? "$100 flat" : "$75/hr"
        case .crluxury: return layover == 1 ? "Contact for pricing" : "$150/hr"
        }
    }

    func primaryColor() -> Color { Color(uiColor: .systemGray4) }
    func secondaryColor() -> Color { K.darkBlue }

    func imageName() -> String {
        switch self {
        case .crsedan: return "car"
        case .crluxury: return "car.side"
        }
    }
}
