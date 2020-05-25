//
//  NetworkTests.swift
//  NetworkTests
//
//  Created by Kenny on 5/22/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import XCTest
@testable import WunderList

class NetworkTests: XCTestCase {

    func testGettingData() {
        let expectation = self.expectation(description: "\(#file), \(#function): WaitForGenericGetResult")
        let networkService = NetworkService()
        //test creating request
        let request = networkService.createRequest(url: URL(string: "https://www.google.com"), method: .get)
        XCTAssertNotNil(request)
        //test loading data from request
        networkService.dataLoader.loadData(using: request!) { (data, response, error) in
            XCTAssertNotNil(error)
            XCTAssertNotNil(data)
            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testDecodingMockUserData() {
        // FIXME: Once refactored to live user, remove this
        struct MockUser: Codable {
            let username: String
        }
        let expectation = self.expectation(description: "\(#file), \(#function): WaitForDecodingMockData")
        let mockDataLoader = MockDataLoader(data: Data.mockData(with: "GoodUserData"), response: nil, error: nil)
        let networkService = NetworkService(dataLoader: mockDataLoader)
        var request = URLRequest(url: URL(string: "https://google.com")!)
        networkService.dataLoader.loadData(using: request) { (data, response, error) in
            XCTAssertNotNil(data)
            XCTAssertNil(response)
            XCTAssertNil(error)
            // FIXME: Once refactored to live user, change type ALSO CHANGE MOCK JSON TO MATCH BACKEND SAMPLE JSON
            let mockUser = networkService.decode(to: MockUser.self, data: data!)
            networkService.encode(from: mockUser, request: &request)
            networkService.dataLoader.loadData(using: foo.request) { (data, response, error) in

            }
            XCTAssertNotNil(mockUser)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func foo() {
        let networkHelper = NetworkService()
        let request = networkHelper.createRequest(url: URL(string: "https://google.com"), method: .get)
        networkHelper.dataLoader.loadData(using: request!) { (data, response, error) in
            if let error = error {
                print("error getting google")
                print(error)
            }
            if let response = response {
                print(response.statusCode)
            }
            if let data = data {
                print(data)
            }
        }
    }
}
