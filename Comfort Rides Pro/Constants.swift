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
    static let appId = "sq0idp-1cj1NCzJF5Rl6xU7aGL1QA"
    static let locationId = "L9DGVF8VYD6FW"
    
    struct payment {
        struct ApplePay {
            static let MERCHANT_IDENTIFIER: String = "REPLACE_ME"
            static let COUNTRY_CODE: String = "US"
            static let CURRENCY_CODE: String = "USD"
        }

        struct square {
            static let SQUARE_LOCATION_ID: String = "LZ81MMSRJDWMC"
            static let APPLICATION_ID: String  = "sandbox-sq0idb-7QC6HyosVyq8KTeQCquFLg"
            static let CHARGE_SERVER_HOST: String = "https://private-app-872d489208bd.herokuapp.com"
            static let CHARGE_URL: String = "\(CHARGE_SERVER_HOST)/chargeForCookie"
        }
    }
}


struct U {
    static let userId = "square_user_id"
    static let defaultCard = "default_card_id"
    
    static func setUserID(id: String) {
        UserDefaults.standard.setValue(id, forKey: U.userId)
    }
    
    static func getUserID() -> String? {
        return UserDefaults.standard.string(forKey: U.userId)
    }
    
    static func setDefaultCard(card: String) {
        UserDefaults.standard.setValue(card, forKey: defaultCard)
    }
    
    static func getDefaultCard(in cards: [Card]) -> Card? {
        if let id = UserDefaults.standard.string(forKey: defaultCard) {
            return cards.first(where: { $0.id == id })
        }
        return nil
    }
}

struct F {
    static func vibrate(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactMed = UIImpactFeedbackGenerator(style: style)
        impactMed.impactOccurred()
    }
}

struct V {
    static var cards: [Card] = []
    
    
}
