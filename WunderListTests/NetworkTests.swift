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
        //test creating request
        let request = NetworkService.createRequest(url: URL(string: "https://www.google.com"), method: .get)
        XCTAssertNotNil(request)
        //test loading data from request
        NetworkService.loadData(using: request!) { (data, response, error) in
            XCTAssertNotNil(data)
            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testDecodingMockUserData() {
        let mockDataLoader = MockDataLoader(data: Data.mockData(with: "GoodUserData"), response: nil, error: nil)
        mockDataLoader.loadData(using: <#T##URLRequest#>, with: <#T##(Data?, URLResponse?, Error?) -> Void#>)
    }

}
