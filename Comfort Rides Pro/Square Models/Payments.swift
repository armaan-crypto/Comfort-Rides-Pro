//
//  Payments.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 11/22/23.
//

import Foundation
import SquareInAppPaymentsSDK
import SquareInAppPaymentsSwiftUI
import SquareBuyerVerificationSDK

struct SquarePayment {
    
    let sandboxKey = "EAAAEHO3dmYEsPSJTl-qDCfFtejSW5Ykw2zy2dUGog-int-OE_lnTW5H30MwBvC1"
    var pCompletion: ((String) -> Void)? = nil
    
    enum PayErr: Error {
        case couldntPay
        case couldntAdd
        case couldntDisable
    }
    
    func processCardToken(card: SQIPCardDetails, verify: SQIPBuyerVerifiedDetails?, completionHandler: @escaping (Error?) -> Void) {
        let cardToken = card.nonce
        //let verifyToken = verify?.verificationToken
        Task {
            do {
//                let paymentId = try await pay(with: cardToken)
                let newId = try await addCardToUser(with: cardToken, and: "Personal")
                completionHandler(nil)
                if let pCompletion = pCompletion {
                    pCompletion(newId)
                }
            } catch {
                completionHandler(error)
            }
        }
    }
    
    func pay(with nonce: String, amount: Int, and customer: String = U.getUserID()!) async throws -> String {
        let parameters = "{\n    \"idempotency_key\": \"\(UUID())\",\n    \"source_id\": \"\(nonce)\",\n    \"amount_money\": {\n      \"currency\": \"USD\",\n      \"amount\": \(amount)\n    },\n    \"customer_id\": \"\(customer)\"\n  }"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: "https://connect.\(K.keyword).com/v2/payments")!,timeoutInterval: Double.infinity)
        request.addValue("2023-11-15", forHTTPHeaderField: "Square-Version")
        request.addValue("Bearer \(K.key)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        print(String(data: data, encoding: .utf8))
        guard (200...210).contains((response as? HTTPURLResponse)!.statusCode) else { throw PayErr.couldntPay }
        
        let responseData = try JSONDecoder().decode(CreatedPaymentResponse.self, from: data)
        return responseData.payment.id
        
    }
    
    fileprivate func addCardToUser(with cnon: String, and name: String) async throws -> String {
        let parameters = "{\n    \"card\": {\n      \"customer_id\": \"\(U.getUserID()!)\",\n      \"reference_id\": \"\(name)\"\n    },\n    \"source_id\": \"\(cnon)\",\n    \"idempotency_key\": \"\(UUID())\"\n  }"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: "https://connect.squareup.com/v2/cards")!,timeoutInterval: Double.infinity)
        request.addValue("2023-11-15", forHTTPHeaderField: "Square-Version")
        request.addValue("Bearer \(K.key)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        print(String(data: data, encoding: .utf8))
        guard (200...210).contains((response as? HTTPURLResponse)!.statusCode) else { throw PayErr.couldntAdd }
        let responseData = try JSONDecoder().decode(CreatedCardResponse.self, from: data)
        return responseData.card.id

    }
    
    func disableCard(id: String) async throws {
        var request = URLRequest(url: URL(string: "https://connect.\(K.keyword).com/v2/cards/\(id)/disable")!,timeoutInterval: Double.infinity)
        request.addValue("2023-11-15", forHTTPHeaderField: "Square-Version")
        request.addValue("Bearer \(K.key)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard (200...210).contains(((response as? HTTPURLResponse)!.statusCode)) else { throw PayErr.couldntDisable }
        return
    }
    
    func getCards() async throws -> [Card] {
        let customer = try await SquareManager().retrieveUser()
        
        return customer.cards ?? []
    }
}

struct CreatedPaymentResponse: Codable {
    let payment: CreatedPaymentResponsePayment
}

struct CreatedPaymentResponsePayment: Codable {
    let id: String
}

struct CreatedCardResponse: Codable {
    let card: CreatedCardResponsePayment
}

struct CreatedCardResponsePayment: Codable {
    let id: String
}
