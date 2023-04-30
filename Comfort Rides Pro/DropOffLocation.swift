//
//  DropOffLocation.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 1/19/23.
//

import SwiftUI
import MapItemPicker

struct DropOffLocation: View {
    @Binding var ride: Ride
    @State var showing = false
    @State var text = ""
    @State var address = ""
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
                    ride.dropOffLocation = address
                })
                    .background(.blue)
                    .cornerRadius(10)

            }
                .padding()
            Spacer()
            NavigationLink {
                BookRide(ride: $ride)
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
            .navigationTitle("Enter Your Drop Off Location")
    }
    
    func isntEntered() -> Bool {
        return ((address == "") || (address == "Please enter another address"))
    }
}

struct DropOffLocation_Previews: PreviewProvider {
    static var previews: some View {
        DropOffLocation(ride: BookRide_Previews.$ride)
    }
}
