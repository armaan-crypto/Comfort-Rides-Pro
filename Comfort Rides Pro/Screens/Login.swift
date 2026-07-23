//
//  Login.swift
//  Comfort Rides Pro
//

import SwiftUI
import AlertToast

// MARK: - Welcome screen

struct Login: View {
    var body: some View {
        ZStack {
            // Background gradient
            K.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo + name
                VStack(spacing: 28) {
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 132)
                        .cornerRadius(28)
                        .shadow(color: .black.opacity(0.5), radius: 24, x: 0, y: 12)
                }

                Spacer()

                // Buttons
                VStack(spacing: 14) {
                    NavigationLink(destination: SignUpView()) {
                        CTALabel(title: "Create an account")
                    }

                    NavigationLink(destination: SignInView()) {
                        Text("Sign in")
                            .font(.system(size: 16))
                            .tracking(0.5)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 48)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Sign In (email only)

struct SignInView: View {
    @State private var email = ""
    @State private var loading = false
    @State private var isError = false
    @State private var error = ""
    @State private var showOtp = false

    var body: some View {
        ZStack {
            K.backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 24)

                    VStack(spacing: 14) {
                        CRLogo(isSmall: true)
                        Overline(text: "Members")
                        SerifHeading(text: "Welcome back", size: 28)
                        Text("Enter your email to receive a sign-in code")
                            .font(.system(size: 14))
                            .foregroundColor(K.textDim)
                            .multilineTextAlignment(.center)
                    }

                    AuthTextField(placeholder: "Email address", text: $email, keyboardType: .emailAddress)

                    AuthButton(title: "Continue", loading: loading) {
                        await sendOTP()
                    }
                }
                .padding(.horizontal, 28)
            }
        }
        .navigationDestination(isPresented: $showOtp) {
            OtpFormFieldView(email: email, firstName: "", lastName: "")
        }
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
        .toast(isPresenting: $isError) {
            AlertToast(type: .regular, title: "Error", subTitle: error)
        }
    }

    private func sendOTP() async {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            error = "Enter your email address"
            isError = true
            return
        }
        loading = true
        do {
            try await supabase.auth.signInWithOTP(email: email.trimmingCharacters(in: .whitespaces))
            showOtp = true
        } catch {
            self.error = error.localizedDescription
            isError = true
        }
        loading = false
    }
}

// MARK: - Sign Up (email + name)

struct SignUpView: View {
    @State private var email = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phone = ""
    @State private var loading = false
    @State private var isError = false
    @State private var error = ""
    @State private var showOtp = false

    var body: some View {
        ZStack {
            K.backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    Spacer().frame(height: 24)

                    VStack(spacing: 14) {
                        CRLogo(isSmall: true)
                        Overline(text: "Membership")
                        SerifHeading(text: "Create your account", size: 28)
                        Text("We'll send a verification code to your email")
                            .font(.system(size: 14))
                            .foregroundColor(K.textDim)
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 14) {
                        AuthTextField(placeholder: "Email address", text: $email, keyboardType: .emailAddress)
                        AuthTextField(placeholder: "First name", text: $firstName, contentType: .givenName)
                        AuthTextField(placeholder: "Last name", text: $lastName, contentType: .familyName)
                        AuthTextField(placeholder: "Phone number", text: $phone, contentType: .telephoneNumber, keyboardType: .phonePad)
                    }

                    AuthButton(title: "Continue", loading: loading) {
                        await sendOTP()
                    }
                }
                .padding(.horizontal, 28)
            }
        }
        .navigationDestination(isPresented: $showOtp) {
            OtpFormFieldView(email: email, firstName: firstName, lastName: lastName, phone: phone)
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
        .toast(isPresenting: $isError) {
            AlertToast(type: .regular, title: "Error", subTitle: error)
        }
    }

    private func sendOTP() async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        guard !trimmedEmail.isEmpty, !firstName.isEmpty, !lastName.isEmpty, !phone.isEmpty else {
            error = "Fill out all fields"
            isError = true
            return
        }
        loading = true
        do {
            try await supabase.auth.signInWithOTP(email: trimmedEmail)
            showOtp = true
        } catch {
            self.error = error.localizedDescription
            isError = true
        }
        loading = false
    }
}

// MARK: - Shared components

struct CRLogo: View {
    var isSmall: Bool = false
    var body: some View {
        Image("logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: isSmall ? 76 : 200)
            .cornerRadius(isSmall ? 18 : 20)
            .shadow(color: .black.opacity(0.45), radius: 14, x: 0, y: 8)
    }
}

struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    var contentType: UITextContentType? = nil
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.35)))
            .font(.system(size: 16))
            .foregroundColor(.white)
            .tint(K.gold)
            .padding(.horizontal, 16)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(K.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(K.hairline, lineWidth: 1)
            )
            .textContentType(contentType)
            .keyboardType(keyboardType)
            .autocorrectionDisabled()
            .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
    }
}

struct AuthButton: View {
    let title: String
    let loading: Bool
    let action: () async -> Void

    var body: some View {
        Button {
            Task { await action() }
        } label: {
            CTALabel(title: title, enabled: !loading, loading: loading)
        }
        .disabled(loading)
    }
}

struct LoginTest_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { Login() }
    }
}
