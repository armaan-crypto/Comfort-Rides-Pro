//
//  BookedRides.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 6/11/23.
//

import SwiftUI

struct BookedRides: View {
    
    @ObservedObject var ridesManager = RidesManager()
    
    var body: some View {
        if ridesManager.loaded {
            if ridesManager.bookedRides.count > 0 {
                List(ridesManager.bookedRides) { ride in
                    BookedRidesRow(ride: ride)
                        .navigationTitle("Upcoming Rides")
                }
            } else {
                Text("No rides have been booked yet")
                    .foregroundColor(Color(uiColor: UIColor.systemGray6))
                    .bold()
                    .navigationTitle("Upcoming Rides")
            }
        } else {
            ProgressView()
                .navigationTitle("Upcoming Rides")
                .onAppear {
                    Task {
                        do {
                            try await ridesManager.retrieve({ str in
                                print("ERROR: " + str)
                            })
                        } catch {
                            print(error)
                        }
                    }
                }
        }
    }
}

struct BookedRidesRow: View {
    @State var ride: Ride
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(ride.carType!.rawValue)
                    .bold()
                Spacer()
            }
            HStack {
                Text("From: " + ride.pickUpLocation!)
                Spacer()
            }
            HStack {
                Text("To: " + ride.dropOffLocation!)
                Spacer()
            }
            HStack {
                VStack {
                    Spacer()
                    Text(ride.formattedDate)
                }
                Spacer()
                VStack {
                    Image(ride.carType!.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                        .padding(.leading)
                }
            }
        }
        .padding(5)
    }
}

struct BookedRides_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BookedRides()
        }
    }
}

class RidesManager: ObservableObject {
    @Published var bookedRides = [Ride]()
    @Published var loaded = false
    init() {
        bookedRides = []
    }
    
    func retrieve(_ hadError: ((String) -> Void)) async throws {
        var request = URLRequest(url: URL(string: "https://connect.squareupsandbox.com/v2/bookings")!,timeoutInterval: Double.infinity)
        request.addValue("2023-06-08", forHTTPHeaderField: "Square-Version")
        request.addValue("Bearer EAAAEDNhYZgNTP3M7GcxEBMdf9PD6zNFBhbvvjnYri6TwvUZ1g3fQzJvWW2T7nKf", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as! HTTPURLResponse).statusCode >= 200 else { hadError("Error retrieving rides"); return }
        let rideResponse = try JSONDecoder().decode(RideResponse.self, from: data)
        DispatchQueue.main.async {
            self.loaded = true
        }
        for r in rideResponse.bookings {
            if r.customerID == UserDefaults.standard.string(forKey: U.userId) ?? "" {
                DispatchQueue.main.async {
                    withAnimation {
                        self.bookedRides.append(self.getRide(from: r))
                    }
                }
            }
        }
    }
    
    func getRide(from booking: BookingResponseData) -> Ride {
        let pickUp = String(String(booking.customerNote.split(separator: "Pickup location: ")[1]).split(separator: ". Drop off location")[0])
        let dropOff = String(booking.customerNote.split(separator: "Drop off location: ")[1])
        let carType = CarType(serviceId: booking.appointmentSegments[0].serviceVariationID)
        // TODO: If booking.start is nil show error
        return Ride(time: booking.start!, pickUpLocation: pickUp, dropOffLocation: dropOff, carType: carType, price: Int(String(carType.price().split(separator: "$")[0])) ?? 0, locationId: nil)
    }
}
