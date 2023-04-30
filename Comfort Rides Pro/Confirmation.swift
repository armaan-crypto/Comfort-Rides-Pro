//
//  Confirmation.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 1/19/23.
//

import SwiftUI

struct Confirmation: View {
    @Binding var ride: Ride
    var body: some View {
        VStack {
            HStack {
                Text("Confirmation")
                    .bold()
                    .font(.system(size: 24))
                Spacer()
            }
            VStack {
                List {
                    Text("Pick Up: " + ride.pickUpLocation!)
                    Text("Drop Off: " + ride.dropOffLocation!)
                    Text("Car: " + ride.carType!.rawValue)
                    Text("Mileage: " + "19.6 miles")
                    Text("Price: $" + "\(ride.price)")
                }
                .cornerRadius(20)
                .scrollDisabled(true)
            }
            .cornerRadius(20)
            Spacer()
            Button {
                // TODO: Done
            } label: {
                Text("Book")
                    .foregroundColor(.white)
                    .fontWeight(.heavy)
                    .padding()
                    .frame(width: UIScreen.main.bounds.width - 50)
                    .cornerRadius(10)
            }
            .background(.blue)
            .cornerRadius(10)
        }.padding()
            .background(Color(uiColor: .systemGray6))
    }
}

struct Confirmation_Previews: PreviewProvider {
    @State static var ride = Ride(time: .now, pickUpLocation: "Pick Up", dropOffLocation: "Drop Off", carType: .crluxury)
    static var previews: some View {
        Confirmation(ride: $ride)
    }
}
