//
//  SendEmail.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 11/7/23.
//

import Foundation
import SwiftSMTP

struct SendEmail {
    func send(with ride: Ride, and res: CreatedBookingResponseData) {
        let smtpServer = SMTP(hostname: "smtp.gmail.com", email: "privateincapps@gmail.com", password: "sbhi juax avng zakd", port: 587)
        let receiver = Mail.User(email: "privateappreservations@gmail.com")
        let sender = Mail.User(email: "privateincapps@gmail.com")
//        let sender = Mail.User(email: "jibraanahmed10@gmail.com")
//        let receiver = Mail.User(email: "privateincapps@gmail.com")
        let email = Mail(from: sender, to: [receiver], subject: "MOBILE RIDE SCHEDULED - " + ride.formattedDate + " PST", text: "User ID: \(res.booking.customerID)\nScheduled for \(ride.formattedDate) PST")
        smtpServer.send(email)
    }
}
