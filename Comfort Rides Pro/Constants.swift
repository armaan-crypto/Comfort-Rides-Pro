//
//  Constants.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 2/18/23.
//

import Foundation
import SwiftUI

struct K {
    static let darkBlue = Color(uiColor: UIColor(named: "black")!)
    static let key = "EAAAEDNhYZgNTP3M7GcxEBMdf9PD6zNFBhbvvjnYri6TwvUZ1g3fQzJvWW2T7nKf"
}

struct F {
    static func vibrate(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactMed = UIImpactFeedbackGenerator(style: style)
        impactMed.impactOccurred()
    }
}
