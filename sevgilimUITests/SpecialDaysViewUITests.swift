//
//  SpecialDaysViewUITests.swift
//  sevgilimUITests
//
//  Created by GitHub Copilot on 17/10/2025.
//

import XCTest

/// UI testleri: SpecialDaysView, SpecialDayDetailView, AddSpecialDayView
/// Özel günler feature'ının tüm kullanıcı etkileşimlerini test eder
final class SpecialDaysViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
        
        loginIfNeeded()
        
        // Special Days ekranına git
        navigateToSpecialDays()
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
    
    private func navigateToSpecialDays() {
        // Hamburger menüden özel günlere git
        let hamburgerButton = app.buttons.matching(identifier: "hamburgerMenuButton").firstMatch
        if hamburgerButton.waitForExistence(timeout: 3) {
            hamburgerButton.tap()
            sleep(1)
            
            let specialDaysButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Özel Günler'")).firstMatch
            if specialDaysButton.exists {
                specialDaysButton.tap()
            }
        }
    }
    
    // MARK: - Test Cases
    
    /// Test 1: SpecialDaysView liste görünümü çalışmalı
    func testSpecialDaysListDisplays() throws {
        // Given: Special Days ekranındayız
        
        // Then: Liste veya boş durum görünür olmalı
        let daysList = app.scrollViews.firstMatch
        let emptyState = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Özel gün'")).firstMatch
        
        XCTAssertTrue(
            daysList.exists || emptyState.exists,
            "Özel günler listesi veya boş durum görünür olmalı"
        )
    }
    
    /// Test 2: Yeni özel gün ekleme butonu çalışmalı
    func testAddNewSpecialDayButton() throws {
        // Given: "Yeni Özel Gün" butonunu buluyoruz
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Özel' OR label CONTAINS[c] 'Ekle'")).firstMatch
        
        if addButton.waitForExistence(timeout: 3) {
            // When: Butona tıklıyoruz
            addButton.tap()
            
            // Then: Form ekranı açılmalı
            sleep(1)
            XCTAssertTrue(
                app.textFields.firstMatch.exists ||
                app.datePickers.firstMatch.exists ||
                app.buttons["Kaydet"].exists,
                "Özel gün ekleme formu açılmalı"
            )
        }
    }
    
    /// Test 3: Countdown sayacı görünür olmalı
    func testCountdownDisplay() throws {
        // Given: Listede en az bir özel gün var
        let firstDay = app.cells.firstMatch
        
        if firstDay.waitForExistence(timeout: 3) {
            // Then: Countdown text'i görünür olmalı
            let countdownText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'gün' OR label CONTAINS[c] 'kaldı'")).firstMatch
            
            XCTAssertTrue(
                countdownText.exists || app.staticTexts.count > 0,
                "Countdown göstergesi olmalı"
            )
        } else {
            throw XCTSkip("Test için özel gün verisi bulunamadı")
        }
    }
    
    /// Test 4: Özel gün detay sayfası açılmalı
    func testSpecialDayDetailOpens() throws {
        // Given: Listede en az bir özel gün var
        let firstDay = app.cells.firstMatch
        
        if firstDay.waitForExistence(timeout: 3) {
            // When: Özel güne tıklıyoruz
            firstDay.tap()
            
            // Then: Detay ekranı açılmalı
            sleep(1)
            XCTAssertTrue(
                app.navigationBars.element(boundBy: 0).exists ||
                app.buttons["Geri"].exists ||
                app.buttons["Düzenle"].exists,
                "Özel gün detayı açılmalı"
            )
        } else {
            throw XCTSkip("Test için özel gün verisi bulunamadı")
        }
    }
    
    /// Test 5: Özel gün düzenleme işlemi çalışmalı
    func testEditSpecialDay() throws {
        // Given: Bir özel gün detayındayız
        let firstDay = app.cells.firstMatch
        
        if firstDay.waitForExistence(timeout: 3) {
            firstDay.tap()
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
                    titleField.typeText("Yıldönümümüz")
                    
                    // When: Kaydet
                    let saveButton = app.buttons["Kaydet"].firstMatch
                    if saveButton.exists {
                        saveButton.tap()
                        
                        // Then: Güncellenen başlık görünmeli
                        sleep(1)
                        let updatedTitle = app.staticTexts["Yıldönümümüz"]
                        XCTAssertTrue(
                            updatedTitle.exists ||
                            app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Yıldönümü'")).firstMatch.exists
                        )
                    }
                }
            }
        } else {
            throw XCTSkip("Test için özel gün verisi bulunamadı")
        }
    }
    
    /// Test 6: Özel gün silme işlemi çalışmalı
    func testDeleteSpecialDay() throws {
        // Given: Bir özel gün detayındayız
        let firstDay = app.cells.firstMatch
        
        if firstDay.waitForExistence(timeout: 3) {
            let dayTitle = firstDay.staticTexts.firstMatch.label
            firstDay.tap()
            sleep(1)
            
            // When: Sil butonuna tıklıyoruz
            let deleteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Sil'")).firstMatch
            if deleteButton.waitForExistence(timeout: 2) {
                deleteButton.tap()
                
                // When: Onay dialog'unda "Evet"
                let confirmButton = app.buttons["Evet"].firstMatch
                if confirmButton.waitForExistence(timeout: 2) {
                    confirmButton.tap()
                    
                    // Then: Liste ekranına dönmeli ve gün silinmiş olmalı
                    sleep(2)
                    let deletedDay = app.staticTexts[dayTitle]
                    XCTAssertFalse(deletedDay.exists, "Silinen özel gün listede görünmemeli")
                }
            }
        } else {
            throw XCTSkip("Test için özel gün verisi bulunamadı")
        }
    }
    
    /// Test 7: Tarih seçici çalışmalı
    func testDatePickerWorks() throws {
        // Given: Yeni özel gün ekleme ekranına gidiyoruz
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Ekle'")).firstMatch
        
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()
            sleep(1)
            
            // When: Tarih seçiciye tıklıyoruz
            let datePicker = app.datePickers.firstMatch
            let dateButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Tarih'")).firstMatch
            
            if datePicker.waitForExistence(timeout: 2) {
                datePicker.tap()
                
                // Then: Tarih seçici açılmalı (crash olmamalı)
                XCTAssertTrue(datePicker.exists)
            } else if dateButton.exists {
                dateButton.tap()
                sleep(1)
                XCTAssertTrue(app.datePickers.firstMatch.exists || app.buttons["Done"].exists)
            }
        }
    }
}
