//
//  Ride.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 1/18/23.
//

import Foundation
import CoreLocation
import SwiftUI
import UIKit

struct Ride: Identifiable {
    var id: UUID { UUID() }
    var time: Date?
    var pickUpLocation: String?
    var dropOffLocation: String?
    var carType: CarType?
    var price: Int = 55
    var locationId: String?
    var layover: Int = 1
    var hasLayover: Bool = false
    var note: String = ""
    
    var formattedDate: String {
        let relativeDateFormatter = DateFormatter()
        relativeDateFormatter.timeStyle = .short
        relativeDateFormatter.dateStyle = .medium
        relativeDateFormatter.timeZone = TimeZone(abbreviation: "PST")
        relativeDateFormatter.doesRelativeDateFormatting = true
        return relativeDateFormatter.string(from: time!)
    }
}

enum CarType: String, Identifiable {
    var id: UUID { UUID() }
    case crsedan = "Private Sedan"
    case crluxury = "Private SUV"
    
    func title() -> String {
        switch self {
        case .crsedan:
            return "Private Sedan"
        case .crluxury:
            return "Private SUV"
        }
    }
    
    init(serviceId: String) {
        if serviceId == CarType.crluxury.serviceId() {
            self = .crluxury
        } else {
            self = .crsedan
        }
    }
    
    func image() -> Image {
        return Image(uiImage: UIImage(named: self.rawValue)!)
    }
    
    func seats() -> Int {
        switch self {
        case .crsedan:
            return 4
        case .crluxury:
            return 6
        }
    }
    
    func serviceId() -> String {
        switch self {
        case .crsedan:
//            return "GZ2FW5MAN3WMPT7NG2W376QD"
            return "SASQNSLOU5GC4HLQ5S7IKB6G"
        case .crluxury:
            return "ZZAXSYXCDH6NK62EMBMQOHKO"
        }
    }
    
    func description1() -> [String] {
        switch self {
        case .crsedan:
            return ["Tesla Model Y or similar (EV)", "Holds 4 passengers • 4 luggage", "Free Cancellation up to 24 hrs before pickup time", "30 minutes of wait time included on every ride."]
        case .crluxury:
            return ["Cadillac Escalade ESV or similar", "Holds 6 passengers • 6 luggage", "Drinks are provided and are all inclusive", "Free Cancellation up to 24 hrs before pickup time", "30 minutes of wait time included on every ride."]
        }
    }
    
    func images() -> [String] {
        switch self {
        case .crsedan:
            return ["car.fill", "person.fill", "x.circle", "clock.fill"]
        case .crluxury:
            return ["car.fill", "person.fill", "wineglass.fill", "x.circle", "clock.fill"]
        }
    }
    
    fileprivate func sellerReduction(_ layover: Int) -> Int {
        // r = price - (price * 0.029 + 30)
        let price = totalPrice(layover)
        let scale = Double(price) * 0.029
        return price - (Int(scale) + 30)
    }
    
    func fees(_ layover: Int) -> Int {
        return totalPrice(layover) - servicePrice(layover)
    }
    
    func feesText(_ layover: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: fees(layover) / 100 as NSNumber)!
    }
    
    func totalPrice(_ layover: Int) -> Int {
        let price = servicePrice(layover)
        let a = price + 30
        return Int(Double(a) / 0.971)
    }
    
    func totalPriceText(_ layover: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: totalPrice(layover) / 100 as NSNumber)!
    }
    
    func servicePrice(_ layover: Int) -> Int {
        switch self {
        case .crsedan:
            if layover == 1 {
                return 100 * 60
            } else {
                return 75 * layover * 100
            }
        case .crluxury:
            if layover == 1 {
                return 100 * 0
            } else {
                return 150 * layover * 100
            }
        }
    }
    
    func servicePriceText(_ layover: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: servicePrice(layover) / 100 as NSNumber)!
    }
    
    func price(_ layover: Int) -> String {
        switch self {
        case .crsedan:
            return "$\(60 * layover)"
        case .crluxury:
            return "$\(0 * layover)"
        }
    }
    
    func primaryColor() -> Color {
        return Color(uiColor: .systemGray4)
    }
    
    func secondaryColor() -> Color {
        return K.darkBlue
    }
    
    func imageName() -> String {
        switch self {
        case .crsedan:
            return "car"
        case .crluxury:
            return "car.side"
        }
    }
}
