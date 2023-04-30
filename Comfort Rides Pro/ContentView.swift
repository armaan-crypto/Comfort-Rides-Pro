//
//  ContentView.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 1/16/23.
//

import SwiftUI

struct ContentView: View {
    
    @State var loaded = false
    @State var isValidUser = false
    
    var body: some View {
        if loaded {
            NavigationView {
                if isValidUser {
                    StartingScreen()
                } else {
                    LoginTest()
                }
            }.accentColor(K.darkBlue)
                .preferredColorScheme(.light)
        } else {
            Launchscreen()
                .preferredColorScheme(.light)
                .onAppear(perform: viewDidLoad)
        }
    }
    
    func viewDidLoad() -> Void {
        Task {
            do {
                let _ = try await SquareManager().retrieveUser()
                isValidUser = true
                withAnimation {
                    loaded = true
                }
            } catch {
                print(error)
                withAnimation {
                    loaded = true
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
