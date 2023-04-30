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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                LocationSelector(ride: $ride, placeholder: "Pickup Location", address: $pickupAddress, text: $pickupAddress, isShowing: $showing1, placemark: $pickUpPlacemark)
                LocationSelector(ride: $ride, placeholder: "Destination", address: $whereToAddress, text: $whereToText, isShowing: $showing, placemark: $dropOffPlacemark)
                VStack(spacing: 20) {
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
                Button {
//                    Overview(ride: $ride)
                    createLocation()
                } label: {
                    Text("Next")
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: 330, height: 50)
                        .cornerRadius(10)
                }
                .background(buttonColor())
                .cornerRadius(10)
                .disabled(isDisabled())
                NavigationLink(destination: Overview(ride: $ride), isActive: $advance) { EmptyView() }
            }
            .padding()
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
        .preferredColorScheme(.light)
        .navigationTitle("Enter Locations")
        .navigationBarTitleDisplayMode(.large)
        .toast(isPresenting: $isUploading) {
            AlertToast(type: .loading, title: "")
        }
        .toast(isPresenting: $isError) { AlertToast(type: .regular, title: "Error while finding your location", subTitle: error) }
    }
    
    func createLocation() {
//        Task {
//            do {
//                isUploading = true
//                guard let pickUpPlacemark = pickUpPlacemark else { isUploading = false; return }
//                let id = try await SquareManager().createLocation(with: pickUpPlacemark, string: pickupAddress)
//                ride.locationId = id
//                isUploading = false
//                advance = true
//            } catch {
//                isUploading = false
//                self.error = error.localizedDescription
//                isError = true
//            }
//        }
        advance = true
    }
    
    func isDisabled() -> Bool {
        let noCarSelected = !(firstSelected || secondSelected)
        let textFieldsAreEmpty = (whereToAddress.isEmpty || pickupAddress.isEmpty)
        return (noCarSelected || textFieldsAreEmpty)
    }
    func buttonColor() -> Color {
        return isDisabled() ? Color(uiColor: .systemGray4) : K.darkBlue
    }
}

struct CarSelectorItem: View {
    
    @State var carType: CarType
    @Binding var isSelected: Bool
    
    var body: some View {
        ZStack {
            VStack {
                LeftText(text: carType.title(), weight: .heavy)
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
                VStack(spacing: 5) {
                    ForEach(carType.description1(), id: \.self) { s in
                        LeftText(text: "- " + s)
                    }
                    LeftText(text: "- Seats 1-" + "\(carType.seats())")
                        .bold()
                }
                .padding(EdgeInsets(top: 1, leading: 20, bottom: 20, trailing: 20))
                Spacer()
                LeftText(text: carType.price())
                .padding()
            }
            HStack {
                Spacer()
                VStack {
                    Spacer()
//                    Image(systemName: carType.imageName())
//                        .padding()
//                        .imageScale(.large)
                    Image(uiImage: UIImage(named: carType.rawValue)!)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                        .padding()
                }
            }
            HStack {
                Spacer()
                VStack {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .padding()
                        .imageScale(.large)
                    Spacer()
                }
            }
        }
//        .background(carType.primaryColor())
        .background(.black)
        .foregroundColor(.white)
        .cornerRadius(10)
//        .frame(height: 150)
        .bold()
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
            BetterTextField(placeholder: placeholder, enteredText: $address, width: 250)
            Button {
                isShowing = true
            } label: {
                Image(systemName: "map")
                    .padding()
                    .foregroundColor(.white)
                    .bold()
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
            .background(K.darkBlue)
                .cornerRadius(10)
        }
    }
}

struct BetterTextField: View {
    
    @State var placeholder: String
    @Binding var enteredText: String
    @State var width: CGFloat
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(K.darkBlue)
                TextField(text: $enteredText) {
                    Text(placeholder)
                        .foregroundColor(Color(uiColor: .systemGray4))
                }
                Spacer()
            }
//            .frame(width: width)
            .padding()
        }
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(10)
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
