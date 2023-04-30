//
//  Test.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 4/9/23.
//

import SwiftUI
import AlertToast

struct Test: View {
    @State private var connected = false
    @State var loading = false
    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    connectApi()
                }) {
                    Text("Connect")
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                .padding()
                .navigationDestination(isPresented: $connected) {
                    Text("Hello")
                }
                NavigationLink(
                    destination: EmptyView(),
                    isActive: $connected
                ) {
                    EmptyView()
                }
            }
            .navigationTitle("Connect to API")
            .toast(isPresenting: $loading) {
                AlertToast(type: .loading)
            }
        }
    }
    
    func connectApi() {
        loading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.loading = false
            self.connected = true
        }
        // Perform network function here
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
