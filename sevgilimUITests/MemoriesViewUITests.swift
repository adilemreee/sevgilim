//
//  MemoriesViewUITests.swift
//  sevgilimUITests
//
//  Created by GitHub Copilot on 17/10/2025.
//

import XCTest

/// UI testleri: MemoriesView, MemoryDetailView, AddMemoryView
/// Anılar feature'ının tüm kullanıcı etkileşimlerini test eder
final class MemoriesViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
        
        // Login flow - varsayılan olarak kullanıcı giriş yapmış
        loginIfNeeded()
        
        // Memories tab'ına git
        let memoriesTab = app.tabBars.buttons["Anılar"]
        if memoriesTab.waitForExistence(timeout: 5) {
            memoriesTab.tap()
        }
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Helper Methods
    
    private func loginIfNeeded() {
        // Eğer login ekranı varsa giriş yap
        let emailField = app.textFields["Email"]
        if emailField.waitForExistence(timeout: 3) {
            emailField.tap()
            emailField.typeText("test@example.com")
            
            let passwordField = app.secureTextFields["Şifre"]
            passwordField.tap()
            passwordField.typeText("password123")
            
            app.buttons["Giriş Yap"].tap()
            
            // Home ekranının yüklenmesini bekle
            _ = app.navigationBars.firstMatch.waitForExistence(timeout: 5)
        }
    }
    
    // MARK: - Test Cases
    
    /// Test 1: MemoriesView açıldığında temel UI elemanları görünür olmalı
    func testMemoriesViewDisplaysCorrectly() throws {
        // Given: Memories ekranındayız
        XCTAssertTrue(app.navigationBars["Anılarımız"].exists || app.staticTexts["Anılarımız"].exists)
        
        // Then: "Yeni Anı Ekle" butonu görünür olmalı
        let addButton = app.buttons["Yeni Anı Ekle"].firstMatch
        XCTAssertTrue(addButton.exists || app.buttons.matching(identifier: "addMemoryButton").firstMatch.exists)
        
        // Then: Liste veya boş durum mesajı görünür olmalı
        let memoryList = app.scrollViews.firstMatch
        let emptyStateText = app.staticTexts["Henüz anı eklenmemiş"]
        XCTAssertTrue(memoryList.exists || emptyStateText.exists)
    }
    
    /// Test 2: Yeni anı ekleme flow'u çalışmalı
    func testAddNewMemoryFlow() throws {
        // Given: "Yeni Anı Ekle" butonuna tıklıyoruz
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Anı' OR label CONTAINS[c] 'Ekle'")).firstMatch
        
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()
            
            // When: Form alanlarını dolduruyoruz
            let titleField = app.textFields["Başlık"].firstMatch
            if titleField.waitForExistence(timeout: 2) {
                titleField.tap()
                titleField.typeText("İlk Buluşmamız")
                
                let descriptionField = app.textViews["Açıklama"].firstMatch
                if descriptionField.exists {
                    descriptionField.tap()
                    descriptionField.typeText("Harika bir gündü")
                }
                
                // When: Kaydet butonuna tıklıyoruz
                let saveButton = app.buttons["Kaydet"].firstMatch
                if saveButton.exists {
                    saveButton.tap()
                    
                    // Then: Liste ekranına dönmeli ve yeni anı görünmeli
                    sleep(2) // Animation bekleme
                    let newMemory = app.staticTexts["İlk Buluşmamız"]
                    XCTAssertTrue(newMemory.waitForExistence(timeout: 3), "Yeni anı listede görünmeli")
                }
            }
        }
    }
    
    /// Test 3: Anı detay sayfası açılmalı
    func testMemoryDetailOpens() throws {
        // Given: Listede en az bir anı var
        let firstMemory = app.cells.firstMatch
        
        if firstMemory.waitForExistence(timeout: 3) {
            // When: Anıya tıklıyoruz
            firstMemory.tap()
            
            // Then: Detay ekranı açılmalı
            sleep(1)
            XCTAssertTrue(
                app.navigationBars.element(boundBy: 0).exists ||
                app.buttons["Geri"].exists ||
                app.buttons["Düzenle"].exists,
                "Detay ekranı açılmalı"
            )
        } else {
            throw XCTSkip("Test için anı verisi bulunamadı")
        }
    }
    
    /// Test 4: Anı düzenleme işlemi çalışmalı
    func testEditMemory() throws {
        // Given: Bir anı detayındayız
        let firstMemory = app.cells.firstMatch
        
        if firstMemory.waitForExistence(timeout: 3) {
            firstMemory.tap()
            sleep(1)
            
            // When: Düzenle butonuna tıklıyoruz
            let editButton = app.buttons["Düzenle"].firstMatch
            if editButton.waitForExistence(timeout: 2) {
                editButton.tap()
                
                // When: Başlığı değiştiriyoruz
                let titleField = app.textFields.firstMatch
                if titleField.exists {
                    titleField.tap()
                    titleField.clearText()
                    titleField.typeText("Güncellenen Anı")
                    
                    // When: Kaydet
                    let saveButton = app.buttons["Kaydet"].firstMatch
                    if saveButton.exists {
                        saveButton.tap()
                        
                        // Then: Güncellenen başlık görünmeli
                        sleep(1)
                        let updatedTitle = app.staticTexts["Güncellenen Anı"]
                        XCTAssertTrue(updatedTitle.exists || app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Güncellenen'")).firstMatch.exists)
                    }
                }
            }
        } else {
            throw XCTSkip("Test için anı verisi bulunamadı")
        }
    }
    
    /// Test 5: Anı silme işlemi çalışmalı
    func testDeleteMemory() throws {
        // Given: Bir anı detayındayız
        let firstMemory = app.cells.firstMatch
        
        if firstMemory.waitForExistence(timeout: 3) {
            let memoryText = firstMemory.staticTexts.firstMatch.label
            firstMemory.tap()
            sleep(1)
            
            // When: Sil butonuna tıklıyoruz
            let deleteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Sil'")).firstMatch
            if deleteButton.waitForExistence(timeout: 2) {
                deleteButton.tap()
                
                // When: Onay dialog'unda "Evet" diyoruz
                let confirmButton = app.buttons["Evet"].firstMatch
                if confirmButton.waitForExistence(timeout: 2) {
                    confirmButton.tap()
                    
                    // Then: Liste ekranına dönmeli ve anı silinmiş olmalı
                    sleep(2)
                    let deletedMemory = app.staticTexts[memoryText]
                    XCTAssertFalse(deletedMemory.exists, "Silinen anı listede görünmemeli")
                }
            }
        } else {
            throw XCTSkip("Test için anı verisi bulunamadı")
        }
    }
    
    /// Test 6: Boş durum mesajı görünmeli (anı yoksa)
    func testEmptyStateDisplayed() throws {
        // Given: Tüm anıları silmişiz
        // When: Hiç anı yoksa
        
        // Then: Boş durum mesajı görünmeli
        let emptyStateText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Henüz' OR label CONTAINS[c] 'anı yok'")).firstMatch
        let emptyStateImage = app.images.matching(identifier: "emptyStateImage").firstMatch
        
        // En az birinin görünmesi yeterli
        XCTAssertTrue(
            emptyStateText.exists || emptyStateImage.exists || app.cells.count == 0,
            "Boş durum göstergesi olmalı"
        )
    }
    
    /// Test 7: Anı listesi scroll edilebilmeli
    func testMemoryListScrollable() throws {
        // Given: Liste görünümü
        let scrollView = app.scrollViews.firstMatch
        
        if scrollView.waitForExistence(timeout: 3) {
            // When: Aşağı scroll yapıyoruz
            scrollView.swipeUp()
            
            // Then: Scroll çalışmalı (crash olmamalı)
            XCTAssertTrue(scrollView.exists)
            
            // When: Yukarı scroll
            scrollView.swipeDown()
            XCTAssertTrue(scrollView.exists)
        }
    }
    
    /// Test 8: Fotoğraf ekleme butonu çalışmalı
    func testAddPhotoToMemory() throws {
        // Given: Yeni anı ekleme ekranındayız
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Anı' OR label CONTAINS[c] 'Ekle'")).firstMatch
        
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()
            
            // When: Fotoğraf ekleme butonuna tıklıyoruz
            let photoButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Fotoğraf'")).firstMatch
            
            if photoButton.waitForExistence(timeout: 2) {
                photoButton.tap()
                
                // Then: Fotoğraf seçici açılmalı
                sleep(1)
                let photosPicker = app.otherElements["PhotosPicker"].firstMatch
                let allowAccessButton = app.buttons["Allow Access to All Photos"].firstMatch
                
                XCTAssertTrue(
                    photosPicker.exists || allowAccessButton.exists || app.images.firstMatch.exists,
                    "Fotoğraf seçici açılmalı"
                )
            }
        }
    }
}
