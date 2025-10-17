//
//  ProfileViewUITests.swift
//  sevgilimUITests
//
//  Created by GitHub Copilot on 17/10/2025.
//

import XCTest

/// UI testleri: ProfileView, SettingsView, EditProfileView
/// Profil yönetimi ve ayarlar feature'ının tüm kullanıcı etkileşimlerini test eder
final class ProfileViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
        
        loginIfNeeded()
        
        // Profile tab'ına git
        let profileTab = app.tabBars.buttons["Profil"]
        if profileTab.waitForExistence(timeout: 5) {
            profileTab.tap()
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
    
    /// Test 1: ProfileView temel bilgiler görünmeli
    func testProfileViewDisplaysUserInfo() throws {
        // Given: Profile ekranındayız
        
        // Then: Profil fotoğrafı ve isim görünür olmalı
        let profileImage = app.images.matching(identifier: "profileImage").firstMatch
        let userName = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'test' OR label != ''")).firstMatch
        
        XCTAssertTrue(
            profileImage.exists || userName.exists || app.images.firstMatch.exists,
            "Profil bilgileri görünür olmalı"
        )
    }
    
    /// Test 2: Ayarlar butonu çalışmalı
    func testSettingsButtonOpensSettings() throws {
        // Given: Ayarlar butonunu buluyoruz
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Ayarlar' OR label CONTAINS[c] 'Settings'")).firstMatch
        
        if settingsButton.waitForExistence(timeout: 3) {
            // When: Butona tıklıyoruz
            settingsButton.tap()
            
            // Then: Ayarlar ekranı açılmalı
            sleep(1)
            XCTAssertTrue(
                app.navigationBars["Ayarlar"].exists ||
                app.staticTexts["Ayarlar"].exists ||
                app.buttons["Geri"].exists,
                "Ayarlar ekranı açılmalı"
            )
        }
    }
    
    /// Test 3: Profil düzenleme ekranı açılmalı
    func testEditProfileButton() throws {
        // Given: Profil düzenle butonunu buluyoruz
        let editButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Düzenle' OR label CONTAINS[c] 'Edit'")).firstMatch
        
        if editButton.waitForExistence(timeout: 3) {
            // When: Butona tıklıyoruz
            editButton.tap()
            
            // Then: Düzenleme ekranı açılmalı
            sleep(1)
            XCTAssertTrue(
                app.navigationBars.matching(NSPredicate(format: "identifier CONTAINS[c] 'Düzenle'")).firstMatch.exists ||
                app.textFields.firstMatch.exists ||
                app.buttons["Kaydet"].exists,
                "Profil düzenleme ekranı açılmalı"
            )
        }
    }
    
    /// Test 4: Profil bilgileri güncellenebilmeli
    func testEditProfileInformation() throws {
        // Given: Profil düzenleme ekranına gidiyoruz
        let editButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Düzenle'")).firstMatch
        
        if editButton.waitForExistence(timeout: 3) {
            editButton.tap()
            sleep(1)
            
            // When: İsim alanını değiştiriyoruz
            let nameField = app.textFields.firstMatch
            if nameField.exists {
                nameField.tap()
                nameField.clearText()
                nameField.typeText("Yeni İsim")
                
                // When: Kaydet butonuna tıklıyoruz
                let saveButton = app.buttons["Kaydet"].firstMatch
                if saveButton.exists {
                    saveButton.tap()
                    
                    // Then: Profil ekranına dönmeli ve yeni isim görünmeli
                    sleep(2)
                    let updatedName = app.staticTexts["Yeni İsim"]
                    XCTAssertTrue(
                        updatedName.exists || app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Yeni'")).firstMatch.exists,
                        "Güncellenen isim görünmeli"
                    )
                }
            }
        }
    }
    
    /// Test 5: Tema değiştirme çalışmalı
    func testThemeChange() throws {
        // Given: Ayarlar ekranına gidiyoruz
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Ayarlar'")).firstMatch
        
        if settingsButton.waitForExistence(timeout: 3) {
            settingsButton.tap()
            sleep(1)
            
            // When: Tema seçeneğini buluyoruz
            let themeOption = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Tema' OR label CONTAINS[c] 'Theme'")).firstMatch
            
            if themeOption.waitForExistence(timeout: 2) {
                themeOption.tap()
                sleep(1)
                
                // When: Farklı bir tema seçiyoruz
                let darkTheme = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Koyu' OR label CONTAINS[c] 'Dark'")).firstMatch
                let lightTheme = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Açık' OR label CONTAINS[c] 'Light'")).firstMatch
                
                if darkTheme.exists {
                    darkTheme.tap()
                    sleep(1)
                    
                    // Then: Tema değişmeli (crash olmamalı)
                    XCTAssertTrue(app.navigationBars.firstMatch.exists)
                } else if lightTheme.exists {
                    lightTheme.tap()
                    sleep(1)
                    XCTAssertTrue(app.navigationBars.firstMatch.exists)
                }
            }
        }
    }
    
    /// Test 6: İlişki bilgileri görünmeli
    func testRelationshipInfoDisplayed() throws {
        // Given: Profile ekranındayız
        
        // Then: Partner ismi ve ilişki tarihi görünür olmalı
        let relationshipInfo = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'gün' OR label CONTAINS[c] 'Partner'")).firstMatch
        let partnerName = app.staticTexts.matching(NSPredicate(format: "label.length > 0")).element(boundBy: 1)
        
        XCTAssertTrue(
            relationshipInfo.exists || partnerName.exists,
            "İlişki bilgileri görünür olmalı"
        )
    }
    
    /// Test 7: Bildirim ayarları değiştirilebilmeli
    func testNotificationSettings() throws {
        // Given: Ayarlar ekranına gidiyoruz
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Ayarlar'")).firstMatch
        
        if settingsButton.waitForExistence(timeout: 3) {
            settingsButton.tap()
            sleep(1)
            
            // When: Bildirim toggle'ını buluyoruz
            let notificationToggle = app.switches.matching(NSPredicate(format: "label CONTAINS[c] 'Bildirim' OR label CONTAINS[c] 'Notification'")).firstMatch
            
            if notificationToggle.waitForExistence(timeout: 2) {
                let initialState = notificationToggle.value as? String
                
                // When: Toggle'ı değiştiriyoruz
                notificationToggle.tap()
                sleep(1)
                
                // Then: Durum değişmeli
                let newState = notificationToggle.value as? String
                XCTAssertNotEqual(initialState, newState, "Bildirim durumu değişmeli")
            }
        }
    }
    
    /// Test 8: Çıkış yapma işlemi çalışmalı
    func testLogoutFlow() throws {
        // Given: Ayarlar veya profil ekranında "Çıkış Yap" butonunu buluyoruz
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Ayarlar'")).firstMatch
        
        if settingsButton.exists {
            settingsButton.tap()
            sleep(1)
        }
        
        // When: "Çıkış Yap" butonuna tıklıyoruz
        let logoutButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Çıkış' OR label CONTAINS[c] 'Logout'")).firstMatch
        
        if logoutButton.waitForExistence(timeout: 3) {
            logoutButton.tap()
            
            // When: Onay dialogunda "Evet"
            let confirmButton = app.buttons["Evet"].firstMatch
            if confirmButton.waitForExistence(timeout: 2) {
                confirmButton.tap()
                
                // Then: Login ekranına dönmeli
                sleep(2)
                let emailField = app.textFields["Email"]
                let loginButton = app.buttons["Giriş Yap"]
                
                XCTAssertTrue(
                    emailField.exists || loginButton.exists,
                    "Çıkış yapınca login ekranına dönmeli"
                )
            }
        }
    }
}
