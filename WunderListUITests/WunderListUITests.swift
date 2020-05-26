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
        case loginEmailTextField = "LoginViewController.EmailTextField"
    }

    private var testUserName = "Test Name"
    private var testUserEmail = "test@test.com"
    private var testUserPW = "password"

    private var app: XCUIApplication {
        return XCUIApplication()
    }

    private func textField(identifier: Identifier) -> XCUIElement {
        return app.textFields[identifier.rawValue]
    }

    private var emailTextField: XCUIElement {
        return textField(identifier: .loginEmailTextField)
      }

    private var nameTextField: XCUIElement {
           return textField(identifier: .loginNameTextField)
         }



    func testExample() throws {
        // UI tests must launch the application that they test.
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

    func testUserSignUp() throws {
//        let loginScreen = app.tables.matching(identifier: "LoginViewController")

        let signInButton = app.segmentedControls.buttons["Sign Up"]
        XCTAssert(signInButton.isHittable)
        signInButton.tap()

//        XCTAssert(nameTextField.isHittable)
//        nameTextField.tap()
//        nameTextField.typeText(testUserName)
//
//        XCTAssert(emailTextField.isHittable)
//        emailTextField.tap()
//        emailTextField.typeText(testUserEmail)

//        let nameField = app.te
//        nameField.tap()
//        nameField.typeText("Test Name")
//
//        let emailField = app.textFields[Identifier.loginEmailTextField.rawValue]
//        emailField.tap()
//        emailField.typeText(testUserEmail)
//
//        let pwField = app.textFields[Identifier.loginPasswordField.rawValue]
//        pwField.tap()
//        pwField.typeText(testUserPW)
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
