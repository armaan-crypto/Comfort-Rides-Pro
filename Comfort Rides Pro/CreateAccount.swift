//
//  CreateAccount.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 3/25/23.
//

import SwiftUI

struct CreateAccount: View {
    @State var firstname = ""
    @State var lastname = ""
    @State var phone = ""
    
    var body: some View {
        VStack {
            LoginScreen()
        }
        .padding()
    }
}

struct LoginScreen: View {
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        ZStack {
            Color.white
            
            VStack(spacing: 20) {
//                Image(systemName: "lock.shield.fill")
                Image("logo")
                    .resizable()
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding()
                    .shadow(radius: 10)
                Text("Welcome to Comfort Rides Pro")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Text("Let's get you moving")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Username")
                        .font(.headline)
                        .foregroundColor(.gray)
                    TextField("Enter your username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Password")
                        .font(.headline)
                        .foregroundColor(.gray)
                    SecureField("Enter your password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Button(action: {
                    // Handle login button action
                }, label: {
                    Text("Log in")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(K.darkBlue)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                })
                .padding(.top, 20)
            }
            .padding()
        }
        .ignoresSafeArea()
    }
}

struct CreateAccount_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccount()
    }
}
