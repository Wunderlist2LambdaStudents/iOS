//
//  AuthService.swift
//  WunderList
//
//  Created by Kenny on 5/25/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import Foundation

struct Bearer: Codable {
    var token: String
}

class AuthService {
    // MARK: - Properties -
    private var token: String?
    private let networkService = NetworkService()
    private let dataLoader: NetworkLoader
    // FIXME: Set this once backend is established
    private let baseURL = URL(string: "")!
    //static so it's always accessible and always the same user (until another user is logged in)
    static var activeUser: UserRepresentation?

    init(dataLoader: NetworkLoader = URLSession.shared) {
        self.dataLoader = dataLoader
    }

    func loginUser(with username: String, password: String) {
        guard var request = networkService.createRequest(url: baseURL, method: .post, headerType: .auth) else {
            print("Error forming request, bad URL?")
            return
        }
        let loginUser = UserRepresentation(username: username, password: password)
        let encodedUser = networkService.encode(from: loginUser, request: &request)
        guard let requestWithUser = encodedUser.request else {
            print("requestWithUser failed, error encoding user?")
            return
        }
        networkService.dataLoader.loadData(using: requestWithUser) { (data, response, error) in
            if let error = error {
                NSLog("Error loggin user in: \(error)")
                return
            }
            guard let data = data else {
                print("No data from login request")
                return
            }
            if response?.statusCode == 200 {
                self.token = self.networkService.decode(to: Bearer.self, data: data)?.token
                AuthService.activeUser = loginUser
            }
        }
    }

    func logoutUser() {
        token = nil
        //global function to return user to login screen? local method here?
    }
}
