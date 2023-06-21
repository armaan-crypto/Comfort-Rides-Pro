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
    static let sandboxKey = "EAAAEDNhYZgNTP3M7GcxEBMdf9PD6zNFBhbvvjnYri6TwvUZ1g3fQzJvWW2T7nKf"
    static let key = "EAAAFG3eWy7mwdUzcFAsYH7WeT1zSy_V7_KLyOEo4S2YcBwZCSCATdF9LOaeOvvS"
    static let keyword = "squareup"
    static let teamMemberId = "TMjd9YcIJgpKsgG0"
    static let sandboxMemberId = "TMnxCtcwd8BjSXZ7"
}

struct F {
    static func vibrate(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactMed = UIImpactFeedbackGenerator(style: style)
        impactMed.impactOccurred()
    }
}
