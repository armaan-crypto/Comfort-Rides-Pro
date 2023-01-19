//
//  ContentView.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 1/16/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            HomeBackgroundView()
            VStack {
                Spacer()
                    .frame(height: 80)
                Image(uiImage: UIImage(named: "logo")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .cornerRadius(20)
                Spacer()
                Button {
                    print("hi")
                } label: {
                    Text("Sign Up or Sign In To Your Account")
                        .foregroundColor(.blue)
                        .padding()
                        .bold()
                }.background(.white)
                    .cornerRadius(20)
                Spacer()
                    .frame(height: 100)
            }
        }
        .padding()
    }
}

struct HomeBackgroundView: View {
    var body: some View {
        Image(uiImage: UIImage(named: "homescreen")!)
            .resizable()
            .scaledToFill()
            .frame(height: 880)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
