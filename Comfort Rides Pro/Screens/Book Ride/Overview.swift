//
//  Overview.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 2/22/23.
//

import SwiftUI
import AlertToast

struct Overview: View {
    
    @Binding var ride: Ride
    @State var isUploading = false
    @State var posted = false
    @State var isError = false
    @State var error = ""
    @State var enabled = true
    @State var advance = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    HStack {
                        Spacer()
                        Image(uiImage: UIImage(named: ride.carType!.rawValue)!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300)
                    }
                    //                List {
                    VStack {
                        CarTypeOverviewSection(carType: ride.carType!)
                        Divider()
                        PaymentOverviewSection(carType: ride.carType!)
                        Divider()
                        TimeOverviewSection(ride: $ride)
                        Divider()
                        RideDetailsOverviewSection(ride: ride)
                        Divider()
                    }
                    .padding()
                    Button {
                        bookRide()
                    } label: {
                        Text("Book")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 320)
                            .bold()
                    }
                    .disabled(!enabled)
                    .background(K.darkBlue)
                    .cornerRadius(10)
                    .frame(width: 320)
                }
            }
            Spacer()
                .toast(isPresenting: $posted) {
                    AlertToast(type: .complete(K.darkBlue), title: "Booked")
                }
                .toast(isPresenting: $isUploading) {
                    AlertToast(type: .loading, title: "")
                }
                .toast(isPresenting: $isError) { AlertToast(type: .regular, title: "Error while booking your ride", subTitle: error) }
            NavigationLink(destination: StartingScreen().navigationBarBackButtonHidden(), isActive: $advance) { EmptyView() }
        }
        .onAppear(perform: {
            setDefaultTime()
        })
        .navigationTitle("Ride Overview")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(uiColor: .systemGray6))
    }
    
    func bookRide() {
        enabled = false
        startLoad()
        Task {
            do {
                try await SquareManager().book(ride: ride)
                stopLoad()
                showCheck()
            } catch {
                stopLoad()
                self.error = error.localizedDescription
                isError = true
                enabled = true
            }
        }
    }
    
    func setDefaultTime() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.calendar, .minute, .hour, .month, .year, .timeZone, .day, .era, .nanosecond, .quarter, .second, .weekOfMonth, .weekday, .weekdayOrdinal, .weekOfYear, .yearForWeekOfYear], from: ride.time!)
        let m = components.minute!
        let secondIsZero = (components.second! == 0)
        let minuteIsValid = (m == 0 || m == 15 || m == 30 || m == 45)
        let isNotValidTime = !(secondIsZero && minuteIsValid)
        if isNotValidTime {
            let timeShouldBePushed = (components.minute! >= 45)
            let mi = (timeShouldBePushed ? 15 : 0)
//            print(mi)
            components.hour! += 1
            components.minute! = mi
            ride.time = calendar.date(from: components)
        }
    }
    
    func showLoadFor(seconds: Double, after: (() -> Void)?) {
        startLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            stopLoad()
            guard let after = after else { return }
            after()
        }
    }
    
    func startLoad() {
        isUploading = true
    }
    
    func stopLoad() {
        isUploading = false
    }
    
    func showCheck() {
        posted = true
        let seconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            posted = false
            enabled = true
            advance = true
        }
    }
}

struct CarTypeOverviewSection: View {
    
    @State var carType: CarType
    
    var body: some View {
        VStack(spacing: 30) {
            VStack {
                LeftText(text: carType.title())
                    .bold()
                    .font(.system(size: 24))
                let t = carType.description1().joined(separator: ". ")
                ForEach(carType.description1(), id: \.self) { d in
                    LeftText(text: "• " + d)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            VStack {
                HStack {
                    Image(systemName: "person")
                        .bold()
                    LeftText(text: "Seats 1-" + "\(carType.seats()) People")
                }
            }
        }
    }
}

struct TimeOverviewSection: View {
    
    @Binding var ride: Ride
    
    var body: some View {
        VStack(spacing: 30) {
            LeftText(text: "Appointment")
                .font(.system(size: 20))
            HStack {
                Text("Your " + ride.carType!.title() + " will arrive " + ride.formattedDate.lowercased())
                Spacer()
            }
        }
        .padding(4)
    }
}

struct PaymentOverviewSection: View {
    @State var carType: CarType
    
    var body: some View {
        VStack(spacing: 30) {
            LeftText(text: "Payment")
                .font(.system(size: 20))
            HStack {
                Text("Est.")
                Spacer()
                    .frame(width: 20)
                Text(carType.price())
                    .font(.system(size: 40))
                Spacer()
            }
        }
        .padding(4)
    }
}

struct RideDetailsOverviewSection: View {
    
    @State var ride: Ride
    
    var body: some View {
        VStack(spacing: 30) {
            LeftText(text: "Ride Details")
                .font(.system(size: 20))
            HStack {
                Image(systemName: "car.circle")
                    .bold()
                    .font(.system(size: 30))
                LeftText(text: "From: " + ride.pickUpLocation!)
            }
            HStack {
                Image(systemName: "car.circle.fill")
                    .bold()
                    .font(.system(size: 30))
                LeftText(text: "To: " + ride.dropOffLocation!)
            }
        }
    }
}

struct Overview_Previews: PreviewProvider {
    @State static var r = Ride(time: Date(), pickUpLocation: "Home", dropOffLocation: "School", carType: .crluxury, price: 80)
    static var previews: some View {
        NavigationView {
            Overview(ride: $r)
        }
    }
}
