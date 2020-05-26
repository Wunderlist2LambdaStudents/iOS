//
//  MockDataLoader.swift
//  WunderListTests
//
//  Created by Kenny on 5/24/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import Foundation

class MockDataLoader: NetworkLoader {
    let data: Data?
    let response: HTTPURLResponse?
    let error: Error?

    init(data: Data?, response: HTTPURLResponse?, error: Error?) {
        self.data = data
        self.response = response
        self.error = error
    }

    private(set) var request: URLRequest?

    func loadData(using request: URLRequest, with completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
            self.request = request
            completion(self.data, self.response, self.error)
        }
    }
}


