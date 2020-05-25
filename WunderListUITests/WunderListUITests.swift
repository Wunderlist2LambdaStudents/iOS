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

        let signInButton = app/*@START_MENU_TOKEN@*/.buttons["Sign In"]/*[[".segmentedControls.buttons[\"Sign In\"]",".buttons[\"Sign In\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        signInButton.tap()

        let signUpButton = app/*@START_MENU_TOKEN@*/.buttons["Sign Up"]/*[[".segmentedControls.buttons[\"Sign Up\"]",".buttons[\"Sign Up\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        signUpButton.tap()
        signInButton.tap()
        signUpButton.tap()
        app/*@START_MENU_TOKEN@*/.textFields["LoginViewController.NameTextField"]/*[[".textFields[\"  Enter Name\"]",".textFields[\"LoginViewController.NameTextField\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.textFields["LoginViewController.EmailTextField"]/*[[".textFields[\"  you@yourdomain.com\"]",".textFields[\"LoginViewController.EmailTextField\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.textFields["LoginViewController.PWTextField"]/*[[".textFields[\"  Password\"]",".textFields[\"LoginViewController.PWTextField\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.buttons["LoginViewController.GetStartedButton"]/*[[".buttons[\"Get Started\"]",".buttons[\"LoginViewController.GetStartedButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()

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
