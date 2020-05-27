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
    private let baseURL = URL(string: "https://bw-wunderlist.herokuapp.com/auth")!
    //static so it's always accessible and always the same user (until another user is logged in)
    ///The currently logged in user
    static var activeUser: UserRepresentation?

    // MARK: - Init -
    init(dataLoader: NetworkLoader = URLSession.shared) {
        self.dataLoader = dataLoader
    }

    // MARK: - Methods -
    func registerUser(with username: String, and password: String, completion: @escaping () -> Void) {
        let requestURL = baseURL.appendingPathComponent("/register")
        guard var request = networkService.createRequest(
            url: requestURL,
            method: .post,
            headerType: .contentType,
            headerValue: .json
        ) else { return }
        var loginUser = UserRepresentation(username: username, password: password)
        let encodedUser = networkService.encode(from: loginUser, request: &request)
        dump(String(data: request.httpBody ?? Data(), encoding: .utf8))
        guard let requestWithUser = encodedUser.request else {
            print("requestWithUser failed, error encoding user?")
            completion()
            return
        }
        networkService.dataLoader.loadData(using: requestWithUser, with: { (data, response, error) in
            if let error = error {
                print("error registering user: \(error)")
                completion()
                return
            }
            if let response = response {
                print("registration response status code: \(response.statusCode)")
            }
            if let data = data {
                print(String(data: data, encoding: .utf8) as Any) //as Any to silence warning
                guard let returnedUser = self.networkService.decode(
                    to: UserRepresentation.self,
                    data: data
                    ) else { return }
                loginUser = returnedUser
                AuthService.activeUser = loginUser
            }
            completion()
        })
    }

    func loginUser(with username: String, password: String, completion: @escaping () -> Void) {
        let loginURL = baseURL.appendingPathComponent("login")
        guard var request = networkService.createRequest(
            url: loginURL,
            method: .post,
            headerType: .contentType,
            headerValue: .json
            ) else {
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
                NSLog("Error logging user in: \(error)")
                completion()
                return
            }
            guard let data = data else {
                print("No data from login request")
                completion()
                return
            }
            print(response?.statusCode as Any) //as Any to silence warning
            if response?.statusCode == 200 {
                //once the user is logged in, assign the active user for use in methods external to this class
                loginUser.token = self.networkService.decode(to: Bearer.self, data: data)?.token
                //assign the static activeUser
                AuthService.activeUser = loginUser
                completion()
                return
            } else {
                //`String(describing:` to silence warning
                print("Bad Status Code: \(String(describing: response?.statusCode))")
            }
            completion()
        }
    }

    func logoutUser() {
        AuthService.activeUser = nil
        //global function to return user to login screen? local method here?
    }
}
