//
//  Data+MockData.swift
//  WunderList
//
//  Created by Kenny on 5/26/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import Foundation

enum FileName: String {
    case goodUserData = "GoodUserData"
    case badUserData = "BadUserData"
    case goodTodoData = "GoodTodoData"
    case badTodoData = "BadTodoData"
}

extension Data {
    static func mockData(with name: FileName) -> Data {
        let bundle = Bundle(for: MockDataLoader.self)
        let url = bundle.url(forResource: name.rawValue, withExtension: "json")!
        var data = Data()
        do {
            data = try Data(contentsOf: url)
        } catch let fileError {
            print("Error loading file: \(fileError)")
        }
        return data
    }
}
