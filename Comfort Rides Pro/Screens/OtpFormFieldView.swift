//
//  OtpFormFieldView.swift
//  Comfort Rides Pro
//

import SwiftUI
import Combine
import Supabase

struct OtpFormFieldView: View {

    let email: String
    let firstName: String
    let lastName: String
    var phone: String = ""

    enum FocusPin { case p1, p2, p3, p4, p5, p6, p7, p8 }

    @FocusState private var focus: FocusPin?
    @State private var p1 = ""
    @State private var p2 = ""
    @State private var p3 = ""
    @State private var p4 = ""
    @State private var p5 = ""
    @State private var p6 = ""
    @State private var p7 = ""
    @State private var p8 = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var resent = false

    private var otp: String { p1 + p2 + p3 + p4 + p5 + p6 + p7 + p8 }

    var body: some View {
        ZStack {
            K.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 24) {
            Spacer()
            Overline(text: "Verification")
            SerifHeading(text: "Verify your Email", size: 28)
            Text("Enter the 8-digit code sent to \(email)")
                .font(.system(size: 13))
                .foregroundColor(K.textDim)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 6) {
                TextField("", text: $p1)
                    .modifier(OtpModifer(pin: $p1))
                    .focused($focus, equals: .p1)
                    .onChange(of: p1, perform: { v in if v.count == 1 { focus = .p2 } })

                TextField("", text: $p2)
                    .modifier(OtpModifer(pin: $p2))
                    .focused($focus, equals: .p2)
                    .onChange(of: p2, perform: { v in
                        if v.count == 1 { focus = .p3 }
                        else if v.isEmpty { focus = .p1 }
                    })

                TextField("", text: $p3)
                    .modifier(OtpModifer(pin: $p3))
                    .focused($focus, equals: .p3)
                    .onChange(of: p3, perform: { v in
                        if v.count == 1 { focus = .p4 }
                        else if v.isEmpty { focus = .p2 }
                    })

                TextField("", text: $p4)
                    .modifier(OtpModifer(pin: $p4))
                    .focused($focus, equals: .p4)
                    .onChange(of: p4, perform: { v in
                        if v.count == 1 { focus = .p5 }
                        else if v.isEmpty { focus = .p3 }
                    })

                TextField("", text: $p5)
                    .modifier(OtpModifer(pin: $p5))
                    .focused($focus, equals: .p5)
                    .onChange(of: p5, perform: { v in
                        if v.count == 1 { focus = .p6 }
                        else if v.isEmpty { focus = .p4 }
                    })

                TextField("", text: $p6)
                    .modifier(OtpModifer(pin: $p6))
                    .focused($focus, equals: .p6)
                    .onChange(of: p6, perform: { v in
                        if v.count == 1 { focus = .p7 }
                        else if v.isEmpty { focus = .p5 }
                    })

                TextField("", text: $p7)
                    .modifier(OtpModifer(pin: $p7))
                    .focused($focus, equals: .p7)
                    .onChange(of: p7, perform: { v in
                        if v.count == 1 { focus = .p8 }
                        else if v.isEmpty { focus = .p6 }
                    })

                TextField("", text: $p8)
                    .modifier(OtpModifer(pin: $p8))
                    .focused($focus, equals: .p8)
                    .onChange(of: p8, perform: { v in
                        if v.isEmpty { focus = .p7 }
                    })
            }
            .padding(.vertical)

            if let err = errorMessage {
                Text(err)
                    .foregroundColor(Color(red: 0.94, green: 0.52, blue: 0.5))
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button {
                Task { await verify() }
            } label: {
                CTALabel(title: "Verify", enabled: otp.count == 8 && !isLoading, loading: isLoading)
            }
            .disabled(otp.count < 8 || isLoading)
            .padding(.horizontal)

            Button {
                Task { await resend() }
            } label: {
                Text(resent ? "Code resent ✓" : "Resend code")
                    .font(.footnote)
                    .foregroundColor(resent ? .green : K.gold)
            }
            .disabled(resent)

            Spacer()
            }
            .padding()
        }
        .navigationTitle("Verification")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { focus = .p1 }
    }

    private func verify() async {
        isLoading = true
        errorMessage = nil
        do {
            try await supabase.auth.verifyOTP(email: email, token: otp, type: .email)
            try await BookingService().saveProfile(firstName: firstName, lastName: lastName, phone: phone)
            // ContentView's authStateChanges listener handles navigation automatically
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func resend() async {
        do {
            try await supabase.auth.signInWithOTP(email: email)
            resent = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        OtpFormFieldView(email: "test@example.com", firstName: "John", lastName: "Doe")
    }
}
