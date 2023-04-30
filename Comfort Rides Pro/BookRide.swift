//
//  BookRide.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 1/18/23.
//

import SwiftUI

struct BookRide: View {
    @Binding var ride: Ride
    var body: some View {
//        ScrollView {
            VStack {
                ChooseCarType(ride: $ride)
                Spacer()
                BookRideButton(ride: $ride)
            }
            .navigationTitle("Choose Your Ride")
//        }
    }
}

struct BookRideButton: View {
    
    @Binding var ride: Ride
    
    var body: some View {
        NavigationLink {
            Confirmation(ride: $ride)
        } label: {
            Text("Next")
                .foregroundColor(.white)
                .padding()
                .fontWeight(.heavy)
                .frame(width: UIScreen.main.bounds.width - 50)
        }
        .background(.blue)
        .frame(width: UIScreen.main.bounds.width - 50)
        .cornerRadius(10)
    }
}

struct ChooseCarType: View {
    
    @Binding var ride: Ride
    var carTypes: [CarType] = [.crsedan, .crluxury]
    
    var body: some View {
//        HStack {
//            Text("Choose Your Ride")
//                .bold()
//                .font(.system(size: 24))
//            Spacer()
//        }.padding()
        ScrollableCarTypePicker(carTypes: carTypes, ride: $ride)
    }
}

struct ScrollableCarTypePicker: View {
    
    @State var carTypes: [CarType]
    @Binding var ride: Ride
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 30) {
                Spacer()
                ForEach(carTypes) { carType in
                    CarTypeView(carType: carType, ride: $ride)
                }
            }
        }
    }
}

struct CarTypeView: View {
    
    @State var carType: CarType
    @Binding var ride: Ride
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                ZStack {
                    carType.image()
                        .resizable()
                        .scaledToFit()
                        .scaledToFill()
                        .cornerRadius(20)
                        .shadow(radius: 8)
                        .frame(width: 330, height: 220)
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                                .frame(width: 20)
                            Text(carType.rawValue)
                                .bold()
                                .foregroundColor(.white)
                                .padding()
                            Spacer()
                        }
                    }
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ZStack {
                                VStack {
                                    Text("")
                                }.background(.white)
                                Image(systemName: (ride.carType == carType) ? "checkmark.circle.fill" : "circle")
                                    .bold()
                                    .foregroundColor(.white)
                            }
                            Spacer()
                                .frame(width: 40)
                        }
                        Spacer()
                            .frame(height: 15)
                    }
                }
                Spacer()
            }
        }.onTapGesture {
            ride.carType = carType
            F.vibrate(.medium)
        }
    }
}

struct CarTypeView1: View {
    
    @State var carType: CarType
    @Binding var ride: Ride
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                    .frame(height: 15)
                carType.image()
                    .resizable()
                    .scaledToFit()
                    .scaledToFill()
                    .cornerRadius(20)
                    .shadow(radius: 8)
                    .frame(width: 300, height: 200)
                Spacer()
                    .frame(height: 15)
            }
            VStack {
                Spacer()
                HStack {
                    Text(carType.rawValue)
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                }
                Spacer()
                    .frame(height: 10)
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ZStack {
                        VStack {
                            Text("")
                        }.background(.white)
                        Image(systemName: (ride.carType == carType) ? "checkmark.circle.fill" : "circle")
                            .bold()
                            .foregroundColor(.white)
                    }
                    Spacer()
                        .frame(width: 21)
                }
                Spacer()
                    .frame(height: 30)
            }
        }.onTapGesture {
            ride.carType = carType
            F.vibrate(.medium)
        }
        
        
    }
}

struct BookRide_Previews: PreviewProvider {
    @State static var ride = Ride()
    static var previews: some View {
        BookRide(ride: $ride)
    }
}
