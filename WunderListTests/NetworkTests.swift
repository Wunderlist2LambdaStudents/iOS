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
        let expectation = self.expectation(description: "Wait for google")
        let networkService = NetworkService()
        //test creating request
        let request = networkService.createRequest(url: URL(string: "https://www.google.com"), method: .get)
        XCTAssertNotNil(request)
        //test loading data from request
        networkService.dataLoader.loadData(using: request!) { (data, response, error) in
            XCTAssertNotNil(data)
            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testDecodingMockUserData() {
        // FIXME: Once refactored to live user, remove this
        struct MockUser: Decodable {
            let username: String
        }
        let expectation = self.expectation(description: "\(#file), \(#function): WaitForResults")
        let mockDataLoader = MockDataLoader(data: Data.mockData(with: "GoodUserData"), response: nil, error: nil)
        let networkService = NetworkService(dataLoader: mockDataLoader)
        let request = URLRequest(url: URL(string: "https://google.com")!)
        networkService.dataLoader.loadData(using: request) { (data, response, error) in
            XCTAssertNotNil(data)
            // FIXME: Once refactored to live user, change type ALSO CHANGE MOCK JSON TO MATCH BACKEND SAMPLE JSON
            print(networkService.decode(to: MockUser.self, data: data!))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)


    }

}
