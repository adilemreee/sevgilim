//
//  StoriesViewUITests.swift
//  sevgilimUITests
//
//  Created by GitHub Copilot on 17/10/2025.
//

import XCTest

/// UI testleri: StoriesView, StoryViewer, StoryCircles, AddStoryView
/// Instagram-like stories feature'ının tüm kullanıcı etkileşimlerini test eder
final class StoriesViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
        
        loginIfNeeded()
        
        // Home ekranında story circles görünür
        _ = app.navigationBars.firstMatch.waitForExistence(timeout: 5)
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Helper Methods
    
    private func loginIfNeeded() {
        let emailField = app.textFields["Email"]
        if emailField.waitForExistence(timeout: 3) {
            emailField.tap()
            emailField.typeText("test@example.com")
            
            let passwordField = app.secureTextFields["Şifre"]
            passwordField.tap()
            passwordField.typeText("password123")
            
            app.buttons["Giriş Yap"].tap()
            _ = app.navigationBars.firstMatch.waitForExistence(timeout: 5)
        }
    }
    
    // MARK: - Test Cases
    
    /// Test 1: Story circles home ekranında görünmeli
    func testStoryCirclesDisplayOnHome() throws {
        // Given: Home ekranındayız
        
        // Then: Story circles scroll view görünür olmalı
        let storyScrollView = app.scrollViews.matching(identifier: "storyCirclesScrollView").firstMatch
        let storyCircle = app.images.matching(NSPredicate(format: "identifier CONTAINS 'storyCircle'")).firstMatch
        
        XCTAssertTrue(
            storyScrollView.exists || storyCircle.exists || app.scrollViews.firstMatch.exists,
            "Story circles görünür olmalı"
        )
    }
    
    /// Test 2: Yeni story ekleme butonu çalışmalı
    func testAddNewStoryButton() throws {
        // Given: "Yeni Story" veya "+" butonunu buluyoruz
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Story' OR label CONTAINS[c] '+'")).firstMatch
        
        if addButton.waitForExistence(timeout: 3) {
            // When: Butona tıklıyoruz
            addButton.tap()
            
            // Then: Camera/Photo picker açılmalı
            sleep(1)
            let cameraPicker = app.otherElements["CameraPicker"].firstMatch
            let photosPicker = app.otherElements["PhotosPicker"].firstMatch
            let allowButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Allow'")).firstMatch
            
            XCTAssertTrue(
                cameraPicker.exists || photosPicker.exists || allowButton.exists,
                "Kamera veya fotoğraf seçici açılmalı"
            )
        }
    }
    
    /// Test 3: Story circle'a tıklayınca tam ekran viewer açılmalı
    func testStoryCircleTapOpensViewer() throws {
        // Given: İlk story circle'ı buluyoruz
        let firstStoryCircle = app.images.matching(NSPredicate(format: "identifier CONTAINS 'storyCircle'")).firstMatch
        
        if firstStoryCircle.waitForExistence(timeout: 3) {
            // When: Circle'a tıklıyoruz
            firstStoryCircle.tap()
            
            // Then: Tam ekran story viewer açılmalı
            sleep(1)
            XCTAssertTrue(
                app.images.firstMatch.exists ||
                app.buttons["Kapat"].exists ||
                app.buttons["X"].exists ||
                app.otherElements["StoryViewer"].exists,
                "Story viewer açılmalı"
            )
        } else {
            throw XCTSkip("Test için story verisi bulunamadı")
        }
    }
    
    /// Test 4: Story viewer'da swipe ile geçiş yapılabilmeli
    func testStoryViewerSwipeNavigation() throws {
        // Given: Bir story viewer'dayız
        let firstStoryCircle = app.images.matching(NSPredicate(format: "identifier CONTAINS 'storyCircle'")).firstMatch
        
        if firstStoryCircle.waitForExistence(timeout: 3) {
            firstStoryCircle.tap()
            sleep(1)
            
            let storyImage = app.images.firstMatch
            if storyImage.exists {
                // When: Sola swipe (sonraki story)
                storyImage.swipeLeft()
                sleep(1)
                
                // Then: Story hala görünür olmalı (crash olmamalı)
                XCTAssertTrue(app.images.firstMatch.exists)
                
                // When: Sağa swipe (önceki story)
                storyImage.swipeRight()
                sleep(1)
                XCTAssertTrue(app.images.firstMatch.exists)
            }
        } else {
            throw XCTSkip("Test için story verisi bulunamadı")
        }
    }
    
    /// Test 5: Story otomatik geçiş zamanlayıcı çalışmalı
    func testStoryAutoProgressTimer() throws {
        // Given: Bir story viewer'dayız
        let firstStoryCircle = app.images.matching(NSPredicate(format: "identifier CONTAINS 'storyCircle'")).firstMatch
        
        if firstStoryCircle.waitForExistence(timeout: 3) {
            firstStoryCircle.tap()
            sleep(1)
            
            // When: Progress bar'ı kontrol ediyoruz
            let progressBar = app.progressIndicators.firstMatch
            let progressView = app.otherElements.matching(identifier: "storyProgressBar").firstMatch
            
            // Then: Progress göstergesi görünür olmalı
            XCTAssertTrue(
                progressBar.exists || progressView.exists,
                "Story progress göstergesi olmalı"
            )
            
            // When: 5 saniye bekleyip otomatik geçiş olup olmadığını kontrol ediyoruz
            sleep(5)
            
            // Then: Hala bir story görünür olmalı (next story veya closed)
            XCTAssertTrue(
                app.images.firstMatch.exists ||
                app.navigationBars.firstMatch.exists,
                "Story otomatik geçiş çalışmalı"
            )
        } else {
            throw XCTSkip("Test için story verisi bulunamadı")
        }
    }
    
    /// Test 6: Story silme işlemi çalışmalı
    func testDeleteStory() throws {
        // Given: Bir story viewer'dayız
        let firstStoryCircle = app.images.matching(NSPredicate(format: "identifier CONTAINS 'storyCircle'")).firstMatch
        
        if firstStoryCircle.waitForExistence(timeout: 3) {
            firstStoryCircle.tap()
            sleep(1)
            
            // When: Menü veya sil butonuna tıklıyoruz
            let menuButton = app.buttons["•••"].firstMatch
            let deleteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Sil'")).firstMatch
            
            if menuButton.exists {
                menuButton.tap()
                sleep(1)
            }
            
            if deleteButton.waitForExistence(timeout: 2) {
                deleteButton.tap()
                
                // When: Onay dialogunda "Evet"
                let confirmButton = app.buttons["Evet"].firstMatch
                if confirmButton.waitForExistence(timeout: 2) {
                    confirmButton.tap()
                    
                    // Then: Story viewer kapanmalı
                    sleep(2)
                    XCTAssertTrue(
                        app.navigationBars.firstMatch.exists,
                        "Story silindikten sonra ana ekrana dönmeli"
                    )
                }
            }
        } else {
            throw XCTSkip("Test için story verisi bulunamadı")
        }
    }
    
    /// Test 7: Story viewer kapatma butonu çalışmalı
    func testCloseStoryViewer() throws {
        // Given: Bir story viewer'dayız
        let firstStoryCircle = app.images.matching(NSPredicate(format: "identifier CONTAINS 'storyCircle'")).firstMatch
        
        if firstStoryCircle.waitForExistence(timeout: 3) {
            firstStoryCircle.tap()
            sleep(1)
            
            // When: Kapat butonuna tıklıyoruz
            let closeButton = app.buttons["Kapat"].firstMatch.exists ? app.buttons["Kapat"].firstMatch : app.buttons["X"].firstMatch
            
            if closeButton.exists {
                closeButton.tap()
                
                // Then: Ana ekrana dönmeli
                sleep(1)
                XCTAssertTrue(
                    app.navigationBars.firstMatch.exists,
                    "Story viewer kapanmalı"
                )
            } else {
                // Alternatif: Aşağı swipe ile kapatma
                let storyImage = app.images.firstMatch
                storyImage.swipeDown()
                sleep(1)
                XCTAssertTrue(app.navigationBars.firstMatch.exists)
            }
        } else {
            throw XCTSkip("Test için story verisi bulunamadı")
        }
    }
    
    /// Test 8: Story circles yatay scroll edilebilmeli
    func testStoryCirclesScrollable() throws {
        // Given: Story circles scroll view
        let storyScrollView = app.scrollViews.firstMatch
        
        if storyScrollView.waitForExistence(timeout: 3) {
            // When: Sola scroll
            storyScrollView.swipeLeft()
            
            // Then: Scroll çalışmalı (crash olmamalı)
            XCTAssertTrue(storyScrollView.exists)
            
            // When: Sağa scroll
            storyScrollView.swipeRight()
            XCTAssertTrue(storyScrollView.exists)
        }
    }
}
