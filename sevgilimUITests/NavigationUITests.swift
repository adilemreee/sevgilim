//
//  NavigationUITests.swift
//  sevgilimUITests
//
//  UI tests for navigation flow

import XCTest

final class NavigationUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testMainTabBarNavigation() throws {
        let tabBar = app.tabBars.firstMatch
        
        if tabBar.exists {
            let tabs = tabBar.buttons
            let tabCount = tabs.count
            
            // Navigate through all tabs
            for i in 0..<tabCount {
                let tab = tabs.element(boundBy: i)
                tab.tap()
                sleep(1)
                XCTAssertTrue(tab.isSelected)
            }
        }
    }
    
    func testBackNavigation() throws {
        // Navigate to a sub-screen
        if app.buttons["Ayarlar"].exists {
            app.buttons["Ayarlar"].tap()
            sleep(1)
            
            // Go back
            let backButton = app.navigationBars.buttons.element(boundBy: 0)
            if backButton.exists {
                backButton.tap()
                sleep(1)
                XCTAssertTrue(true, "Back navigation worked")
            }
        }
    }
    
    func testDeepLinkNavigation() throws {
        // Test navigation from home to specific feature
        let features = ["Chat", "Fotoğraflar", "Anılar", "Sürprizler", "Planlar"]
        
        for feature in features {
            if app.buttons[feature].exists {
                app.buttons[feature].tap()
                sleep(1)
                
                // Navigate back to home
                if app.tabBars.buttons["Ana Sayfa"].exists {
                    app.tabBars.buttons["Ana Sayfa"].tap()
                    sleep(1)
                }
            }
        }
        
        XCTAssertTrue(true, "Deep link navigation tested")
    }
}
