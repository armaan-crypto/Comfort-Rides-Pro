//
//  StartingScreen.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 2/18/23.
//

import SwiftUI
import UIKit

struct StartingScreen: View {
    
    @State var ride = Ride()
    @State var phoneNumber: String = ""
    @State private var date = Date()
    @State var isActive = false
    @State var navigateTo: AnyView = AnyView(EmptyView())
    @State var selected: Card? = nil
    
    var body: some View {
        ScrollView {
            VStack {
                VegasImage()
                VStack {
                    Spacer()
                        .frame(height: 20)
                    Spacer()
                    VStack(spacing: 0) {
                        HStack {
                            Text("Choose your pickup date and time")
                                .bold()
                                .foregroundColor(K.darkBlue)
                            Spacer()
                        }
                        DatePicker("", selection: $date, in: Date().addingTimeInterval(5400)..., displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.graphical)
                            .tint(K.darkBlue)
                            .labelsHidden()
                        
                    }
                    Spacer()
                    NavigationLink {
                        DestinationSelector(ride: $ride)
                    } label: {
                        Text("Schedule Ride")
                            .bold()
                            .foregroundColor(.white)
                            .frame(width: 330, height: 50)
                            .cornerRadius(10)
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        ride.time = date
                    })
                    .background(K.darkBlue)
                    .cornerRadius(10)
                    Spacer()
                        .frame(height: 20)

                }
                
                .padding([.trailing, .leading, .bottom])
            }
        }
        .background(.white)
        .toolbar(content: bar)
        .background(NavigationLink(destination: self.navigateTo, isActive: $isActive) {
            EmptyView()
        })
        .preferredColorScheme(.light)
        .navigationTitle("Private")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            UIDatePicker.appearance().minuteInterval = 30
        }
    }
    
    @ToolbarContentBuilder
    func bar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Menu(content: {
                Button {
                    self.navigateTo = AnyView(BookedRides())
                    isActive = true
                } label: {
                    Text("Upcoming Rides")
                }
                
                Button {
                    self.navigateTo = AnyView(ListCards(id: U.getUserID()!, selected: $selected))
                    isActive = true
                } label: {
                    Text("Payment")
                }
                
                Button(action: {
                    EmailController.shared.sendEmail(subject: "Account Deletion Request", body: "Deletion request for User ID: \(UserDefaults.standard.string(forKey: U.userId) ?? "NOT FOUND")", to: "info@privateappusa.com")
                 }) {
                     Text("Request Account Deletion")
                 }
            }, label: {
                Image(systemName: "gear")
            })
         }
    }
}

struct WhereToButton: View {
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(K.darkBlue)
                Text("Where to?")
                    .foregroundColor(Color(uiColor: .systemGray4))
                Spacer()
            }
            .frame(width: 300)
            .padding()
        }
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(10)
    }
}

struct StartingScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StartingScreen()
        }
    }
}

struct VegasImage: View {
    var body: some View {
        ZStack {
            Image("vegas")
                .resizable()
                .scaledToFill()
                .shadow(radius: 10)
        }
    }
}
