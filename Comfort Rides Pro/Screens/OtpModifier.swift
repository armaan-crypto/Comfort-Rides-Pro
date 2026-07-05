//
//  OtpModifier.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 12/27/23.
//

import SwiftUI
import Combine

struct OtpModifer: ViewModifier {

    @Binding var pin : String

    var textLimt = 1

    func limitText(_ upper : Int) {
        if pin.count > upper {
            self.pin = String(pin.prefix(upper))
        }
    }


    //MARK -> BODY
    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .font(.system(size: 20, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .tint(K.gold)
            .onReceive(Just(pin)) {_ in limitText(textLimt)}
            .frame(width: 36, height: 52)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(K.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(pin.isEmpty ? K.hairline : K.gold, lineWidth: 1.5)
            )
    }
}
