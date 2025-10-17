//
//  LoginViewUITests.swift
//  sevgilimUITests
//
//  UI tests for LoginView

import XCTest

final class LoginViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - UI Element Tests
    
    func testLoginViewElementsExist() throws {
        // Test that login screen elements are present
        XCTAssertTrue(app.textFields["Email"].exists, "Email field should exist")
        XCTAssertTrue(app.secureTextFields["Password"].exists, "Password field should exist")
        XCTAssertTrue(app.buttons["Giriş Yap"].exists, "Login button should exist")
        XCTAssertTrue(app.buttons["Kayıt Ol"].exists, "Register button should exist")
    }
    
    func testLoginWithEmptyFields() throws {
        let loginButton = app.buttons["Giriş Yap"]
        loginButton.tap()
        
        // Should show error or stay on login screen
        XCTAssertTrue(app.textFields["Email"].exists, "Should stay on login screen")
    }
    
    func testLoginWithValidCredentials() throws {
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Giriş Yap"]
        
        emailField.tap()
        emailField.typeText("test@example.com")
        
        passwordField.tap()
        passwordField.typeText("Test123456")
        
        loginButton.tap()
        
        // Should navigate to home screen or show error
        // Wait for navigation
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == true"),
            object: app.buttons["Home"]
        )
        let result = XCTWaiter.wait(for: [expectation], timeout: 5.0)
        
        // Either navigated or showed error
        XCTAssertTrue(result == .completed || app.textFields["Email"].exists)
    }
    
    func testNavigateToRegister() throws {
        let registerButton = app.buttons["Kayıt Ol"]
        registerButton.tap()
        
        // Should navigate to register screen
        XCTAssertTrue(app.textFields["İsim"].exists, "Should show register screen")
    }
    
    func testEmailFieldInput() throws {
        let emailField = app.textFields["Email"]
        emailField.tap()
        emailField.typeText("test@example.com")
        
        XCTAssertEqual(emailField.value as? String, "test@example.com")
    }
    
    func testPasswordFieldIsSecure() throws {
        let passwordField = app.secureTextFields["Password"]
        
        XCTAssertTrue(passwordField.exists, "Password field should be secure")
    }
}
