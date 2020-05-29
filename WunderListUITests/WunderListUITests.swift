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
        case signInButtonLabel = "Welcome Back!"
        case signUpButtonLabel = "Get Started"
        case addToDoButton = "ToDoListViewController.addToDo"
        case addLocationButton = "TodoEditAndAddViewController.addLocationButton"
        case addDetailTextView = "TodoEditAndAddViewController.addDetailTextView"
        case addTitleTextField = "TodoEditAndAddViewController.titleText"
        case completeButton = "TodoListViewController.completeToggleButton"
        case toDoListItem = "TodoListViewController.todoItem"
        case saveToDoButton = "TodoEditAndAddViewController.saveButton"
        case cancelToDoButton = "TodoEditAndAddViewController.cancelButton"
    }

    private var testUserName = "Test Name"
    private var testUserEmail = "test@test.com"
    private var testUserPW = "password"
    private var detailTextEntry = "Test detail entry for UI Testing."
    private var titleTextEntry = "Test title entry for UI Testing."

    private var app: XCUIApplication {
        return XCUIApplication()
    }

    private func textField(identifier: Identifier) -> XCUIElement {
        return app.textFields[identifier.rawValue]
    }

    private func textView(identifier: Identifier) -> XCUIElement {
           return app.textViews[identifier.rawValue]
       }

    private func buttons(identifier: Identifier) -> XCUIElement {
        return app.buttons[identifier.rawValue]
    }

    private func signInHelper() {
              let signInButton = app.segmentedControls.buttons["Sign In"]
                XCTAssert(signInButton.isHittable)
                signInButton.tap()

                emailTextField.tap()
                XCTAssert(emailTextField.isHittable)
                emailTextField.typeText(testUserEmail)
                XCTAssertTrue(emailTextField.value as? String == testUserEmail)

                pwTextField.tap()
                pwTextField.typeText(testUserPW)
                XCTAssertTrue(pwTextField.value as? String == testUserPW)

                let point = CGPoint(x: 100, y: 100)
                app.tapCoordinate(at: point)

                let startButton = app.buttons.element(boundBy: 2)
                XCTAssertTrue(startButton.isHittable)
                startButton.tap()
            }

    private var emailTextField: XCUIElement {
        return textField(identifier: .loginEmailTextField)
    }

    private var nameTextField: XCUIElement {
        return textField(identifier: .loginNameTextField)
    }

    private var pwTextField: XCUIElement {
        return textField(identifier: .loginPasswordField)
    }

    private var loginStartButton: XCUIElement {
        return buttons(identifier: .loginStartButton)
    }

    private var addToDoButton: XCUIElement {
        return buttons(identifier: .addToDoButton)
    }

    private var addTitleTextField: XCUIElement {
        return textField(identifier: .addTitleTextField)
    }

    private var addDetailTextView: XCUIElement {
        return textView(identifier: .addDetailTextView)
    }

    private var saveToDoButton: XCUIElement {
        return buttons(identifier: .saveToDoButton)
    }

    func testUserSignUp() throws {
        let signUpButton = app.segmentedControls.buttons["Sign Up"]
        XCTAssert(signUpButton.isHittable)
        signUpButton.tap()

        emailTextField.tap()
        XCTAssert(emailTextField.isHittable)
        emailTextField.typeText(testUserEmail)
        XCTAssertTrue(emailTextField.value as? String == testUserEmail)

        pwTextField.tap()
        pwTextField.typeText(testUserPW)
        XCTAssertTrue(pwTextField.value as? String == testUserPW)

        let point = CGPoint(x: 100, y: 100)
        app.tapCoordinate(at: point)

        let startButton = app.buttons.element(boundBy: 2)
        XCTAssertTrue(startButton.isHittable)
        startButton.tap()

    }

    func testUserSignIn() throws {
        let signInButton = app.segmentedControls.buttons["Sign In"]
        XCTAssert(signInButton.isHittable)
        signInButton.tap()

        emailTextField.tap()
        XCTAssert(emailTextField.isHittable)
        emailTextField.typeText(testUserEmail)
        XCTAssertTrue(emailTextField.value as? String == testUserEmail)

        pwTextField.tap()
        pwTextField.typeText(testUserPW)
        XCTAssertTrue(pwTextField.value as? String == testUserPW)

        let point = CGPoint(x: 100, y: 100)
        app.tapCoordinate(at: point)

        let startButton = app.buttons.element(boundBy: 2)
        XCTAssertTrue(startButton.isHittable)
        startButton.tap()
    }

    func testStartButtonTextChanges() {
        let signInButton = app.segmentedControls.buttons["Sign In"]
        XCTAssert(signInButton.isHittable)
        signInButton.tap()

        XCTAssertTrue(loginStartButton.label == Identifier.signInButtonLabel.rawValue)

        let signUpButton = app.segmentedControls.buttons["Sign Up"]
        XCTAssert(signUpButton.isHittable)
        signUpButton.tap()

        XCTAssertTrue(loginStartButton.label == Identifier.signUpButtonLabel.rawValue)

    }

    func testCreateToDo() {
        signInHelper()
        XCTAssert(addToDoButton.isHittable)
        addToDoButton.tap()

        XCTAssert(addTitleTextField.isHittable)
        addTitleTextField.tap()
        addTitleTextField.typeText(titleTextEntry)
        XCTAssertTrue(addTitleTextField.value as? String == titleTextEntry)

        XCTAssert(addDetailTextView.isHittable)
        addDetailTextView.tap()
        addDetailTextView.typeText(detailTextEntry)
        XCTAssertTrue(addDetailTextView.value as? String == detailTextEntry)

        let point = CGPoint(x: 100, y: 100)
        app.tapCoordinate(at: point)

        XCTAssert(saveToDoButton.isHittable)
        saveToDoButton.tap()
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

extension XCUIApplication {
    func tapCoordinate(at point: CGPoint) {
        let normalized = coordinate(withNormalizedOffset: .zero)
        let offset = CGVector(dx: point.x, dy: point.y)
        let coordinate = normalized.withOffset(offset)
        coordinate.tap()
    }
}
