//
//  SquareError.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 3/26/23.
//

import Foundation

// MARK: - Enum Error
enum SquareError: Error {
    case userNotFound
    case sessionExpired
}

extension SquareError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .userNotFound:
            return NSLocalizedString("User wasn't found", comment: "User not found")
        case .sessionExpired:
            return NSLocalizedString("Your session has expired, please login", comment: "Session expired")
        }
    }
}

// MARK: - Returned Error

// MARK: - SquareError
struct SquareErrorJSON: Codable {
    let errors: [SEError]
}

// MARK: - Error
struct SEError: Codable {
    let code, detail, category: String
    
    var showedText: String {
        return code.replacingOccurrences(of: "_", with: " ").lowercased().capitalized
    }
}
