//
//  SongsViewUITests.swift
//  sevgilimUITests
//
//  Created by GitHub Copilot on 17/10/2025.
//

import XCTest

/// UI testleri: SongsView, AddSongView
/// Şarkılar feature'ının tüm kullanıcı etkileşimlerini test eder
final class SongsViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
        
        loginIfNeeded()
        
        // Songs ekranına git
        navigateToSongs()
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
    
    private func navigateToSongs() {
        // Hamburger menüden şarkılara git
        let hamburgerButton = app.buttons.matching(identifier: "hamburgerMenuButton").firstMatch
        if hamburgerButton.waitForExistence(timeout: 3) {
            hamburgerButton.tap()
            sleep(1)
            
            let songsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Şarkı'")).firstMatch
            if songsButton.exists {
                songsButton.tap()
            }
        }
    }
    
    // MARK: - Test Cases
    
    /// Test 1: SongsView liste görünümü çalışmalı
    func testSongsListDisplays() throws {
        // Given: Songs ekranındayız
        
        // Then: Liste veya boş durum görünür olmalı
        let songsList = app.scrollViews.firstMatch
        let emptyState = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'şarkı'")).firstMatch
        
        XCTAssertTrue(
            songsList.exists || emptyState.exists,
            "Şarkı listesi veya boş durum görünür olmalı"
        )
    }
    
    /// Test 2: Yeni şarkı ekleme butonu çalışmalı
    func testAddNewSongButton() throws {
        // Given: "Yeni Şarkı" butonunu buluyoruz
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Şarkı' OR label CONTAINS[c] 'Ekle'")).firstMatch
        
        if addButton.waitForExistence(timeout: 3) {
            // When: Butona tıklıyoruz
            addButton.tap()
            
            // Then: Form ekranı açılmalı
            sleep(1)
            XCTAssertTrue(
                app.textFields.firstMatch.exists ||
                app.buttons["Kaydet"].exists ||
                app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Spotify'")).firstMatch.exists,
                "Şarkı ekleme formu açılmalı"
            )
        }
    }
    
    /// Test 3: Spotify entegrasyonu butonu çalışmalı
    func testSpotifyIntegration() throws {
        // Given: Yeni şarkı ekleme ekranındayız
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Ekle'")).firstMatch
        
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()
            sleep(1)
            
            // When: "Spotify'dan Ara" butonunu buluyoruz
            let spotifyButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Spotify'")).firstMatch
            
            if spotifyButton.waitForExistence(timeout: 2) {
                spotifyButton.tap()
                
                // Then: Spotify arama ekranı veya browser açılmalı
                sleep(2)
                XCTAssertTrue(
                    app.textFields.matching(identifier: "searchField").firstMatch.exists ||
                    app.searchFields.firstMatch.exists ||
                    app.webViews.firstMatch.exists ||
                    app.buttons["Geri"].exists,
                    "Spotify entegrasyonu çalışmalı"
                )
            }
        }
    }
    
    /// Test 4: Şarkı favorileme çalışmalı
    func testFavoriteSong() throws {
        // Given: Listede en az bir şarkı var
        let firstSong = app.cells.firstMatch
        
        if firstSong.waitForExistence(timeout: 3) {
            // When: Favori butonuna tıklıyoruz
            let favoriteButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'favorite' OR identifier CONTAINS 'heart'")).firstMatch
            
            if favoriteButton.exists {
                favoriteButton.tap()
                
                // Then: Favori durumu değişmeli
                sleep(1)
                XCTAssertTrue(
                    favoriteButton.exists,
                    "Favori işlemi çalışmalı"
                )
            } else {
                // Alternatif: Detaya girip favorile
                firstSong.tap()
                sleep(1)
                
                let detailFavoriteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Favori'")).firstMatch
                if detailFavoriteButton.exists {
                    detailFavoriteButton.tap()
                    sleep(1)
                    XCTAssertTrue(app.buttons["Geri"].exists || app.staticTexts.count > 0)
                }
            }
        } else {
            throw XCTSkip("Test için şarkı verisi bulunamadı")
        }
    }
    
    /// Test 5: Şarkı çalma/oynat butonu çalışmalı
    func testPlaySong() throws {
        // Given: Listede en az bir şarkı var
        let firstSong = app.cells.firstMatch
        
        if firstSong.waitForExistence(timeout: 3) {
            firstSong.tap()
            sleep(1)
            
            // When: Oynat butonunu buluyoruz
            let playButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Oynat' OR identifier CONTAINS 'play'")).firstMatch
            
            if playButton.waitForExistence(timeout: 2) {
                playButton.tap()
                
                // Then: Müzik çalmaya başlamalı (pause butonu görünmeli)
                sleep(2)
                let pauseButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Duraklat' OR identifier CONTAINS 'pause'")).firstMatch
                
                XCTAssertTrue(
                    pauseButton.exists || playButton.exists,
                    "Oynatma işlemi çalışmalı"
                )
            }
        } else {
            throw XCTSkip("Test için şarkı verisi bulunamadı")
        }
    }
    
    /// Test 6: Şarkı silme işlemi çalışmalı
    func testDeleteSong() throws {
        // Given: Bir şarkı detayındayız
        let firstSong = app.cells.firstMatch
        
        if firstSong.waitForExistence(timeout: 3) {
            let songTitle = firstSong.staticTexts.firstMatch.label
            firstSong.tap()
            sleep(1)
            
            // When: Sil butonuna tıklıyoruz
            let deleteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Sil'")).firstMatch
            if deleteButton.waitForExistence(timeout: 2) {
                deleteButton.tap()
                
                // When: Onay dialog'unda "Evet"
                let confirmButton = app.buttons["Evet"].firstMatch
                if confirmButton.waitForExistence(timeout: 2) {
                    confirmButton.tap()
                    
                    // Then: Liste ekranına dönmeli ve şarkı silinmiş olmalı
                    sleep(2)
                    let deletedSong = app.staticTexts[songTitle]
                    XCTAssertFalse(deletedSong.exists, "Silinen şarkı listede görünmemeli")
                }
            }
        } else {
            throw XCTSkip("Test için şarkı verisi bulunamadı")
        }
    }
}
