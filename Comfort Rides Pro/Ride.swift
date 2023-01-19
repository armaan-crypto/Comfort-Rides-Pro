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
    let time: Date
    let pickUpLocation: CLLocation?
    let dropOffLocation: CLLocation?
    let carType: CarType
}

enum CarType: String, Identifiable {
    var id: UUID { UUID() }
    case crsedan = "CRSedan"
    case crluxury = "CRLuxury"
    
    func image() -> Image {
        return Image(uiImage: UIImage(named: self.rawValue)!)
    }
}
