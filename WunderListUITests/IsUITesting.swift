//
//  IsUITesting.swift
//  WunderListUITests
//
//  Created by Mark Poggi on 5/25/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import UIKit

var isUITesting: Bool {
    return CommandLine.arguments.contains("UITesting")
}
