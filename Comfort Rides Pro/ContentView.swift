//
//  ContentView.swift
//  Comfort Rides Pro
//

import SwiftUI

struct ContentView: View {

    @State private var loaded = false
    @State private var isValidUser = false

    var body: some View {
        Group {
            if !loaded {
                Launchscreen()
                    .preferredColorScheme(.dark)
            } else if isValidUser {
                NavigationStack {
                    StartingScreen()
                }
                .tint(K.gold)
                .preferredColorScheme(.dark)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
            } else {
                NavigationStack {
                    Login()
                }
                .tint(K.gold)
                .preferredColorScheme(.dark)
                .transition(.asymmetric(
                    insertion: .move(edge: .leading),
                    removal: .move(edge: .trailing)
                ))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: isValidUser)
        .task { await observeAuthState() }
    }

    private func observeAuthState() async {
        for await (event, session) in await supabase.auth.authStateChanges {
            switch event {
            case .initialSession:
                isValidUser = session != nil
                withAnimation { loaded = true }
            case .signedIn:
                withAnimation { isValidUser = true }
                if !loaded { withAnimation { loaded = true } }
            case .signedOut:
                withAnimation { isValidUser = false }
            default:
                break
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
