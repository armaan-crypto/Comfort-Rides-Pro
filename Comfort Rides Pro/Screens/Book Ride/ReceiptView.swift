//
//  ReceiptView.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 12/17/23.
//

import SwiftUI

struct ReceiptView: View {
    
    @State var done = false
    @State var total = 0
    @State var showSettings = false
    @State var settingsDetent: PresentationDetent = .fraction(7/10)
    var body: some View {
        VStack {
            HStack {
                Text("Total")
                    .bold()
                Spacer()
                Text("$1.00")
                Spacer()
                Spacer()
            }
            .padding()
            Divider()
                .padding()
            Button(action: { showSettings = true }, label: {
                Text("Pay With Card")
                    .foregroundStyle(Color.white)
                    .bold()
                    .padding()
            })
            .background(K.darkBlue)
            .cornerRadius(30)
            Spacer()
        }
        .onChange(of: done, perform: { newValue in
            if done == true {
                print(total)
            }
            done = false
            total = 0
        })
        .padding()
        .sheet(isPresented: $showSettings) {
            PaymentConfirmationView(total: $total, isPresented: $showSettings, isDone: $done, totalAmount: 40.00)
                .presentationDetents([.fraction(7/10)],
                                     selection: $settingsDetent)
            }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Reserve Your Ride")
    }
}

#Preview {
    NavigationView {
        ReceiptView()
    }
}
