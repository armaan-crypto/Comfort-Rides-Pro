//
//  BookRide.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 1/18/23.
//

import SwiftUI

struct BookRide: View {
    var body: some View {
        ScrollView {
            VStack {
                ChooseCarType()
            }
        }
    }
}

struct ChooseCarType: View {
    
    var carTypes: [CarType] = [.crsedan, .crluxury]
    
    var body: some View {
        HStack {
            Text("Choose Your Ride")
                .bold()
                .font(.system(size: 24))
            Spacer()
        }.padding()
        ScrollView(.horizontal) {
            HStack(spacing: 20) {
                Spacer()
                ForEach(carTypes) { carType in
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
                                .frame(height: 30)
                            HStack {
                                Spacer()
                                ZStack {
                                    VStack {
                                        Text("")
                                    }.background(.white)
                                    Image(systemName: "circle")
                                        .foregroundColor(.blue)
                                        .bold()
                                }
                                Spacer()
                                    .frame(width: 21)
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

struct BookRide_Previews: PreviewProvider {
    static var previews: some View {
        BookRide()
    }
}
