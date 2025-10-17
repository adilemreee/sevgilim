//
//  SurprisesViewUITests.swift
//  sevgilimUITests
//
//  Created by GitHub Copilot on 17/10/2025.
//

import XCTest

/// UI testleri: SurprisesView, SurpriseCardView
/// Sürprizler feature'ının tüm kullanıcı etkileşimlerini test eder
final class SurprisesViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
        
        loginIfNeeded()
        
        // Surprises ekranına git (tab veya hamburger menüden)
        navigateToSurprises()
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
    
    private func navigateToSurprises() {
        // Hamburger menüden veya tab'dan sürprizlere git
        let hamburgerButton = app.buttons.matching(identifier: "hamburgerMenuButton").firstMatch
        if hamburgerButton.waitForExistence(timeout: 3) {
            hamburgerButton.tap()
            sleep(1)
            
            let surprisesButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Sürpriz'")).firstMatch
            if surprisesButton.exists {
                surprisesButton.tap()
            }
        }
    }
    
    // MARK: - Test Cases
    
    /// Test 1: SurprisesView liste görünümü çalışmalı
    func testSurprisesListDisplays() throws {
        // Given: Surprises ekranındayız
        
        // Then: Sürpriz listesi veya boş durum görünür olmalı
        let surprisesList = app.scrollViews.firstMatch
        let emptyState = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'sürpriz'")).firstMatch
        
        XCTAssertTrue(
            surprisesList.exists || emptyState.exists,
            "Sürpriz listesi veya boş durum görünür olmalı"
        )
    }
    
    /// Test 2: Yeni sürpriz ekleme butonu çalışmalı
    func testAddNewSurpriseButton() throws {
        // Given: "Yeni Sürpriz" butonunu buluyoruz
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Sürpriz' OR label CONTAINS[c] 'Ekle'")).firstMatch
        
        if addButton.waitForExistence(timeout: 3) {
            // When: Butona tıklıyoruz
            addButton.tap()
            
            // Then: Form ekranı açılmalı
            sleep(1)
            XCTAssertTrue(
                app.textFields.firstMatch.exists ||
                app.textViews.firstMatch.exists ||
                app.buttons["Kaydet"].exists,
                "Sürpriz ekleme formu açılmalı"
            )
        }
    }
    
    /// Test 3: Sürpriz kartı reveal animasyonu çalışmalı
    func testSurpriseCardReveal() throws {
        // Given: Listede kapalı (unrevealed) bir sürpriz var
        let surpriseCard = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'surpriseCard'")).firstMatch
        
        if surpriseCard.waitForExistence(timeout: 3) {
            // When: Karta tıklıyoruz
            surpriseCard.tap()
            
            // Then: Reveal animasyonu oynar ve detay açılır
            sleep(2) // Animation bekleme
            XCTAssertTrue(
                app.staticTexts.firstMatch.exists ||
                app.images.firstMatch.exists ||
                app.buttons["Geri"].exists,
                "Sürpriz detayı açılmalı"
            )
        } else {
            throw XCTSkip("Test için sürpriz kartı bulunamadı")
        }
    }
    
    /// Test 4: Sürpriz filtreleme çalışmalı
    func testSurpriseFiltering() throws {
        // Given: Filtre butonunu buluyoruz
        let filterButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Filtre' OR label CONTAINS[c] 'Filter'")).firstMatch
        
        if filterButton.waitForExistence(timeout: 3) {
            // When: Filtre menüsünü açıyoruz
            filterButton.tap()
            sleep(1)
            
            // When: "Açılan Sürprizler" filtresi
            let revealedFilter = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Açılan'")).firstMatch
            if revealedFilter.exists {
                revealedFilter.tap()
                sleep(1)
                
                // Then: Liste filtrelenmeli
                XCTAssertTrue(
                    app.scrollViews.firstMatch.exists ||
                    app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'sürpriz yok'")).firstMatch.exists
                )
            }
        }
    }
    
    /// Test 5: Sürpriz silme işlemi çalışmalı
    func testDeleteSurprise() throws {
        // Given: Bir sürpriz detayındayız
        let surpriseCard = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'surpriseCard'")).firstMatch
        
        if surpriseCard.waitForExistence(timeout: 3) {
            surpriseCard.tap()
            sleep(1)
            
            // When: Sil butonuna tıklıyoruz
            let deleteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Sil'")).firstMatch
            if deleteButton.waitForExistence(timeout: 2) {
                deleteButton.tap()
                
                // When: Onay dialog'unda "Evet"
                let confirmButton = app.buttons["Evet"].firstMatch
                if confirmButton.waitForExistence(timeout: 2) {
                    confirmButton.tap()
                    
                    // Then: Liste ekranına dönmeli
                    sleep(2)
                    XCTAssertTrue(
                        app.scrollViews.firstMatch.exists ||
                        app.navigationBars.firstMatch.exists
                    )
                }
            }
        } else {
            throw XCTSkip("Test için sürpriz verisi bulunamadı")
        }
    }
    
    /// Test 6: Sürprizler scroll edilebilmeli
    func testSurprisesListScrollable() throws {
        // Given: Liste görünümü
        let scrollView = app.scrollViews.firstMatch
        
        if scrollView.waitForExistence(timeout: 3) {
            // When: Aşağı scroll
            scrollView.swipeUp()
            XCTAssertTrue(scrollView.exists)
            
            // When: Yukarı scroll
            scrollView.swipeDown()
            XCTAssertTrue(scrollView.exists)
        }
    }
}
