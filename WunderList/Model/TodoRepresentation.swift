//
//  TodoRepresentation.swift
//  WunderList
//
//  Created by Kenny on 5/24/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import Foundation

enum Recurring: String, Codable, CaseIterable {
    case none
    case daily
    case weekly
    case monthly
}

struct LocationRepresentation: Codable {
    var xLocation: Double
    var yLocation: Double

    enum CodingKeys: String, CodingKey {
        case xLocation = "x"
        case yLocation = "y"
    }
}
//everything in the backend is "not-nullable" (not optional)
struct TodoRepresentation: Codable {
    var identifier: UUID
    var title: String
    var body: String
    var dueDate: Date
    var complete: Bool
    var recurring: Recurring
    var location: LocationRepresentation?
    var creatorId: UUID

    enum CodingKeys: String, CodingKey {
        case identifier
        case title
        case body
        case dueDate
        case complete
        case recurring
        case location
        case creatorId
    }
}
