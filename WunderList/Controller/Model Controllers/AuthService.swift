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
    private let networkService = NetworkService()
    private let dataLoader: NetworkLoader
    // FIXME: Set this once backend is established
    private let baseURL = URL(string: "https://www.google.com")!
    //static so it's always accessible and always the same user (until another user is logged in)
    static var activeUser: UserRepresentation?
    init(dataLoader: NetworkLoader = URLSession.shared) {
        self.dataLoader = dataLoader
    }

    func loginUser(with username: String, password: String, completion: @escaping () -> Void) {
        guard var request = networkService.createRequest(url: baseURL, method: .post, headerType: .auth) else {
            print("Error forming request, bad URL?")
            completion()
            return
        }
        //token is nil in UserRepresentation by default, so not required in the initializer
        var loginUser = UserRepresentation(username: username, password: password)
        let encodedUser = networkService.encode(from: loginUser, request: &request)
        guard let requestWithUser = encodedUser.request else {
            print("requestWithUser failed, error encoding user?")
            completion()
            return
        }
        networkService.dataLoader.loadData(using: requestWithUser) { (data, response, error) in
            if let error = error {
                NSLog("Error loggin user in: \(error)")
                completion()
                return
            }
            guard let data = data else {
                print("No data from login request")
                completion()
                return
            }
            if response?.statusCode == 200 {
                //once the user is logged in, assign the token to the user for use in methods external to this class
                loginUser.token = self.networkService.decode(to: Bearer.self, data: data)?.token
                //assign the static activeUser
                AuthService.activeUser = loginUser
                completion()
            }
            completion()
        }
    }

    func logoutUser() {
        AuthService.activeUser = nil
        //global function to return user to login screen? local method here?
    }
}
