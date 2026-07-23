//
//  DestinationSelector.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 2/14/23.
//

import SwiftUI
import MapItemPicker
import AlertToast
import MapKit

struct DestinationSelector: View {

    @State var showing1 = false
    @State var showing = false
    @Binding var ride: Ride
    @State var whereToAddress = ""
    @State var whereToText = ""
    @State var pickupAddress = ""
    @State var pickupText = ""
    @State var firstSelected = false
    @State var secondSelected = false
    @State var advance = false
    @State var pickUpPlacemark: MKPlacemark? = nil
    @State var dropOffPlacemark: MKPlacemark? = nil
    @State var isUploading = false
    @State var isError = false
    @State var error = ""
    @State var layover = 1
    @State var isHourlyService = false
    @State private var carTypeRates: [String: Int] = [:]   // supabaseId → hourly_rate_cents

    var suvRateLabel: String {
        if let cents = carTypeRates["suv"] { return "$\(cents / 100)" }
        return "$85"
    }

    var body: some View {
        ZStack {
            K.backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    VStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 4) {
                            Overline(text: "Where to?")
                            SerifHeading(text: "Enter Locations", size: 24)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        LocationSelector(ride: $ride, placeholder: "Pickup Location", address: $pickupAddress, text: $pickupAddress, isShowing: $showing1, placemark: $pickUpPlacemark)
                        DestinationField(ride: $ride, address: $whereToAddress, text: $whereToText, isShowing: $showing, isHourlyService: $isHourlyService, placemark: $dropOffPlacemark)
                    }
                    
                    Rectangle()
                        .fill(K.hairline)
                        .frame(height: 1)

                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Overline(text: "Your vehicle")
                            SerifHeading(text: "Select Ride", size: 24)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
//                    CarSelectorItem(carType: .crsedan, isSelected: $firstSelected)
//                        .onTapGesture {
//                            firstSelected = true
//                            secondSelected = false
//                            ride.carType = .crsedan
//                            F.vibrate(.heavy)
//                        }
                        CarSelectorItem(carType: .crluxury, isSelected: $secondSelected, rateLabel: suvRateLabel, hidePrice: isHourlyService)
                            .onTapGesture {
                                firstSelected = false
                                secondSelected = true
                                ride.carType = .crluxury
                                F.vibrate(.heavy)
                            }
                    }

                    if isHourlyService {
                        Rectangle()
                            .fill(K.hairline)
                            .frame(height: 1)

                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Overline(text: "Driver standby")
                                SerifHeading(text: "Hourly Service", size: 24)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            HourlyServiceView(selected: $layover, carType: ride.carType, hourlyRateCents: carTypeRates[ride.carType?.supabaseId ?? ""])
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    Button {
                        ride.layover = layover
                        ride.hasLayover = false
                        ride.note = ""
                        if layover > 1 {
                            ride.hasLayover = true
                            ride.note = "Layover time of \(layover) hours. "
                        }
                        advance = true
                    } label: {
                        CTALabel(title: "Next", enabled: !isDisabled())
                    }
                    .disabled(isDisabled())
                    NavigationLink(destination: Overview(ride: $ride), isActive: $advance) { EmptyView() }
                }
                .padding(20)
            }
        }
        .onChange(of: isHourlyService, perform: { hourly in
            if !hourly { layover = 1 }
        })
        .task {
            if let rows = try? await BookingService().fetchCarTypes() {
                carTypeRates = Dictionary(uniqueKeysWithValues: rows.map { ($0.id, $0.hourlyRateCents) })
            }
        }
        .onAppear(perform: {
            whereToAddress = ride.dropOffLocation ?? ""
            pickupAddress = ride.pickUpLocation ?? ""
            if ride.dropOffLocation == "Hourly Service" {
                isHourlyService = true
                layover = ride.layover
            }
            guard let carType = ride.carType else {
                return
            }
            switch carType {
            case .crsedan:
                firstSelected = true
            case .crluxury:
                secondSelected = true
            }
        })
        .toast(isPresenting: $isUploading) {
            AlertToast(type: .loading, title: "")
        }
        .toast(isPresenting: $isError) { AlertToast(type: .regular, title: "Error while finding your location", subTitle: error) }
    }

    func isDisabled() -> Bool {
        let noCarSelected = !(firstSelected || secondSelected)
        let textFieldsAreEmpty = (whereToAddress.isEmpty || pickupAddress.isEmpty)
        return (noCarSelected || textFieldsAreEmpty)
    }
    func buttonColor() -> Color {
        return isDisabled() ? Color.white.opacity(0.08) : K.gold
    }
}

struct HourlyServiceView: View {

    @Binding var selected: Int
    @State var text = "Select Layover Length"
    var carType: CarType? = nil
    var hourlyRateCents: Int? = nil

    private func hourlyLabel(_ hours: Int) -> String {
        let total = 150 * hours
        return "\(hours) hours - $\(total)"
    }

    private var hourlyRateDisplay: String {
//        if let cents = hourlyRateCents { return "$\(cents / 100)/hr" }
        return "$150/hr"
    }

    var body: some View {
        VStack(spacing: 16) {
            LeftText(text: "If you would like your driver to stay on standby, select the length of your booking. Your driver will stay on standby for you during your desired booking hours. Charged by the hour.")
                .font(.system(size: 13))
                .foregroundColor(K.textDim)
            HStack {
                Overline(text: "\(hourlyRateDisplay) • 2 hour booking minimum")
                Spacer()
            }
            Menu {
                Button("Select Layover Length") {
                    text = "Select Layover Length"
                    selected = 1
                }
                ForEach(2...24, id: \.self) { i in
                    Button {
                        text = hourlyLabel(i)
                        selected = i
                    } label: {
                        Text(hourlyLabel(i))
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "clock")
                        .foregroundColor(K.gold)
                    Text(text)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.45))
                }
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(K.surface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(K.hairline, lineWidth: 1)
                )
            }
        }
        .onAppear {
            if selected > 1 {
                text = hourlyLabel(selected)
            }
        }
    }
}

