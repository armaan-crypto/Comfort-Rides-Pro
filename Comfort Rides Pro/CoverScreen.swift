//
//  CoverScreen.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 2/14/23.
//

import SwiftUI

struct CoverScreen: View {
    @State var ride = Ride()
    var body: some View {
        VStack {
            ZStack {
                Image(uiImage: UIImage(named: "top")!)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(20)
                Image(uiImage: UIImage(named: "logo")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140)
                    .cornerRadius(20)
            }
            Spacer()
            DestinationSelector(ride: $ride)
            Spacer()
            NavigationLink {
                Login()
            } label: {
                Text("Where to?")
                    .bold()
                    .foregroundColor(.white)
                    .frame(width: 330, height: 50)
                    .cornerRadius(10)
            }
            .background(.blue)
            .cornerRadius(10)
            Spacer()
                .frame(height: 20)
        }
        .padding()
        .background(.white)
    }
}

struct CoverScreen_Previews: PreviewProvider {
    static var previews: some View {
        CoverScreen()
    }
}
