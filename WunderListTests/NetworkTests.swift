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

    // FIXME: Once refactored to live user, remove this
    struct MockUser: Codable {
        let username: String
    }

    func testDecodingMockUserData() {

        let expectation = self.expectation(description: "\(#file), \(#function): WaitForDecodingMockData")
        let mockDataLoader = MockDataLoader(data: Data.mockData(with: "GoodUserData"), response: nil, error: nil)
        let networkService = NetworkService(dataLoader: mockDataLoader)
        let request = URLRequest(url: URL(string: "https://google.com")!)
        networkService.dataLoader.loadData(using: request) { (data, response, error) in
            XCTAssertNotNil(data)
            XCTAssertNil(response)
            XCTAssertNil(error)
            // FIXME: Once refactored to live user, change type ALSO CHANGE MOCK JSON TO MATCH BACKEND SAMPLE JSON
            let mockUser = networkService.decode(to: MockUser.self, data: data!)
            XCTAssertNotNil(mockUser)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testDecodingMockTodo() {
        let expectation = self.expectation(description: "\(#file), \(#function): WaitForDecodingMockData")
        let mockDataLoader = MockDataLoader(data: Data.mockData(with: "GoodTodoData"), response: nil, error: nil)
        let networkService = NetworkService(dataLoader: mockDataLoader)
        let request = URLRequest(url: URL(string: "https://google.com")!)
        networkService.dataLoader.loadData(using: request) { (data, response, error) in
            XCTAssertNotNil(data)
            XCTAssertNil(response)
            XCTAssertNil(error)
            // FIXME: Once refactored to live user, change type ALSO CHANGE MOCK JSON TO MATCH BACKEND SAMPLE JSON
            let mockUser = networkService.decode(to: TodoRepresentation.self, data: data!)
            XCTAssertNotNil(mockUser)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}
