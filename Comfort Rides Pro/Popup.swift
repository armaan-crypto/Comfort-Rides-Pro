//
//  Popup.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 1/26/23.
//

import SwiftUI

struct Popup: View {
    @State private var checkmarkOpacity: Double = 0
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.green)
                    .opacity(checkmarkOpacity)
                Path { path in
                    path.move(to: CGPoint(x: 10, y: 10))
                    path.addLine(to: CGPoint(x: 20, y: 20))
                    path.addLine(to: CGPoint(x: 35, y: 5))
                }
                .stroke(Color.white, lineWidth: 5)
                .opacity(checkmarkOpacity)
            }
            .frame(width: 50, height: 50)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.checkmarkOpacity = 1
                }
            }
        }
}

struct Popup_Previews: PreviewProvider {
    static var previews: some View {
        Popup()
    }
}
