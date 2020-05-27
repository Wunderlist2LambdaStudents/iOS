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

    static func writeToFile<EncodableData: Encodable>(with name: FileName, encodableData: EncodableData) {
        do {
            let bundle = Bundle(for: MockDataLoader.self)
            guard let url = bundle.url(forResource: name.rawValue, withExtension: "json") else {
                print("invalid URL for \(name.rawValue)")
                return
            }
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(encodableData)
            try jsonData.write(to: url)
        } catch let encodeError {
            print("Error encoding data to \(name.rawValue): \(encodeError)")
        }
    }
}
