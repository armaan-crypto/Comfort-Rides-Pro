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

    var body: some View {
        ZStack {
            K.backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    VStack(spacing: 14) {
                        LocationSelector(ride: $ride, placeholder: "Pickup Location", address: $pickupAddress, text: $pickupAddress, isShowing: $showing1, placemark: $pickUpPlacemark)
                        LocationSelector(ride: $ride, placeholder: "Destination", address: $whereToAddress, text: $whereToText, isShowing: $showing, placemark: $dropOffPlacemark)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Overline(text: "Your vehicle")
                            SerifHeading(text: "Select Ride")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
//                    CarSelectorItem(carType: .crsedan, isSelected: $firstSelected)
//                        .onTapGesture {
//                            firstSelected = true
//                            secondSelected = false
//                            ride.carType = .crsedan
//                            F.vibrate(.heavy)
//                        }
                        CarSelectorItem(carType: .crluxury, isSelected: $secondSelected)
                            .onTapGesture {
                                firstSelected = false
                                secondSelected = true
                                ride.carType = .crluxury
                                F.vibrate(.heavy)
                            }
                    }

                    Rectangle()
                        .fill(K.hairline)
                        .frame(height: 1)

                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Overline(text: "Driver standby")
                            SerifHeading(text: "Hourly Service")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        HourlyServiceView(selected: $layover)
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
        .onAppear(perform: {
            whereToAddress = ride.dropOffLocation ?? ""
            pickupAddress = ride.pickUpLocation ?? ""
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
        .navigationTitle("Enter Locations")
        .navigationBarTitleDisplayMode(.large)
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
    @State var text = "None"

    var body: some View {
        VStack(spacing: 16) {
            LeftText(text: "If you would like your driver to stay on standby, select the length of your booking. Your driver will stay on standby for you during your booked hours. Charged by the hour.\n\n$150/hour - Private SUV.")
                .font(.system(size: 13))
                .foregroundColor(K.textDim)
            Menu {
                Button("None") {
                    text = "None"
                    selected = 1
                }
                ForEach(2...24, id: \.self) { i in
                    Button {
                        text = "\(i) hours"
                        selected = i
                    } label: {
                        Text(String(i) + " hours")
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
    }
}

struct CarSelectorItem: View {

    @State var carType: CarType
    @Binding var isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(carType.title())
                        .font(.system(size: 21, weight: .semibold, design: .serif))
                        .foregroundColor(.white)
                    Text(carType.price(1))
                        .font(.system(size: 13, weight: .semibold))
                        .tracking(0.5)
                        .foregroundColor(K.gold)
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

struct BetterTextField: View {

    @State var placeholder: String
    @Binding var enteredText: String
    @State var width: CGFloat
    @State var onClick: (() -> Void)

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(K.gold)
            TextField("", text: $enteredText, prompt: Text(placeholder).foregroundColor(.white.opacity(0.35)))
                .foregroundColor(.white)
                .tint(K.gold)
                .onTapGesture(perform: onClick)
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
