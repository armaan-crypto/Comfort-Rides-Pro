//
//  Login.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 1/22/23.
//

import SwiftUI

struct Login: View {
    var body: some View {
        NavigationView {
            ZStack {
//                HomeBackgroundView()
                VStack {
                    TopBackgroundView()
                    Spacer()
                    NavigationLink {
                        UpcomingRides(rides: [Ride(time: .now, pickUpLocation: "18109 Main Lane", dropOffLocation: "The Waldorf Astoria, Orlando, FL", carType: .crsedan, price: 60)])
                            .navigationBarBackButtonHidden()
                    } label: {
                        Text("Where to?")
                            .padding()
                            .foregroundColor(.blue)
                            .bold()
                            .frame(width: 350)
                    }.background(.white)
                        .cornerRadius(20)
                        .frame(width: 275)
//                    Button {
//                        print("hi")
//                    } label: {
//                        Text("Sign Up or Sign In To Your Account")
//                            .foregroundColor(.blue)
//                            .padding()
//                            .bold()
//                    }.background(.white)
//                        .cornerRadius(20)
                    Spacer()
                        .frame(height: 100)
                }
            }
        }
    }
}

struct HomeBackgroundView: View {
    var body: some View {
        Image(uiImage: UIImage(named: "homescreen")!)
            .resizable()
            .scaledToFill()
            .frame(height: 960)
    }
}

struct TopBackgroundView: View {
    var body: some View {
        Image(uiImage: UIImage(named: "top")!)
            .resizable()
            .scaledToFill()
            .frame(width: 100)
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}
