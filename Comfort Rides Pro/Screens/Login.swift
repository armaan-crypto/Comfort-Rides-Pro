//
//  LoginTest.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 3/26/23.
//

import SwiftUI
import AlertToast

struct Login: View {
    
    @State var firstname = ""
    @State var lastname = ""
    @State var phone = ""
    @State var email = ""
    @State var advance = false
    @State var loading = false
    @State var isError = false
    @State var error = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer()
                CRLogo()
                Text("Tell us a bit about yourself")
                    .foregroundColor(K.darkBlue)
                    .font(.system(size: 28, weight: .bold))
                VStack(spacing: 20) {
                    LoginTextField(placeholder: "Phone number", text: $phone, keyboardType: .phonePad)
                    LoginTextField(placeholder: "Email", text: $email, keyboardType: .emailAddress)
                    LoginTextField(placeholder: "First name", text: $firstname, contentType: .givenName)
                    LoginTextField(placeholder: "Last name", text: $lastname, contentType: .familyName)
                }
                .padding(.top, 5)
                .padding(.bottom, 20)
                LoginButton(loading: $loading, isError: $isError, error: $error, createUser: createUser)
                NavigationLink(destination: HomescreenFromLogin(), isActive: $advance) { EmptyView() }
                Spacer()
            }
        }
        .preferredColorScheme(.light)
        .padding()
        .toast(isPresenting: $loading) { AlertToast(type: .loading) }
        .toast(isPresenting: $isError) { AlertToast(type: .regular, title: "Error while creating user", subTitle: error) }
    }
    
    func createUser() async throws {
        if email == "" || lastname == "" || firstname == "" || phone == "" {
            self.error = "Fill out all the fields"
            self.isError = true
        }
        // Call the API
        let parameters = "{\n    \"email_address\": \"\(email)\",\n    \"family_name\": \"\(lastname)\",\n    \"given_name\": \"\(firstname)\",\n    \"phone_number\": \"\(phone)\"\n  }"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: "https://connect.\(K.keyword).com/v2/customers")!,timeoutInterval: Double.infinity)
        request.addValue("2023-03-15", forHTTPHeaderField: "Square-Version")
        request.addValue("Bearer \(K.key)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("__cf_bm=GjSThZ7LuFf8yXkbLOj9NmCEU1OUaV2884SjYRTwOEk-1680999689-0-Af0bdPPG6m3f7wCD4tc+ioNAIIylAjtUqwbDQ3vuO4uN41BnYGGUxKnOdD40YntAguhF9Q39ZB9I+7GNoi2xpm0=", forHTTPHeaderField: "Cookie")

        request.httpMethod = "POST"
        request.httpBody = postData
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let decodedJson = try? JSONDecoder().decode(SquareUser.self, from: data) else {
            let d = try JSONDecoder().decode(SquareErrorJSON.self, from: data)
            if d.errors.count > 0 {
                print(d)
                self.error = d.errors[0].showedText
                isError = true
            }
            return
        }
        
        // Store id
        UserDefaults.standard.set(decodedJson.customer.id, forKey: U.userId)
        advance = true
    }
}

struct HomescreenFromLogin: View {
    var body: some View {
        NavigationView {
            StartingScreen()
        }
        .accentColor(K.darkBlue)
        .navigationBarHidden(true)
    }
}

struct LoginTest_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}

fileprivate struct LoginTextField: View {
    
    @State var placeholder: String
    @Binding var text: String
    @State var contentType: UITextContentType? = nil
    @State var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(10)
            .textContentType(contentType)
            .keyboardType(keyboardType)
    }
}

fileprivate struct LoginButton: View {
    
    @Binding var loading: Bool
    @Binding var isError: Bool
    @Binding var error: String
    @State var createUser: (() async throws -> Void)
    
    var body: some View {
        Button {
            Task {
                do {
                    loading = true
                    try await createUser()
                    loading = false
                } catch {
                    print(error)
                    loading = false
                    isError = true
                    self.error = error.localizedDescription
                }
            }
        } label: {
            Text("Continue")
                .foregroundColor(.white)
                .bold()
                .frame(width: UIScreen.screenWidth - 60)
                .padding()
            
        }
        .background(K.darkBlue)
        .cornerRadius(10)
    }
}

struct CRLogo: View {
    @State var isSmall = false
    var body: some View {
        Image("logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: isSmall ? 150 : 200)
            .cornerRadius(20)
            .shadow(radius: 10)
    }
}

struct PhoneNumberTextField: View {
    @State private var phoneNumber: String = ""

    var body: some View {
        TextField("Enter Phone Number", text: $phoneNumber)
            .keyboardType(.phonePad)
    }
}
