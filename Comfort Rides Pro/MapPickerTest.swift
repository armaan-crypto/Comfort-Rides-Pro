//
//  MapPickerTest.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 1/22/23.
//

import SwiftUI
import MapItemPicker

struct MapPickerTest: View {
    @State private var showingPicker = false
    @State var selected = ""
    var body: some View {
        VStack {
            Text(selected)
            Button("Choose location") {
                showingPicker = true
            }
            .mapItemPicker(isPresented: $showingPicker) { item in
                if let item = item {
                    selected = item.placemark.title ?? ""
                }
            }
        }
    }
}

struct MapPickerTest_Previews: PreviewProvider {
    static var previews: some View {
        MapPickerTest()
    }
}
