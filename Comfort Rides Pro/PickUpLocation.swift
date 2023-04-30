//
//  PickUpLocation.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 1/19/23.
//

import SwiftUI
import MapItemPicker

struct PickUpLocation: View {
    
    @State var ride: Ride = Ride(time: nil, pickUpLocation: nil, dropOffLocation: nil)
    @State var showing = false
    @State var text = ""
    @State var address: String = ""
    
    var body: some View {
        VStack {
            List {
                TextField("Place: Enter Your Location First", text: $text)
                TextField("Address: Enter Your Location First", text: $address)
            }
                .scrollDisabled(true)
                .disabled(true)
                .frame(height: 130)
            HStack {
                Spacer()
                Button {
                    showing = true
                } label: {
                    Text("Choose Location")
                        .padding()
                        .foregroundColor(.white)
                        .bold()
                }
                .mapItemPicker(isPresented: $showing, onDismiss: { item in
                    guard let item = item else {
                        address = "Please enter another address"
                        text = "Please enter another address"
                        return
                    }
                    text = item.name!
                    let placemark = item.placemark
                    address = "\(placemark.subThoroughfare ?? "") \(placemark.thoroughfare ?? ""), \(placemark.locality ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.postalCode ?? ""), \(placemark.country ?? "")"
                    ride.pickUpLocation = address
                })
                    .background(.blue)
                    .cornerRadius(10)

            }
                .padding()
            Spacer()
            NavigationLink {
                DropOffLocation(ride: $ride)
            } label: {
                Text("Next")
                    .foregroundColor(.white)
                    .padding()
                    .fontWeight(.heavy)
                    .frame(width: UIScreen.main.bounds.width - 50)
            }
            .disabled(isntEntered())
            .opacity(isntEntered() ? 0.5 : 1)
            .background(Color.blue.opacity(isntEntered() ? 0.5 : 1))
            .frame(width: UIScreen.main.bounds.width - 50)
            .cornerRadius(10)
        }
        .padding()
            .background(Color(uiColor: .systemGray6))
            .navigationTitle("Enter Your Pickup Location")
            .navigationBarTitleDisplayMode(.automatic)
            
    }
    func isntEntered() -> Bool {
        return ((address == "") || (address == "Please enter another address"))
    }
}

struct PickUpLocation_Previews: PreviewProvider {
    static var previews: some View {
        PickUpLocation(ride: Ride(time: .now, pickUpLocation: nil, dropOffLocation: nil))
    }
}
