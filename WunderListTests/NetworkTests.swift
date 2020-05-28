//
//  NetworkTests.swift
//  NetworkTests
//
//  Created by Kenny on 5/22/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import XCTest
@testable import WunderList
/// Test Live and Mock network calls
///
///All live calls mutating a user should be balanced
///(i.e. if testing createTodo, delete the todo at the end of the test
///and make testing that it was deleted part of the test)
class NetworkTests: XCTestCase {

    // MARK: - API Up and Speed -

    ///Is the API working? Do our network methods work?
    func testGettingData() {
        let expectation = self.expectation(description: "\(#file), \(#function): WaitForGenericGetResult")
        let networkService = NetworkService()
        //test creating request
        let request = networkService.createRequest(
            url: URL(string: "https://bw-wunderlist.herokuapp.com/"),
            method: .get
        )
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
    ///How fast is the average login?
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

    // MARK: - API Functionality -

    ///Can the user login?
    func testLoggingInUser() {
        let expectation = self.expectation(description: "\(#file), \(#function): WaitForLoginResult")
        let authService = AuthService()
        authService.loginUser(with: "testiOSUser", password: "123456") {
            XCTAssertNotNil(AuthService.activeUser)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
    ///can we get todos from the server?
    func testGettingTodosFromServer() {
        /*
         loginUser {
            fetchTodos {

            }
         }
        */

    }
    ///Can we create a todo and delete it?
    ///
    ///Making this 2 seperate tests could create unbalanced create/delete calls for our mock user,
    ///causing other tests to fail
    func testCreatingAndDeletingLiveTodo() {
        /*
         loginUser {
            createTodo {
                deleteTodo {

                }
            }
         }
         */
    }

    // MARK: - Mock Tests -
    ///Can we decode Mock a Mock User using our MockDataLoader?
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

    ///Can we decode a Mock Todo using our MockDataLoader?
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
            let mockTodo = networkService.decode(
                to: [TodoRepresentation].self,
                data: data!, dateFormatter: dateFormatter
            )
            XCTAssertNotNil(mockTodo)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    ///Can we add Mock Todos to a Mock User?
    func testAddingMockTodosToMockUser() {
        var mockUser = UserRepresentation(
            username: "TestUser",
            password: "123456",
            identifier: UUID(),
            token: "123456",
            todos: []
        )
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
