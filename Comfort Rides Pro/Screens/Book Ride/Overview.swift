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
    @State var card: Card? = nil
    
    @State var done = false
    @State var total = 0
    @State var showConfirmation = false
    @State var detent: PresentationDetent = .fraction(7/10)
    
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
                    VStack {
                        CarTypeOverviewSection(carType: ride.carType!)
                        Divider()
                        PaymentOverviewSection(ride: ride, carType: ride.carType!, card: $card)
                        Divider()
                        TimeOverviewSection(ride: $ride)
                        Divider()
                        RideDetailsOverviewSection(ride: ride)
                        Divider()
                        if ride.hasLayover {
                            HourlyServiceOverviewSection(ride: ride)
                            Divider()
                        }
                    }
                    .padding()
                    Button {
                        showConfirmation = true
                    } label: {
                        Text("Reserve ride")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 320)
                            .bold()
                    }
//                    .disabled((!enabled || (card == nil)))
                    .background((!enabled || (card == nil)) ? Color(uiColor: .systemGray4) : K.darkBlue)
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
        .onChange(of: done, perform: { newValue in
            if done == true {
                bookRide(amount: total)
            }
            done = false
            total = 0
        })
        .onAppear(perform: {
            print(ride)
            print(V.cards)
            if let c = U.getDefaultCard(in: V.cards) {
                card = c
            }
            setDefaultTime()
        })
        .sheet(isPresented: $showConfirmation) {
            PaymentConfirmationView(total: $total, isPresented: $showConfirmation, isDone: $done, totalAmount: Double(ride.carType!.totalPrice(ride.layover)) / 100)
                .presentationDetents([.fraction(7/10)],
                                     selection: $detent)
        }
        .navigationTitle("Ride Overview")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(uiColor: .systemGray6))
    }
    
    func bookRide(amount: Int) {
        enabled = false
        startLoad()
        Task {
            do {
                try await SquareManager().book(ride: ride)
//                let _ = try await SquarePayment().pay(with: card!.id, amount: amount)
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
        print(ride.formattedDate)
        let h = components.hour!
        let m = components.minute!
        let secondIsZero = (components.second! == 0)
        let minuteIsValid = (m == 0  || m == 30)
        let isNotValidTime = !(secondIsZero && minuteIsValid)
        if isNotValidTime {
            let minuteRemainder = components.minute! % 30
            components.minute! -= minuteRemainder
            ride.time = calendar.date(from: components)
        }
    }
    
//    func showLoadFor(seconds: Double, after: (() -> Void)?) {
//        startLoad()
//        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
//            stopLoad()
//            guard let after = after else { return }
//            after()
//        }
//    }
    
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
                Text("Your " + ride.carType!.title() + " will arrive " + ride.formattedDate + " PST")
                Spacer()
            }
        }
        .padding(4)
    }
}

struct PaymentOverviewSection: View {
    
    @State var ride: Ride
    @State var carType: CarType
    @State var selected: Card? = nil
    @Binding var card: Card?
    
    var body: some View {
        VStack(spacing: 30) {
            LeftText(text: "Payment")
                .font(.system(size: 20))
                ZStack {
                    NavigationLink {
                        ListCards(id: U.getUserID()!, selected: $card, shouldPop: true)
                    } label: {
                        if let card = card {
                            CardRow(card: card, selected: $selected, showNext: true, loadCards: {})
                                .padding()
                        } else {
                            HStack {
                                Text("You currently have no cards added")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .imageScale(.large)
                                    .foregroundStyle(K.darkBlue)
                                    .bold()
                            }
                                .padding()
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(20)
            HStack {
                Text("Est.")
                Spacer()
                    .frame(width: 20)
                Text("$\((Double(carType.totalPrice(ride.layover)) / 100), specifier: "%.2f")")
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

struct HourlyServiceOverviewSection: View {
    @State var ride: Ride
    
    var body: some View {
        VStack(spacing: 30) {
            LeftText(text: "Hourly Service")
                .font(.system(size: 20))
            LeftText(text: ride.note)
        }
        .padding(4)
    }
}

struct Overview_Previews: PreviewProvider {
    @State static var r = Ride(time: Date(), pickUpLocation: "Home", dropOffLocation: "School", carType: .crluxury, price: 80)
    @State static var ca: Card? = nil
    @State static var c = Card(id: "ccof:CBASEN_JRXMyZjLGuZtb8gJMyd8", cardBrand: "VISA", last4: "1111", expMonth: 2, expYear: 2025, billingAddress: BillingAddress(postalCode: "22222"))
    static var previews: some View {
        NavigationView {
            Overview(ride: $r, card: c)
        }
    }
}
