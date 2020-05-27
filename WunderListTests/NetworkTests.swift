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
    func testSpeedOfTypicalLoginRequest() {
        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            let expectation = self.expectation(description: "\(#file), \(#function): WaitForLoginSpeedResult")
            let controller = AuthService(dataLoader: URLSession(configuration: .ephemeral))
            startMeasuring()
            controller.loginUser(with: "testiOSUser", password: "123456") {
                XCTAssertNotNil(AuthService.activeUser)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 5)
        }
    }

    func testLoggingInUser() {
        let expectation = self.expectation(description: "\(#file), \(#function): WaitForLoginResult")
        let authService = AuthService()
        authService.loginUser(with: "testiOSUser", password: "123456") {
            XCTAssertNotNil(AuthService.activeUser)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testGettingData() {
        let expectation = self.expectation(description: "\(#file), \(#function): WaitForGenericGetResult")
        let networkService = NetworkService()
        //test creating request
        let request = networkService.createRequest(url: URL(string: "https://www.google.com"), method: .get)
        XCTAssertNotNil(request)
        //test loading data from request
        networkService.dataLoader.loadData(using: request!) { (data, response, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(data)
            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Mock Tests -
    func testDecodingMockUserData() {
        let expectation = self.expectation(description: "\(#file), \(#function): WaitForDecodingMockUserData")
        //create mockDataLoader and create Request
        let mockDataLoader = MockDataLoader(
            data: Data.mockData(with: .goodUserData),
            response: nil,
            error: nil
        )
        let networkService = NetworkService(dataLoader: mockDataLoader)
        let request = URLRequest(url: URL(string: "https://google.com")!)
        //load mock data and test
        networkService.dataLoader.loadData(using: request) { (data, response, error) in
            XCTAssertNotNil(data)
            XCTAssertNil(response)
            XCTAssertNil(error)
            let mockUser = networkService.decode(to: UserRepresentation.self, data: data!)
            XCTAssertNotNil(mockUser)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testDecodingMockTodo() {
        let expectation = self.expectation(description: "\(#file), \(#function): WaitForDecodingMockTodoData")
        //create mockDataLoader and create Request
        let mockDataLoader = MockDataLoader(
            data: Data.mockData(with: .goodTodoData),
            response: nil,
            error: nil
        )
        let networkService = NetworkService(dataLoader: mockDataLoader)
        let request = URLRequest(url: URL(string: "https://google.com")!)
        //load mock data and test
        networkService.dataLoader.loadData(using: request) { (data, response, error) in
            XCTAssertNotNil(data)
            XCTAssertNil(response)
            XCTAssertNil(error)
            //create dateFormatter to decode date string
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let mockTodo = networkService.decode(to: TodoRepresentation.self, data: data!, dateFormatter: dateFormatter)
            XCTAssertNotNil(mockTodo)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testAddingMockTodosToMockUser() {
        var mockUser = UserRepresentation(username: "TestUser", password: "123456", identifier: UUID(), token: "123456", todos: [])
        //decode mock todos
        let expectation = self.expectation(description: "\(#file), \(#function): WaitForDecodingMockTodoData")
        //create mockDataLoader and create Request
        let mockDataLoader = MockDataLoader(
            data: Data.mockData(with: .goodTodoData),
            response: nil,
            error: nil
        )
        let networkService = NetworkService(dataLoader: mockDataLoader)
        let request = URLRequest(url: URL(string: "https://google.com")!)
        //load mock data and test
        networkService.dataLoader.loadData(using: request) { (data, response, error) in
            XCTAssertNotNil(data)
            XCTAssertNil(response)
            XCTAssertNil(error)
            //create dateFormatter to decode date string
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            guard let mockTodo = networkService.decode(
                to: [TodoRepresentation].self,
                data: data!,
                dateFormatter: dateFormatter
            ) else { return }
            mockUser.todos?.append(contentsOf: mockTodo)
            XCTAssertNotNil(mockUser.todos)
            XCTAssertEqual(mockUser.todos?.count, 2)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
}
