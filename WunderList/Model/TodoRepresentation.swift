//
//  TodoRepresentation.swift
//  WunderList
//
//  Created by Kenny on 5/24/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import Foundation

enum Recurring: String, Codable {
    case none
    case daily
    case weekly
    case monthly
}

struct LocationRepresentation: Codable {
    var xLocation: Double
    var yLocation: Double
}

struct TodoRepresentation: Codable {
    let identifier: String
    var title: String
    var body: String
    var dueDate: Date
    var complete: Bool
    var recurring: Recurring
    var location: LocationRepresentation

    enum CodingKeys: String, CodingKey {
        case identifier
        case title
        case body
        case dueDate = "due_date"
        case complete
        case recurring
        case location
    }
}
