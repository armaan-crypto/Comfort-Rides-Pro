//
//  PKPaymentAuthorizationView.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 5/21/23.
//

import Foundation
import SwiftUI
import SquareInAppPaymentsSDK

struct PKPaymentAuthorizationView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = PKPaymentAuthorizationViewController
    
    var paymentRequest: PKPaymentRequest
    var delegate: PKPaymentAuthorizationViewControllerDelegate
    
    func makeUIViewController(context: Context) -> PKPaymentAuthorizationViewController {
        let paymentAuth = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)!
        paymentAuth.delegate = delegate
        return paymentAuth
    }
    
    func updateUIViewController(_ uiViewController: PKPaymentAuthorizationViewController, context: Context) {
        //
    }
}
