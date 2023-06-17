//
//  Launchscreen.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 4/14/23.
//

import SwiftUI

struct Launchscreen: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                CRLogo()
                Spacer()
            }
            Spacer()
        }
        .background(K.darkBlue)
    }
}

struct Launchscreen_Previews: PreviewProvider {
    static var previews: some View {
        Launchscreen()
    }
}
