//
//  OtpFormFieldView.swift
//  Comfort Rides Pro
//

import SwiftUI
import Supabase

struct OtpFormFieldView: View {

    let email: String
    let firstName: String
    let lastName: String
    var phone: String = ""

    private let codeLength = 8

    @FocusState private var isFocused: Bool
    @State private var otpCode = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var resent = false

    var body: some View {
        ZStack {
            K.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 36) {
                Spacer()

                VStack(spacing: 12) {
                    Overline(text: "Verification")
                    SerifHeading(text: "Check your email", size: 26)
                    Text("Enter the \(codeLength)-digit code sent to\n\(email)")
                        .font(.system(size: 14))
                        .foregroundColor(K.textDim)
                        .multilineTextAlignment(.center)
                }

                // Single hidden field + visual digit boxes
                ZStack {
                    TextField("", text: $otpCode)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .focused($isFocused)
                        .frame(width: 1, height: 1)
                        .opacity(0.001)
                        .onChange(of: otpCode, perform: { value in
                            let filtered = String(value.filter(\.isNumber).prefix(codeLength))
                            if otpCode != filtered { otpCode = filtered }
                            if filtered.count == codeLength { Task { await verify() } }
                        })

                    HStack(spacing: 8) {
                        ForEach(0..<codeLength, id: \.self) { index in
                            OtpDigitBox(
                                digit: digit(at: index),
                                isActive: isFocused && index == min(otpCode.count, codeLength - 1)
                            )
                        }
                    }
                    .onTapGesture { isFocused = true }
                }

                if let err = errorMessage {
                    Text(err)
                        .font(.system(size: 13))
                        .foregroundColor(.red.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                CTALabel(title: "Verify", enabled: otpCode.count == codeLength, loading: isLoading)
                    .onTapGesture { if otpCode.count == codeLength && !isLoading { Task { await verify() } } }
                    .padding(.horizontal, 28)

                Button {
                    Task { await resend() }
                } label: {
                    Text(resent ? "Code resent ✓" : "Resend code")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(resent ? .green : K.gold)
                }
                .disabled(resent || isLoading)

                Spacer()
            }
        }
        .navigationTitle("Verification")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { isFocused = true }
    }

    private func digit(at index: Int) -> String {
        guard index < otpCode.count else { return "" }
        return String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: index)])
    }

    private func verify() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            try await supabase.auth.verifyOTP(email: email, token: otpCode, type: .email)
            try await BookingService().saveProfile(firstName: firstName, lastName: lastName, phone: phone)
            // ContentView's authStateChanges listener handles navigation automatically
        } catch {
            errorMessage = error.localizedDescription
            otpCode = ""
            isFocused = true
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

private struct OtpDigitBox: View {
    let digit: String
    let isActive: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(K.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(isActive ? K.gold : K.hairline, lineWidth: isActive ? 1.5 : 1)
                )

            if digit.isEmpty {
                if isActive {
                    Rectangle()
                        .fill(K.gold)
                        .frame(width: 1.5, height: 20)
                }
            } else {
                Text(digit)
                    .font(.system(size: 20, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
            }
        }
        .frame(width: 36, height: 46)
    }
}

#Preview {
    NavigationStack {
        OtpFormFieldView(email: "test@example.com", firstName: "John", lastName: "Doe")
    }
}
