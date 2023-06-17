//
//  SquareAPI.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 5/27/23.
//

import Foundation
import SquareInAppPaymentsSDK

class SquareAPI {
    static let shared = SquareAPI()

    private let squareClient: SCCAPIRequest = {
        let client = SCCAPIRequest()
        client.applicationID = "YOUR_SQUARE_APPLICATION_ID"
        // Additional configuration for the client
        return client
    }()

    func startSquareInAppPayment() {
        let amountMoney = SCCMoney(amount: 100, currencyCode: "USD") // Replace with the appropriate amount
        let request = SCCAPIRequest(
            callbackURL: URL(string: "YOUR_CALLBACK_URL")!,
            amountMoney: amountMoney,
            userInfoString: "CUSTOM_USER_INFO_STRING"
        )
        SCCAPIConnection.perform(request)
    }
}

// Conform to the SCCAPIConnectionDelegate protocol
extension SquareAPI: SCCAPIConnectionDelegate {
    func connection(_ connection: SCCAPIConnection, didFailWithError error: Error) {
        // Handle the error
    }

    func connection(_ connection: SCCAPIConnection, didCompleteWith response: SCCAPIResponse) {
        // Handle the response
    }
}
