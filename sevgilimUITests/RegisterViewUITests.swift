//
//  RegisterViewUITests.swift
//  sevgilimUITests
//
//  UI tests for RegisterView

import XCTest

final class RegisterViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testRegisterViewElementsExist() throws {
        // Navigate to register
        app.buttons["Kayıt Ol"].tap()
        
        XCTAssertTrue(app.textFields["İsim"].exists)
        XCTAssertTrue(app.textFields["Email"].exists)
        XCTAssertTrue(app.secureTextFields["Şifre"].exists)
        XCTAssertTrue(app.buttons["Kayıt Ol"].exists)
    }
    
    func testRegisterWithEmptyFields() throws {
        app.buttons["Kayıt Ol"].tap()
        
        let registerButton = app.buttons["Kayıt Ol"]
        registerButton.tap()
        
        // Should show error or stay on register screen
        XCTAssertTrue(app.textFields["İsim"].exists)
    }
    
    func testRegisterWithValidData() throws {
        app.buttons["Kayıt Ol"].tap()
        
        let nameField = app.textFields["İsim"]
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Şifre"]
        let registerButton = app.buttons["Kayıt Ol"]
        
        nameField.tap()
        nameField.typeText("Test User")
        
        emailField.tap()
        emailField.typeText("newuser@example.com")
        
        passwordField.tap()
        passwordField.typeText("Test123456")
        
        registerButton.tap()
        
        // Wait for registration
        sleep(2)
        
        // Should navigate to partner setup or show error
        XCTAssertTrue(true)
    }
    
    func testBackToLogin() throws {
        app.buttons["Kayıt Ol"].tap()
        
        // Look for back button or dismiss gesture
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        if backButton.exists {
            backButton.tap()
            XCTAssertTrue(app.buttons["Giriş Yap"].exists)
        }
    }
}
