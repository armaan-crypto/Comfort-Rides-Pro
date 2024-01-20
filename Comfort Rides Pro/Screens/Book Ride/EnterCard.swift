//
//  EnterCard.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 11/22/23.
//

import SwiftUI
import SquareInAppPaymentsSDK

//struct CardInfo: UIViewControllerRepresentable {
//    func makeUIViewController(context: Context) -> SQIPCardEntryViewController {
//        // Customize the card payment form
//        let theme = SQIPTheme()
//        theme.errorColor = .red
//        theme.tintColor = C.primaryAction
//        theme.keyboardAppearance = .light
//        theme.messageColor = C.descriptionFont
//        theme.saveButtonTitle = "Pay"
//
//        return SQIPCardEntryViewController(theme: theme)
//    }
//    
//    func updateUIViewController(_ uiViewController: SQIPCardEntryViewController, context: Context) {
//        <#code#>
//    }
//    
//    typealias UIViewControllerType = SQIPCardEntryViewController
//}



struct EnterCard: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    EnterCard()
}

struct C {
    static let background = UIColor(red: 0.47, green: 0.8, blue: 0.77, alpha: 1.0)
    static let popupBackground = UIColor.white
    static let primaryAction = UIColor(red: 0.14, green: 0.6, blue: 0.55, alpha: 1)
    static let applePayBackground = UIColor.black
    static let hairlineColor = UIColor.black.withAlphaComponent(0.1)
    static let descriptionFont = UIColor(red: 0.48, green: 0.48, blue: 0.48, alpha: 1)
    static let navigationBarTintColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
    static let heading = UIColor(red: 0.14, green: 0.6, blue: 0.55, alpha: 1)
}
