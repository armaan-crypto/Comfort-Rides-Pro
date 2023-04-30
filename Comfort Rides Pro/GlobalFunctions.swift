//
//  GlobalFunctions.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 1/19/23.
//

import Foundation
import SwiftUI

struct F {
    static func vibrate(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactMed = UIImpactFeedbackGenerator(style: style)
        impactMed.impactOccurred()
    }
}
