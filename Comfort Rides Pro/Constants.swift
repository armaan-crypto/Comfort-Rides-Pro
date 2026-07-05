//
//  Constants.swift
//  Comfort Rides Pro
//

import Foundation
import SwiftUI

struct K {
    static let darkBlue = Color(uiColor: UIColor(named: "black")!)

    // MARK: - Luxury theme
    static let gold = Color(red: 0.79, green: 0.66, blue: 0.42)
    static let goldLight = Color(red: 0.89, green: 0.79, blue: 0.56)
    static let ink = Color(red: 0.03, green: 0.05, blue: 0.09)
    static let surface = Color.white.opacity(0.055)
    static let hairline = Color.white.opacity(0.10)
    static let textDim = Color.white.opacity(0.55)

    static var backgroundGradient: LinearGradient {
        LinearGradient(colors: [darkBlue, ink], startPoint: .top, endPoint: .bottom)
    }

    static var goldGradient: LinearGradient {
        LinearGradient(colors: [goldLight, gold], startPoint: .top, endPoint: .bottom)
    }

    // TODO: move to .xcconfig before App Store submission; anon key is safe client-side (RLS is the security boundary)
    static let supabaseURL = "https://wyokmawzlouscxpqbjyn.supabase.co"
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind5b2ttYXd6bG91c2N4cHFianluIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMwMzc4NDIsImV4cCI6MjA5ODYxMzg0Mn0.F2XiZ5xfHx8SmI5VgRE3HJU7bGn6N42P07PYodxspTc"
}

struct F {
    static func vibrate(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactMed = UIImpactFeedbackGenerator(style: style)
        impactMed.impactOccurred()
    }
}

// MARK: - Shared luxury styling

/// Small uppercase gold section label
struct Overline: View {
    let text: String
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .semibold))
            .tracking(2.2)
            .foregroundColor(K.gold)
    }
}

/// Serif display heading
struct SerifHeading: View {
    let text: String
    var size: CGFloat = 26
    var body: some View {
        Text(text)
            .font(.system(size: size, weight: .semibold, design: .serif))
            .foregroundColor(.white)
    }
}

/// Primary call-to-action label (use inside Button / NavigationLink)
struct CTALabel: View {
    let title: String
    var enabled: Bool = true
    var loading: Bool = false

    var body: some View {
        ZStack {
            if loading {
                ProgressView().tint(enabled ? K.ink : K.gold)
            } else {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .tracking(0.5)
                    .foregroundColor(enabled ? K.ink : .white.opacity(0.35))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 54)
        .background(
            Group {
                if enabled {
                    K.goldGradient
                } else {
                    Color.white.opacity(0.08)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: enabled ? K.gold.opacity(0.25) : .clear, radius: 12, x: 0, y: 6)
    }
}

struct LuxCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(K.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(K.hairline, lineWidth: 1)
            )
    }
}

extension View {
    /// Translucent dark card with hairline border
    func luxCard() -> some View { modifier(LuxCardModifier()) }
}
