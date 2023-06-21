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
    case crsedan = "Premium Sedan"
    case crluxury = "SUV Luxe"
    
    func title() -> String {
        switch self {
        case .crsedan:
            return "Premium Sedan"
        case .crluxury:
            return "SUV Luxe"
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
            return "GZ2FW5MAN3WMPT7NG2W376QD"
        case .crluxury:
            return "ZZAXSYXCDH6NK62EMBMQOHKO"
        }
    }
    
    func description1() -> [String] {
        switch self {
        case .crsedan:
            return ["Only available in Columbus, OH", "Tesla Model Y or similar (EV)", "Holds 4 passengers • 4 luggage", "Free Cancellation up to 24 hrs before pickup time", "30 minutes of wait time included on every ride."]
        case .crluxury:
            return ["Only available in Las Vegas", "Cadillac Escalade ESV or similar", "Holds 6 passengers • 6 luggage", "Drinks are provided and are all inclusive", "Free Cancellation up to 24 hrs before pickup time", "30 minutes of wait time included on every ride."]
        }
    }
    
    func images() -> [String] {
        switch self {
        case .crsedan:
            return ["building.fill", "car.fill", "person.fill", "bag.fill", "x.circle", "clock.fill"]
        case .crluxury:
            return ["building.fill", "car.fill", "person.fill", "bag.fill", "wineglass.fill", "x.circle", "clock.fill"]
        }
    }
    
    func price() -> String {
        switch self {
        case .crsedan:
            return "$60"
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