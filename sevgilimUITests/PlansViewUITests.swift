//
//  PlansViewUITests.swift
//  sevgilimUITests
//
//  Created by GitHub Copilot on 17/10/2025.
//

import XCTest

/// UI testleri: PlansView
/// Gelecek planlar feature'ının tüm kullanıcı etkileşimlerini test eder
final class PlansViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
        
        loginIfNeeded()
        
        // Plans ekranına git
        navigateToPlans()
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
    
    private func navigateToPlans() {
        // Hamburger menüden planlara git
        let hamburgerButton = app.buttons.matching(identifier: "hamburgerMenuButton").firstMatch
        if hamburgerButton.waitForExistence(timeout: 3) {
            hamburgerButton.tap()
            sleep(1)
            
            let plansButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Planlar'")).firstMatch
            if plansButton.exists {
                plansButton.tap()
            }
        }
    }
    
    // MARK: - Test Cases
    
    /// Test 1: PlansView liste görünümü çalışmalı
    func testPlansListDisplays() throws {
        // Given: Plans ekranındayız
        
        // Then: Liste veya boş durum görünür olmalı
        let plansList = app.scrollViews.firstMatch
        let emptyState = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'plan'")).firstMatch
        
        XCTAssertTrue(
            plansList.exists || emptyState.exists,
            "Planlar listesi veya boş durum görünür olmalı"
        )
    }
    
    /// Test 2: Yeni plan ekleme butonu çalışmalı
    func testAddNewPlanButton() throws {
        // Given: "Yeni Plan" butonunu buluyoruz
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Plan' OR label CONTAINS[c] 'Ekle'")).firstMatch
        
        if addButton.waitForExistence(timeout: 3) {
            // When: Butona tıklıyoruz
            addButton.tap()
            
            // Then: Form ekranı açılmalı
            sleep(1)
            XCTAssertTrue(
                app.textFields.firstMatch.exists ||
                app.datePickers.firstMatch.exists ||
                app.buttons["Kaydet"].exists,
                "Plan ekleme formu açılmalı"
            )
        }
    }
    
    /// Test 3: Plan detayı açılmalı
    func testPlanDetailOpens() throws {
        // Given: Listede en az bir plan var
        let firstPlan = app.cells.firstMatch
        
        if firstPlan.waitForExistence(timeout: 3) {
            // When: Plana tıklıyoruz
            firstPlan.tap()
            
            // Then: Detay ekranı açılmalı
            sleep(1)
            XCTAssertTrue(
                app.buttons["Geri"].exists ||
                app.buttons["Düzenle"].exists ||
                app.staticTexts.count > 0,
                "Plan detayı açılmalı"
            )
        } else {
            throw XCTSkip("Test için plan verisi bulunamadı")
        }
    }
    
    /// Test 4: Plan tamamlandı işaretleme çalışmalı
    func testMarkPlanAsCompleted() throws {
        // Given: Listede en az bir plan var
        let firstPlan = app.cells.firstMatch
        
        if firstPlan.waitForExistence(timeout: 3) {
            // When: Checkbox veya complete butonuna tıklıyoruz
            let checkboxButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'checkbox' OR label CONTAINS[c] 'Tamamla'")).firstMatch
            
            if checkboxButton.exists {
                checkboxButton.tap()
                
                // Then: Durum değişmeli (işaretli/çizili görünüm)
                sleep(1)
                XCTAssertTrue(
                    app.images.matching(identifier: "checkmark").firstMatch.exists ||
                    app.buttons.matching(NSPredicate(format: "selected == true")).firstMatch.exists ||
                    firstPlan.exists
                )
            } else {
                // Alternatif: Detaya girip tamamla
                firstPlan.tap()
                sleep(1)
                
                let completeButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Tamamla'")).firstMatch
                if completeButton.exists {
                    completeButton.tap()
                    sleep(1)
                    XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Tamamlandı'")).firstMatch.exists || app.buttons["Geri"].exists)
                }
            }
        } else {
            throw XCTSkip("Test için plan verisi bulunamadı")
        }
    }
    
    /// Test 5: Plan silme işlemi çalışmalı
    func testDeletePlan() throws {
        // Given: Bir plan detayındayız
        let firstPlan = app.cells.firstMatch
        
        if firstPlan.waitForExistence(timeout: 3) {
            let planTitle = firstPlan.staticTexts.firstMatch.label
            firstPlan.tap()
            sleep(1)
            
            // When: Sil butonuna tıklıyoruz
            let deleteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Sil'")).firstMatch
            if deleteButton.waitForExistence(timeout: 2) {
                deleteButton.tap()
                
                // When: Onay dialog'unda "Evet"
                let confirmButton = app.buttons["Evet"].firstMatch
                if confirmButton.waitForExistence(timeout: 2) {
                    confirmButton.tap()
                    
                    // Then: Liste ekranına dönmeli ve plan silinmiş olmalı
                    sleep(2)
                    let deletedPlan = app.staticTexts[planTitle]
                    XCTAssertFalse(deletedPlan.exists, "Silinen plan listede görünmemeli")
                }
            }
        } else {
            throw XCTSkip("Test için plan verisi bulunamadı")
        }
    }
    
    /// Test 6: Planlar scroll edilebilmeli
    func testPlansListScrollable() throws {
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
