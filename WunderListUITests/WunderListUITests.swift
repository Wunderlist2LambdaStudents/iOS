//
//  WunderListUITests.swift
//  WunderListUITests
//
//  Created by Kenny on 5/22/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import XCTest

class WunderListUITests: XCTestCase {

    override func setUpWithError() throws {
               continueAfterFailure = false
               let app = XCUIApplication()
               app.launchArguments = ["UITesting"]
               app.launch()
           }

    enum Identifier: String {
        case loginNameTextField = "LoginViewController.NameTextField"
        case loginPasswordField = "LoginViewController.PWTextField"
        case loginStartButton = "LoginViewController.GetStartedButton"
        case loginTCLabel = "LoginViewController.T&CLabel"
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.

        let signInButton = app.segmentedControls.buttons["Sign In"]
        signInButton.tap()

        let signUpButton = app.segmentedControls.buttons["Sign Up"]
        signUpButton.tap()
        signInButton.tap()
        signUpButton.tap()
        app.textFields["LoginViewController.NameTextField"].tap()
        app.textFields["LoginViewController.EmailTextField"].tap()
        app.textFields["LoginViewController.PWTextField"].tap()
        app.buttons["LoginViewController.GetStartedButton"].tap()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
