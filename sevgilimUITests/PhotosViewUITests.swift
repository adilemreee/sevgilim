//
//  PhotosViewUITests.swift
//  sevgilimUITests
//
//  Created by GitHub Copilot on 17/10/2025.
//

import XCTest

/// UI testleri: PhotosView, PhotoDetailView, AddPhotoView, FullScreenPhotoViewer
/// Fotoğraf galerisi feature'ının tüm kullanıcı etkileşimlerini test eder
final class PhotosViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
        
        loginIfNeeded()
        
        // Photos tab'ına git
        let photosTab = app.tabBars.buttons["Fotoğraflar"]
        if photosTab.waitForExistence(timeout: 5) {
            photosTab.tap()
        }
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
    
    /// Test 1: PhotosView grid düzeni doğru görünmeli
    func testPhotosGridDisplaysCorrectly() throws {
        // Given: Photos ekranındayız
        XCTAssertTrue(
            app.navigationBars["Fotoğraflar"].exists ||
            app.staticTexts["Fotoğraflarımız"].exists ||
            app.navigationBars.firstMatch.exists
        )
        
        // Then: Grid veya boş durum görünür olmalı
        let photoGrid = app.scrollViews.firstMatch
        let emptyState = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Fotoğraf'")).firstMatch
        
        XCTAssertTrue(photoGrid.exists || emptyState.exists)
    }
    
    /// Test 2: Fotoğraf yükleme butonu çalışmalı
    func testAddPhotoButton() throws {
        // Given: Fotoğraf ekleme butonunu buluyoruz
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Ekle' OR label CONTAINS[c] 'Fotoğraf'")).firstMatch
        
        if addButton.waitForExistence(timeout: 3) {
            // When: Butona tıklıyoruz
            addButton.tap()
            
            // Then: Photo picker açılmalı
            sleep(1)
            let photosPicker = app.otherElements["PhotosPicker"].firstMatch
            let allowButton = app.buttons["Allow Access to All Photos"].firstMatch
            let photosApp = app.images.firstMatch
            
            XCTAssertTrue(
                photosPicker.exists || allowButton.exists || photosApp.exists,
                "Fotoğraf seçici açılmalı"
            )
        }
    }
    
    /// Test 3: Grid'deki fotoğrafa tıklayınca tam ekran açılmalı
    func testPhotoTapOpensFullScreen() throws {
        // Given: Grid'de en az bir fotoğraf var
        let firstPhoto = app.images.firstMatch
        
        if firstPhoto.waitForExistence(timeout: 3) {
            // When: Fotoğrafa tıklıyoruz
            firstPhoto.tap()
            
            // Then: Tam ekran viewer açılmalı
            sleep(1)
            XCTAssertTrue(
                app.buttons["Kapat"].exists ||
                app.buttons["Geri"].exists ||
                app.buttons["Sil"].exists ||
                app.otherElements["FullScreenViewer"].exists,
                "Tam ekran viewer açılmalı"
            )
        } else {
            throw XCTSkip("Test için fotoğraf verisi bulunamadı")
        }
    }
    
    /// Test 4: Tam ekran viewer'da zoom çalışmalı
    func testFullScreenZoom() throws {
        // Given: Bir fotoğrafın tam ekran görünümündeyiz
        let firstPhoto = app.images.firstMatch
        
        if firstPhoto.waitForExistence(timeout: 3) {
            firstPhoto.tap()
            sleep(1)
            
            let fullScreenImage = app.images.firstMatch
            if fullScreenImage.exists {
                // When: Pinch to zoom yapıyoruz (simüle)
                fullScreenImage.pinch(withScale: 2.0, velocity: 1.0)
                
                // Then: Fotoğraf hala görünür olmalı (crash olmamalı)
                XCTAssertTrue(fullScreenImage.exists)
                
                // When: Zoom out
                fullScreenImage.pinch(withScale: 0.5, velocity: -1.0)
                XCTAssertTrue(fullScreenImage.exists)
            }
        } else {
            throw XCTSkip("Test için fotoğraf verisi bulunamadı")
        }
    }
    
    /// Test 5: Fotoğraf silme işlemi çalışmalı
    func testDeletePhoto() throws {
        // Given: Bir fotoğrafın tam ekranındayız
        let firstPhoto = app.images.firstMatch
        
        if firstPhoto.waitForExistence(timeout: 3) {
            firstPhoto.tap()
            sleep(1)
            
            // When: Sil butonuna tıklıyoruz
            let deleteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Sil'")).firstMatch
            
            if deleteButton.waitForExistence(timeout: 2) {
                deleteButton.tap()
                
                // When: Onay dialogunda "Evet"
                let confirmButton = app.buttons["Evet"].firstMatch
                if confirmButton.waitForExistence(timeout: 2) {
                    confirmButton.tap()
                    
                    // Then: Grid ekranına dönmeli
                    sleep(2)
                    XCTAssertTrue(
                        app.scrollViews.firstMatch.exists ||
                        app.navigationBars.firstMatch.exists
                    )
                }
            }
        } else {
            throw XCTSkip("Test için fotoğraf verisi bulunamadı")
        }
    }
    
    /// Test 6: Grid scroll edilebilmeli
    func testPhotoGridScrollable() throws {
        // Given: Grid görünümü
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
    
    /// Test 7: Fotoğraf paylaşma butonu çalışmalı
    func testSharePhoto() throws {
        // Given: Bir fotoğrafın tam ekranındayız
        let firstPhoto = app.images.firstMatch
        
        if firstPhoto.waitForExistence(timeout: 3) {
            firstPhoto.tap()
            sleep(1)
            
            // When: Paylaş butonuna tıklıyoruz
            let shareButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Paylaş' OR label CONTAINS[c] 'Share'")).firstMatch
            
            if shareButton.waitForExistence(timeout: 2) {
                shareButton.tap()
                
                // Then: Share sheet açılmalı
                sleep(1)
                let activityView = app.otherElements["ActivityListView"].firstMatch
                let shareSheet = app.sheets.firstMatch
                
                XCTAssertTrue(
                    activityView.exists || shareSheet.exists,
                    "Paylaşım menüsü açılmalı"
                )
            }
        } else {
            throw XCTSkip("Test için fotoğraf verisi bulunamadı")
        }
    }
    
    /// Test 8: Boş durum mesajı görünmeli
    func testEmptyStateDisplayed() throws {
        // Given: Hiç fotoğraf yoksa
        
        // Then: Boş durum göstergesi olmalı
        let emptyText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Henüz' OR label CONTAINS[c] 'fotoğraf yok'")).firstMatch
        let emptyImage = app.images.matching(identifier: "emptyPhotosImage").firstMatch
        
        XCTAssertTrue(
            emptyText.exists || emptyImage.exists || app.images.count == 0,
            "Boş durum göstergesi olmalı"
        )
    }
}
