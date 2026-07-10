//
//  Overview.swift
//  Comfort Rides Pro
//

import SwiftUI
import AlertToast

struct Overview: View {

    @Binding var ride: Ride
    @State private var isUploading = false
    @State private var posted = false
    @State private var isError = false
    @State private var error = ""
    @State private var enabled = true
    @State private var advance = false
    @State private var passengerName: String = ""

    var body: some View {
        ZStack {
            K.backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    Image(uiImage: UIImage(named: ride.carType!.rawValue)!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 290)
                        .shadow(color: .black.opacity(0.5), radius: 24, x: 0, y: 14)
                        .padding(.top, 8)

                    CarTypeOverviewSection(carType: ride.carType!)
                        .padding(18)
                        .luxCard()
                    TimeOverviewSection(ride: $ride)
                        .padding(18)
                        .luxCard()
                    RideDetailsOverviewSection(ride: ride)
                        .padding(18)
                        .luxCard()
                    if !passengerName.isEmpty {
                        PassengerOverviewSection(name: passengerName)
                            .padding(18)
                            .luxCard()
                    }
                    if ride.hasLayover {
                        HourlyServiceOverviewSection(ride: ride)
                            .padding(18)
                            .luxCard()
                    }

                    HStack(spacing: 10) {
                        Image(systemName: "banknote")
                            .font(.system(size: 14))
                            .foregroundColor(K.gold)
                        Text("Payment is collected in-vehicle at the end of your ride.")
                            .font(.system(size: 13))
                            .foregroundColor(K.textDim)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 4)

                    Button {
                        bookRide()
                    } label: {
                        CTALabel(title: "Reserve ride", enabled: enabled)
                    }
                    .disabled(!enabled)
                    .padding(.top, 8)
                }
                .padding(20)
            }
            Spacer()
                .toast(isPresenting: $posted) {
                    AlertToast(type: .complete(K.gold), title: "Booked")
                }
                .toast(isPresenting: $isUploading) {
                    AlertToast(type: .loading, title: "")
                }
                .toast(isPresenting: $isError) {
                    AlertToast(type: .regular, title: "Error while booking your ride", subTitle: error)
                }
        }
        .navigationDestination(isPresented: $advance) {
            StartingScreen().navigationBarBackButtonHidden()
        }
        .onAppear { setDefaultTime() }
        .task {
            if let profile = try? await BookingService().fetchProfile() {
                passengerName = profile.fullName
            }
        }
        .navigationTitle("Ride Overview")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func bookRide() {
        enabled = false
        isUploading = true
        Task {
            do {
                try await BookingService().createReservation(ride: ride)
                isUploading = false
                posted = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    posted = false
                    enabled = true
                    advance = true
                }
            } catch {
                isUploading = false
                self.error = error.localizedDescription
                isError = true
                enabled = true
            }
        }
    }

    private func setDefaultTime() {
        guard let time = ride.time else { return }
        let calendar = Calendar.current
        var components = calendar.dateComponents(
            [.calendar, .minute, .hour, .month, .year, .timeZone,
             .day, .era, .nanosecond, .quarter, .second,
             .weekOfMonth, .weekday, .weekdayOrdinal, .weekOfYear, .yearForWeekOfYear],
            from: time
        )
        let m = components.minute ?? 0
        let secondIsZero = (components.second ?? 0) == 0
        let minuteIsValid = (m == 0 || m == 30)
        if !(secondIsZero && minuteIsValid) {
            components.minute = m - (m % 30)
            ride.time = calendar.date(from: components)
        }
    }
}

// MARK: - Section views

struct CarTypeOverviewSection: View {
    let carType: CarType

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Overline(text: "Vehicle")
            Text(carType.title())
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
            VStack(alignment: .leading, spacing: 7) {
                ForEach(carType.description1(), id: \.self) { d in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(K.gold)
                            .padding(.top, 3)
                        Text(d)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.65))
                    }
                }
            }
            HStack(spacing: 8) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 13))
                    .foregroundColor(K.gold)
                Text("Seats 1-\(carType.seats()) People")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TimeOverviewSection: View {
    @Binding var ride: Ride

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Overline(text: "Appointment")
            HStack(spacing: 12) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 18))
                    .foregroundColor(K.gold)
                Text("Your \(ride.carType!.title()) will arrive \(ride.formattedDate) PST")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct RideDetailsOverviewSection: View {
    let ride: Ride

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Overline(text: "Ride Details")
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .strokeBorder(K.gold, lineWidth: 1.5)
                    .frame(width: 10, height: 10)
                    .padding(.top, 4)
                VStack(alignment: .leading, spacing: 2) {
                    Text("FROM")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(1.5)
                        .foregroundColor(.white.opacity(0.4))
                    Text(ride.pickUpLocation ?? "")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(K.gold)
                    .frame(width: 10, height: 10)
                    .padding(.top, 4)
                VStack(alignment: .leading, spacing: 2) {
                    Text("TO")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(1.5)
                        .foregroundColor(.white.opacity(0.4))
                    Text(ride.dropOffLocation ?? "")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PassengerOverviewSection: View {
    let name: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Overline(text: "Passenger")
            HStack(spacing: 12) {
                Image(systemName: "person.fill")
                    .font(.system(size: 15))
                    .foregroundColor(K.gold)
                Text(name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct HourlyServiceOverviewSection: View {
    let ride: Ride

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Overline(text: "Hourly Service")
            HStack(spacing: 12) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 15))
                    .foregroundColor(K.gold)
                Text(ride.note)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct Overview_Previews: PreviewProvider {
    @State static var r = Ride(time: Date(), pickUpLocation: "Home", dropOffLocation: "School", carType: .crluxury)
    static var previews: some View {
        NavigationStack {
            Overview(ride: $r)
        }
    }
}