struct CarSelectorItem: View {

    @State var carType: CarType
    @Binding var isSelected: Bool
    var rateLabel: String? = nil
    var hidePrice: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(carType.title())
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? K.gold : .white.opacity(0.25))
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<carType.description1().count, id: \.self) { i in
                    let s = carType.description1()[i]
                    let img = carType.images()[i]
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: img)
                            .font(.system(size: 12))
                            .foregroundColor(K.gold)
                            .frame(width: 18)
                        Text(s)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

            HStack {
                if !hidePrice {
                    Text(rateLabel ?? carType.price(1))
                        .font(.system(size: 13, weight: .semibold))
                        .tracking(0.5)
                        .foregroundColor(K.gold)
                }
                Spacer()
                Image(uiImage: UIImage(named: carType.rawValue)!)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 72)
                    .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 6)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(K.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(isSelected ? K.gold : K.hairline, lineWidth: isSelected ? 1.5 : 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

struct LeftText: View {

    @State var text: String
    @State var size: CGFloat = 16
    @State var weight: Font.Weight? = nil

    var body: some View {
        HStack {
            Text(text)
                .font(.system(size: size, weight: weight))
            Spacer()
        }
    }
}

struct LocationSelector: View {

    @Binding var ride: Ride
    @State var placeholder: String
    @Binding var address: String
    @Binding var text: String
    @Binding var isShowing: Bool
    @Binding var placemark: MKPlacemark?

    var body: some View {
        HStack(spacing: 10) {
            BetterTextField(placeholder: placeholder, enteredText: $address, width: 250) {
                isShowing = true
            }

            Button {
                isShowing = true
            } label: {
                Image(systemName: "map")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(K.gold)
                    .frame(width: 54, height: 54)
            }
            .onChange(of: address, perform: { newValue in
                if placeholder == "Destination" {
                    ride.dropOffLocation = address
                } else {
                    ride.pickUpLocation = address
                }
            })
            .mapItemPicker(isPresented: $isShowing, onDismiss: { item in
                guard let item = item else {
//                    address = "Please enter another address"
//                    text = "Please enter another address"
                    return
                }
                text = item.name!
                let placemark = item.placemark
                address = "\(placemark.subThoroughfare ?? "") \(placemark.thoroughfare ?? ""), \(placemark.locality ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.postalCode ?? ""), \(placemark.countryCode ?? "")"
                self.placemark = placemark
                if placeholder == "Destination" {
                    ride.dropOffLocation = address
                } else {
                    ride.pickUpLocation = address
                }
            })
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(K.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(K.hairline, lineWidth: 1)
            )
        }
    }
}

struct DestinationField: View {

    @Binding var ride: Ride
    @Binding var address: String
    @Binding var text: String
    @Binding var isShowing: Bool
    @Binding var isHourlyService: Bool
    @Binding var placemark: MKPlacemark?

    private var displayText: String {
        if isHourlyService { return "Hourly Service" }
        return address.isEmpty ? "Destination" : address
    }

    var body: some View {
        HStack(spacing: 10) {
            Menu {
                Button {
                    withAnimation { isHourlyService = false }
                    isShowing = true
                } label: {
                    Label("Choose a location", systemImage: "mappin.and.ellipse")
                }
                Button {
                    withAnimation {
                        isHourlyService = true
                        address = "Hourly Service"
                        text = "Hourly Service"
                        ride.dropOffLocation = "Hourly Service"
                    }
                } label: {
                    Label("Book Hourly Service", systemImage: "clock")
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: isHourlyService ? "clock" : "magnifyingglass")
                        .foregroundColor(K.gold)
                    Text(displayText)
                        .foregroundColor(displayText == "Destination" ? .white.opacity(0.35) : .white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(K.surface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(K.hairline, lineWidth: 1)
                )
            }

            Button {
                withAnimation { isHourlyService = false }
                isShowing = true
            } label: {
                Image(systemName: "map")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(K.gold)
                    .frame(width: 54, height: 54)
            }
            .mapItemPicker(isPresented: $isShowing, onDismiss: { item in
                guard let item = item else { return }
                text = item.name!
                let placemark = item.placemark
                address = "\(placemark.subThoroughfare ?? "") \(placemark.thoroughfare ?? ""), \(placemark.locality ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.postalCode ?? ""), \(placemark.countryCode ?? "")"
                self.placemark = placemark
                withAnimation { isHourlyService = false }
                ride.dropOffLocation = address
            })
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(K.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(K.hairline, lineWidth: 1)
            )
        }
    }
}

struct BetterTextField: View {

    @State var placeholder: String
    @Binding var enteredText: String
    @State var width: CGFloat
    @State var onClick: (() -> Void)

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(K.gold)
                Text(enteredText.isEmpty ? placeholder : enteredText)
                    .foregroundColor(enteredText.isEmpty ? .white.opacity(0.35) : .white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(K.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(K.hairline, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct DestinationSelector_Previews: PreviewProvider {
    @State static var r = Ride()
    static var previews: some View {
        NavigationView {
            DestinationSelector(ride: $r)
        }
    }
}

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}
