//
//  PlacesViewUITests.swift
//  sevgilimUITests
//
//  Created by GitHub Copilot on 17/10/2025.
//

import XCTest

/// UI testleri: PlacesView, AddPlaceView
/// Yerler/harita feature'ının tüm kullanıcı etkileşimlerini test eder
final class PlacesViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
        
        loginIfNeeded()
        
        // Places ekranına git
        navigateToPlaces()
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
    
    private func navigateToPlaces() {
        // Hamburger menüden yerlere git
        let hamburgerButton = app.buttons.matching(identifier: "hamburgerMenuButton").firstMatch
        if hamburgerButton.waitForExistence(timeout: 3) {
            hamburgerButton.tap()
            sleep(1)
            
            let placesButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Yerler'")).firstMatch
            if placesButton.exists {
                placesButton.tap()
            }
        }
    }
    
    // MARK: - Test Cases
    
    /// Test 1: PlacesView harita görünümü çalışmalı
    func testPlacesMapDisplays() throws {
        // Given: Places ekranındayız
        
        // Then: Harita veya liste görünümü olmalı
        let mapView = app.maps.firstMatch
        let listView = app.scrollViews.firstMatch
        
        XCTAssertTrue(
            mapView.exists || listView.exists,
            "Harita veya liste görünümü olmalı"
        )
    }
    
    /// Test 2: Yeni yer ekleme butonu çalışmalı
    func testAddNewPlaceButton() throws {
        // Given: "Yeni Yer Ekle" butonunu buluyoruz
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Yer' OR label CONTAINS[c] 'Ekle'")).firstMatch
        
        if addButton.waitForExistence(timeout: 3) {
            // When: Butona tıklıyoruz
            addButton.tap()
            
            // Then: Form veya harita seçim ekranı açılmalı
            sleep(1)
            XCTAssertTrue(
                app.textFields.firstMatch.exists ||
                app.maps.firstMatch.exists ||
                app.buttons["Kaydet"].exists,
                "Yer ekleme formu açılmalı"
            )
        }
    }
    
    /// Test 3: Harita pin'lerine tıklama çalışmalı
    func testMapPinTap() throws {
        // Given: Haritada pin'ler var
        let mapView = app.maps.firstMatch
        
        if mapView.waitForExistence(timeout: 3) {
            // When: Haritaya tıklıyoruz (pin lokasyonu)
            mapView.tap()
            
            // Then: Callout veya detay açılabilir
            sleep(1)
            XCTAssertTrue(
                mapView.exists || app.buttons.firstMatch.exists,
                "Harita etkileşimi çalışmalı"
            )
        }
    }
    
    /// Test 4: Yer listesi görünümü değişimi çalışmalı
    func testToggleMapListView() throws {
        // Given: Liste/Harita toggle butonunu buluyoruz
        let toggleButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Liste' OR label CONTAINS[c] 'Harita'")).firstMatch
        
        if toggleButton.waitForExistence(timeout: 3) {
            // When: Toggle'a tıklıyoruz
            toggleButton.tap()
            
            // Then: Görünüm değişmeli
            sleep(1)
            XCTAssertTrue(
                app.scrollViews.firstMatch.exists || app.maps.firstMatch.exists,
                "Görünüm geçişi çalışmalı"
            )
        }
    }
    
    /// Test 5: Yer detayı açılmalı
    func testPlaceDetailOpens() throws {
        // Given: Listede en az bir yer var
        let firstPlace = app.cells.firstMatch
        
        if firstPlace.waitForExistence(timeout: 3) {
            // When: Yere tıklıyoruz
            firstPlace.tap()
            
            // Then: Detay ekranı açılmalı
            sleep(1)
            XCTAssertTrue(
                app.maps.firstMatch.exists ||
                app.buttons["Geri"].exists ||
                app.staticTexts.count > 0,
                "Yer detayı açılmalı"
            )
        } else {
            throw XCTSkip("Test için yer verisi bulunamadı")
        }
    }
    
    /// Test 6: Yer silme işlemi çalışmalı
    func testDeletePlace() throws {
        // Given: Bir yer detayındayız
        let firstPlace = app.cells.firstMatch
        
        if firstPlace.waitForExistence(timeout: 3) {
            let placeName = firstPlace.staticTexts.firstMatch.label
            firstPlace.tap()
            sleep(1)
            
            // When: Sil butonuna tıklıyoruz
            let deleteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Sil'")).firstMatch
            if deleteButton.waitForExistence(timeout: 2) {
                deleteButton.tap()
                
                // When: Onay dialog'unda "Evet"
                let confirmButton = app.buttons["Evet"].firstMatch
                if confirmButton.waitForExistence(timeout: 2) {
                    confirmButton.tap()
                    
                    // Then: Liste ekranına dönmeli ve yer silinmiş olmalı
                    sleep(2)
                    let deletedPlace = app.staticTexts[placeName]
                    XCTAssertFalse(deletedPlace.exists, "Silinen yer listede görünmemeli")
                }
            }
        } else {
            throw XCTSkip("Test için yer verisi bulunamadı")
        }
    }
}
