//
//  CreatedLocationResponseData.swift
//  Comfort Rides Pro
//
//  Created by Armaan Ahmed on 4/15/23.
//

import Foundation

struct CreatedLocationResponseData: Codable {
    let location: CreatedLocationResponseDataLocation
}

struct CreatedLocationResponseDataLocation: Codable {
    let id: String
}
