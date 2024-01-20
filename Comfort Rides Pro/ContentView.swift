//
//  ContentView.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 1/16/23.
//

import SwiftUI
import SquareInAppPaymentsSDK

struct ContentView: View {
    
    @State var loaded = false
    @State var isValidUser = false
    @State var shouldShowScreen = false
    
    var body: some View {
        if shouldShowScreen {
            NavigationView {
//                OtpFormFieldView()
//                ReceiptView()
            }
        } else {
            if loaded {
                NavigationView {
                    if isValidUser {
                        StartingScreen()
                    } else {
                        Login()
                    }
                }.accentColor(K.darkBlue)
                    .preferredColorScheme(.light)
            } else {
                Launchscreen()
                    .preferredColorScheme(.light)
                    .onAppear(perform: viewDidLoad)
            }
        }
    }
    
    func sqInit() {
        SQIPInAppPaymentsSDK.squareApplicationID = K.payment.square.APPLICATION_ID
    }
    
    func viewDidLoad() -> Void {
        sqInit()
        Task {
            do {
                let customer = try await SquareManager().retrieveUser()
                V.cards = customer.cards ?? []
                isValidUser = true
                withAnimation {
                    loaded = true
                }
            } catch {
                withAnimation {
                    loaded = true
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
