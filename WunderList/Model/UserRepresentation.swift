//
//  UserRepresentation.swift
//  WunderList
//
//  Created by Kenny on 5/25/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import Foundation

struct UserRepresentation: Codable {
    let username: String
    //optional to avoid storing in CoreData
    let password: String?
    var token: String? = nil
}
