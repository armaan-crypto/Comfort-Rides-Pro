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
    
    var formattedDate: String {
        let relativeDateFormatter = DateFormatter()
        relativeDateFormatter.timeStyle = .short
        relativeDateFormatter.dateStyle = .medium
        relativeDateFormatter.doesRelativeDateFormatting = true
        return relativeDateFormatter.string(from: time!)
    }
}

enum CarType: String, Identifiable {
    var id: UUID { UUID() }
    case crsedan = "CRSedan"
    case crluxury = "CRLuxury"
    
    func title() -> String {
        switch self {
        case .crsedan:
            return "CRSedan"
        case .crluxury:
            return "Luxe SUV"
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
            return 7
        }
    }
    
    func serviceId() -> String {
        switch self {
        case .crsedan:
            return "AVF2ZG45W5MGJMPROZ3QKHFI"
        case .crluxury:
            return "K227EI5PZI4JLTCXISPOGFVD"
        }
    }
    
    func description1() -> [String] {
        switch self {
        case .crsedan:
            return ["Premium Sedan. Tesla Model Y or similar (EV)"]
        case .crluxury:
            return ["Luxury SUV. Cadillac Escalade ESV or similar", "Drinks are provided and are all inclusive", "30 minutes of wait time included on every ride."]
        }
    }
    
    func price() -> String {
        switch self {
        case .crsedan:
            return "$50"
        case .crluxury:
            return "$85"
        }
    }
    
    func primaryColor() -> Color {
//        switch self {
//        case .crsedan:
//            return Color(uiColor: .systemGray4)
//        case .crluxury:
//            return K.darkBlue
//        }
        return Color(uiColor: .systemGray4)
    }
    
    func secondaryColor() -> Color {
//        switch self {
//        case .crsedan:
//            return K.darkBlue
//        case .crluxury:
//            return .white
//        }
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
