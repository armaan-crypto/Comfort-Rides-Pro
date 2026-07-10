//
//  StartingScreen.swift
//  Comfort Rides Pro
//

import SwiftUI
import UIKit

struct StartingScreen: View {

    @State private var ride = Ride()
    @State private var date = Date()
    @State private var isActive = false
    @State private var navigateTo: AnyView = AnyView(EmptyView())
    @State private var profile: ProfileRow? = nil

    var body: some View {
        ZStack {
            K.backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    VegasImage()

                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 6) {
                            Overline(text: "Private")
                            SerifHeading(text: "Where to next?", size: 30)
                        }
                        .padding(.leading)

                        VStack(alignment: .leading, spacing: 4) {
                            Overline(text: "Pickup date & time")
                                .padding([.top, .horizontal], 16)
                            // Minimum lead time: 90 minutes (5400 seconds), matches server-side trigger
                            DatePicker("", selection: $date, in: Date().addingTimeInterval(5400)..., displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.graphical)
                                .tint(K.gold)
                                .labelsHidden()
                                .padding([.bottom, .horizontal], 8)
                        }
                        .luxCard()
                        .padding(.horizontal)

                        NavigationLink {
                            DestinationSelector(ride: $ride)
                        } label: {
                            CTALabel(title: "Schedule Ride")
                        }
                        .simultaneousGesture(TapGesture().onEnded { ride.time = date })
                        .padding(.horizontal)

                        Spacer().frame(height: 8)
                    }
                    .padding(20)
                    .padding(.top, -44)
                }
            }
        }
        .toolbar(content: bar)
        .background(
            NavigationLink(destination: navigateTo, isActive: $isActive) { EmptyView() }
        )
        .navigationTitle("Private")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { UIDatePicker.appearance().minuteInterval = 30 }
        .task {
            do {
                let fetched = try await BookingService().fetchProfile()
                if fetched.email == nil {
                    try? await supabase.auth.signOut()
                } else {
                    profile = fetched
                }
            } catch {
                try? await supabase.auth.signOut()
            }
        }
    }

    @ToolbarContentBuilder
    func bar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Menu {
                if let name = profile?.fullName, !name.isEmpty {
                    Section(name) {
                        Button {
                            navigateTo = AnyView(BookedRides())
                            isActive = true
                        } label: {
                            Label("Upcoming Rides", systemImage: "car.fill")
                        }
                        Button(role: .destructive) {
                            Task { try? await supabase.auth.signOut() }
                        } label: {
                            Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    }
                } else {
                    Button {
                        navigateTo = AnyView(BookedRides())
                        isActive = true
                    } label: {
                        Label("Upcoming Rides", systemImage: "car.fill")
                    }
                    Button(role: .destructive) {
                        Task { try? await supabase.auth.signOut() }
                    } label: {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            } label: {
                Image(systemName: "gear")
                    .foregroundColor(.white.opacity(0.85))
            }
        }
    }
}

struct WhereToButton: View {
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(K.gold)
                Text("Where to?").foregroundColor(.white.opacity(0.35))
                Spacer()
            }
            .frame(width: 300)
            .padding()
        }
        .background(K.surface)
        .cornerRadius(14)
    }
}

struct StartingScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { StartingScreen() }
    }
}

struct VegasImage: View {
    var body: some View {
        Image("vegas")
            .resizable()
            .scaledToFill()
            .frame(height: 250)
            .frame(maxWidth: .infinity)
            .clipped()
            .overlay(
                LinearGradient(
                    colors: [.clear, K.darkBlue.opacity(0.45), K.darkBlue],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
}
