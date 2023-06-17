//
//  StartingScreen.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 2/18/23.
//

import SwiftUI

struct StartingScreen: View {
    
    @State var ride = Ride()
    @State var phoneNumber: String = ""
    @State private var date = Date.now
    @State var isActive = false
    @State var navigateTo: AnyView = AnyView(EmptyView())
    
    var body: some View {
        ScrollView {
            VStack {
                ZStack {
                    Image("vegas")
                        .resizable()
                        .scaledToFill()
                        .shadow(radius: 10)
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .cornerRadius(10)
                                .shadow(color: .white, radius: 20)
                            Spacer()
                        }
                        Spacer()
                    }
                }
                VStack {
                    Spacer()
                        .frame(height: 20)
                    Spacer()
                    VStack(spacing: 0) {
                        HStack {
                            Text("Choose your date and time")
                                .bold()
                                .foregroundColor(K.darkBlue)
                            Spacer()
                        }
                        let newDate = Calendar.current.date(byAdding: DateComponents(minute: 16), to: Date())
                        DatePicker("", selection: $date, in: (newDate ?? Date())...)
                            .datePickerStyle(.graphical)
                            .tint(K.darkBlue)
                        
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
                        print(Calendar.current.dateComponents([.hour, .minute], from: date).minute ?? 12345)
                        ride.time = date
                    })
                    .background(K.darkBlue)
                    .cornerRadius(10)
                    Spacer()
                        .frame(height: 20)
                }
                .padding(.trailing)
                .padding(.leading)
                .padding(.bottom)
            }
        }
        .background(.white)
        .toolbar {
             ToolbarItem(placement: .navigationBarLeading) {
                 Menu(content: {
                     Button {
                         self.navigateTo = AnyView(BookedRides())
                         isActive = true
                     } label: {
                         Text("Upcoming Rides")
                     }

                 }, label: {
                     Image(systemName: "gear")
                 })
              }
          }
        .background(NavigationLink(destination: self.navigateTo, isActive: $isActive) {
            EmptyView()
        })
        .preferredColorScheme(.light)
        .navigationTitle("Private")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            UIDatePicker.appearance().minuteInterval = 15
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
