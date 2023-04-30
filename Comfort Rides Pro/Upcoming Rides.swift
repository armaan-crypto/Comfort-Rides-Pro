//
//  Upcoming Rides.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 1/19/23.
//

import SwiftUI

struct UpcomingRides: View {
    
    @State var rides: [Ride]
    
    var body: some View {
//        NavigationView {
            VStack {
                if rides.count == 0 {
                    Text("Click the plus button above to add")
                } else {
                    List(rides) { ride in
                        VStack(spacing: 10) {
                            HStack {
                                Text(ride.carType?.rawValue ?? "")
                                    .bold()
                                Spacer()
                            }
                            HStack {
                                Text(ride.formattedDate ?? "")
                                Spacer()
                            }
                            HStack {
                                Text("Pickup Location: " + (ride.pickUpLocation ?? "Not Found"))
                                Spacer()
                            }
                            HStack {
                                Text("Dropoff Location: " + (ride.dropOffLocation ?? "Not Found"))
                                Spacer()
                            }
                            HStack {
                                Spacer()
                                Text("$\(ride.price)")
                                    .bold()
                            }
                        }
                    }
                }
            }.toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: PickUpLocation()) {
                        Text("Add")
                    }
                }
            }
            .navigationTitle("Upcoming Rides")
//        }
    }
}

struct Upcoming_Rides_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingRides(rides: [Ride(time: .distantFuture, pickUpLocation: "123 Main Street", dropOffLocation: "567 Free Lane", carType: .crsedan, price: 45), Ride(time: .distantFuture, pickUpLocation: "567 Free Lane", dropOffLocation: "123 Main Street", carType: .crluxury, price: 55)])
    }
}
