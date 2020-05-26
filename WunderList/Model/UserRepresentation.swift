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
    //optional to avoid storing in CoreData/on server
    //password will sometimes be transmitted to the server, and sometimes not.
    let password: String?
    var identifier: String?
    //token will always be assigned by the login method and only
    //sent to the server for methods requiring an authenticated user
    var token: String?
    var todos: [TodoRepresentation]? = []
}
